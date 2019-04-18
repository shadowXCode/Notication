//
//  ViewController.m
//  Notication
//
//  Created by Walker on 2019/4/11.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import "ViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#import "MoLocationManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Notification"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
}

//清除沙盒中写入的日志
- (IBAction)clearNotificationLog:(UIBarButtonItem *)sender {
    [HBLogProfiler clearedNotificationDirectory];
}

- (void)getCurrentLocationInfo {
    //只获取一次
    __block  BOOL isOnece = YES;
    [MoLocationManager getMoLocationWithSuccess:^(double lat, double lng){
        isOnece = NO;
        //只打印一次经纬度
        NSLog(@"lat lng (%f, %f)", lat, lng);
        
        if (!isOnece) {
            [MoLocationManager stop];
        }
    } Failure:^(NSError *error){
        isOnece = NO;
        NSLog(@"error = %@", error);
        if (!isOnece) {
            [MoLocationManager stop];
        }
    }];
}


@end
