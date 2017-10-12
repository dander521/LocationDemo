//
//  TXLocationManager.m
//  TailorX
//
//  Created by Qian Shen on 8/8/17.
//  Copyright © 2017年 utouu. All rights reserved.
//

#import "TXLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface TXLocationManager ()<CLLocationManagerDelegate>

/** 定位*/
@property (nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation TXLocationManager

- (instancetype)init {
    if (self = [super init]) {
        [self locate];
    }
    return self;
}

- (void)locate {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100.0f;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark CoreLocation delegate

- (void)locationManagerWithsuccess:(SuccessBlock)success failure:(FailureBlock)failure {
    self.failureBlock =  failure;
    self.successBlock = success;
}

/**
 * 定位失败
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

/**
 * 定位成功
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    NSString *longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    NSLog(@"longitude = %@ latitude = %@", longitude, latitude);
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    //反编码
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            __weak typeof(self) weakSelf = self;
            // 当前城市
            CLPlacemark *placeMark = placemarks[0];
            if (!placeMark.locality) {
                if (weakSelf.successBlock) {
                    weakSelf.successBlock(@"无法定位当前城市");
                }
            }else {
                NSString *currentCity = placeMark.locality;
//                for(int i = 0; i < [currentCity length]; i++) {
//                    NSString *tempStr = [currentCity substringWithRange:NSMakeRange(i,1)];
//                    if ([tempStr isEqualToString:@"市"] && i == currentCity.length-1) {
//                        currentCity = [currentCity substringToIndex:currentCity.length-1];
//                    }
//                }
                if (weakSelf.successBlock) {
                    weakSelf.successBlock(currentCity);
                }
            }
        }else if (error == nil && placemarks.count == 0) {
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }else if (error) {
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }
    }];
}

- (void)dealloc {
    NSLog(@"-----------------------------------定位dealloc-----------------------------");
}

@end
