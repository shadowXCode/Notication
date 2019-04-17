//
//  AppDelegate.m
//  QiNotification
//
//  Created by wangdacheng on 2018/8/29.
//  Copyright © 2018年 dac. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    ViewController *controller = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window setRootViewController:nav];
    [_window makeKeyAndVisible];
    
    // 注册远程推送通知
    [self registerRemoteNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    return YES;
}

/**
 注册远程推送通知，同本地通知注册不同的是当通知授权成功时候需要调用：[[UIApplication sharedApplication] registerForRemoteNotifications];
 */
- (void)registerRemoteNotifications {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                //请求推送授权成功，下面注册远程推送
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0 && __IPHONE_OS_VERSION_ALLOWED >= __IPHONE_8_0
        // iOS8 --- iOS10之前注册远程通知方法
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        //注册远程推送
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    }
}

//已经注册远程推送并返回DeviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // 获取并处理deviceToken
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"DeviceToken:%@\n", token);
}

//远程推送注册失败回调
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error.description);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
//进入应用后如果没有注册通知，需要首先注册通知请求用户允许通知；一旦调用完注册方法，无论用户是否选择允许通知此刻都会调用该代理方法。在这个方法中根据用户的选择：如果是允许通知则会按照前面的步骤创建通知并在一定时间后执行。
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:]") __TVOS_PROHIBITED;{
    
    NSLog(@"didRegisterUserNotificationSettings");
}
#endif


//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
//收到本地通知回调
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"app收到本地推送(didReceiveLocalNotification:):%@", notification.userInfo);
}
//#endif

//用于显示通知
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_0
// 注：iOS10以上如果不使用UNUserNotificationCenter时，也将走此回调方法，不过尽量要遵守规则。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_DEPRECATED_IOS(3_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications") {
    
    if (userInfo) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {// app位于前台通知
            NSLog(@"app位于前台通知(didReceiveRemoteNotification:):%@", userInfo);
        } else {// 切到后台唤起
            NSLog(@"app位于后台通知(didReceiveRemoteNotification:):%@", userInfo);
        }
    }
}
#else



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler NS_AVAILABLE_IOS(7_0) {
    [self saveText:[NSString stringWithFormat:@"%@ -> %@ : %@",[NSDate date],NSStringFromSelector(_cmd),userInfo] file:@"iOS7*_receiveRemote"];
    completionHandler(UIBackgroundFetchResultNewData);
}




//iOS>=10 中收到推送消息（远程/本地）

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (userInfo) {
        NSLog(@"app位于前台通知(willPresentNotification:):%@", userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

/**
 点击通知进入app时触发
 本地通知、远程通知都会唤醒app回调该方法进行处理事件，限制30s

 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (userInfo) {
        NSLog(@"点击通知进入App时触发(didReceiveNotificationResponse:):%@", userInfo);
    }
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        UNTextInputNotificationResponse *inputResponse = (UNTextInputNotificationResponse *)response;
        [self saveText:[NSString stringWithFormat:@"%@ -> %@ : %@ (%@)",[NSDate date],NSStringFromSelector(_cmd),userInfo,inputResponse.userText] file:@"iOS10*_receiveRemote"];
    } else {
        [self saveText:[NSString stringWithFormat:@"%@ -> %@ : %@",[NSDate date],NSStringFromSelector(_cmd),userInfo] file:@"iOS10*_receiveRemote"];
    }
    
    completionHandler();
}


- (void)saveText:(NSString *)text file:(NSString *)fileName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:@"NotificationLogs"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",fileName]];
    BOOL res = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (!res) {
        return;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [handle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

#endif


@end




//// apsModel示例
/*
 特殊说明：
 1. APNS去掉alert、badge、sound字段实现静默推送，增加增加字段"content-available":1，也可以在后台做一些事情。
 2. mutable-content这个键值为1，说明此条推送可以被 Service Extension 进行更改。
 */

/**
 {"aps":{"alert":{"title":"通知的title","subtitle":"通知的subtitle","body":"通知的body","title-loc-key":"TITLE_LOC_KEY","title-loc-args":["t_01","t_02"],"loc-key":"LOC_KEY","loc-args":["l_01","l_02"]},"sound":"sound01.wav","badge":1,"mutable-content":1,"category": "QiShareCategoryIdentifier"},"msgid":"123"}
 */

/**
{"aps":{"alert":{"title":"Title...","subtitle":"Subtitle...","body":"Body..."},"sound":"default","badge": 1,"mutable-content": 1,"category": "QiShareCategoryIdentifier",},"msgid":"123","media":{"type":"image","url":"https://www.fotor.com/images2/features/photo_effects/e_bw.jpg"}}
*/
