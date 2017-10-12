//
//  ViewController.m
//  LocationDemo
//
//  Created by 程荣刚 on 2017/10/12.
//  Copyright © 2017年 程荣刚. All rights reserved.
//

#import "ViewController.h"
#import "TXLocationManager.h"

@interface ViewController ()

/** 定位*/
@property (nonatomic, strong) TXLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[TXLocationManager alloc] init];
    [self.locationManager locationManagerWithsuccess:^(NSString *cityName) {
        NSLog(@"cityName = %@", cityName);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
