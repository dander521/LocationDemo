//
//  ViewController.m
//  LocationDemo
//
//  Created by 程荣刚 on 2017/10/12.
//  Copyright © 2017年 程荣刚. All rights reserved.
//

#import "ViewController.h"
#import "TXLocationManager.h"
#import "CDZPicker.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate>

/** 定位*/
@property (nonatomic, strong) TXLocationManager *locationManager;

@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSMutableArray *cityArray;
@property (nonatomic, strong) NSMutableDictionary *cityDictionary;

@property (nonatomic, strong) NSMutableArray *showArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cityArray = [NSMutableArray new];
    self.cityDictionary = [NSMutableDictionary new];
    self.showArray = [NSMutableArray new];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    self.locationManager = [[TXLocationManager alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.locationManager locationManagerWithsuccess:^(NSString *cityName) {
        weakSelf.cityName = cityName;
        AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
        dist.keywords = cityName;
        [self.search AMapDistrictSearch:dist];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [self geocodeAddressToLocation:@"成都市"];
    
    
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ ", error);
}

- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    NSLog(@"response: %@", response.formattedDescription);
    for (AMapDistrict *dictrict in response.districts) {
        NSLog(@"...%@", dictrict.name);
        if ([self.cityName isEqualToString:dictrict.name]) {
            for (AMapDistrict *obj in dictrict.districts) {
                NSLog(@"+++%@", obj.name);
                [self.cityArray addObject:obj.name];
            }
            for (int i = 0; i < self.cityArray.count; i++) {
                AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
                dist.keywords = self.cityArray[i];
                [self.search AMapDistrictSearch:dist];
            }
        } else {
            NSMutableArray *subArray = [NSMutableArray new];
            for (AMapDistrict *obj in dictrict.districts) {
                NSLog(@"+++%@", obj.name);
                [subArray addObject:obj.name];
            }
            [self.cityDictionary setValue:subArray forKey:dictrict.name];
        }
    }
    NSLog(@"self.cityDictionary = %@", self.cityDictionary);
}

- (IBAction)touchShowBtn:(id)sender {
    NSArray *allKeys = self.cityDictionary.allKeys;
    
    NSMutableArray *allArea = [NSMutableArray new];
    
    for (NSString *key in allKeys) {
        CDZPickerComponentObject *area = [[CDZPickerComponentObject alloc] initWithText:key];
        
        NSArray *subArea = [self.cityDictionary objectForKey:key];
        
        NSMutableArray *subArray = [NSMutableArray new];
        for (NSString *subName in subArea) {
            CDZPickerComponentObject *subObj = [[CDZPickerComponentObject alloc] initWithText:subName];
            [subArray addObject:subObj];
        }
        
        area.subArray = [NSMutableArray arrayWithArray:[self orderArrayWithArray:subArray]];
        [allArea addObject:area];
    }
    
    [CDZPicker showLinkagePickerInView:self.view withBuilder:nil components:[self orderArrayWithArray:allArea] confirm:^(NSArray<NSString *> * _Nonnull strings, NSArray<NSNumber *> * _Nonnull indexs) {
        NSLog(@"strings = %@", strings);
    } cancel:^{
        //your code
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)orderArrayWithArray:(NSMutableArray *)array {
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(CDZPickerComponentObject *obj1, CDZPickerComponentObject *obj2) {
        return [obj2.text compare:obj1.text]; //升序
    }];
    
    return [NSMutableArray arrayWithArray:result];
}


/**
 * 根据地名获取经纬度
 */
- (void)geocodeAddressToLocation:(NSString*)addressName {
    CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
    [myGeocoder geocodeAddressString:addressName completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil) {
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            NSString *longitude = [NSString stringWithFormat:@"%f",firstPlacemark.location.coordinate.longitude];
            
            NSString *latitude = [NSString stringWithFormat:@"%f",firstPlacemark.location.coordinate.latitude];
            NSLog(@"longitude === %@ latitude === %@", longitude, latitude);
        }
        else if ([placemarks count] == 0 && error == nil) {
            
        } else if (error != nil) {
            
        }
    }];
}


@end
