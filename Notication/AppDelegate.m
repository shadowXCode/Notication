//
//  AppDelegate.m
//  Notication
//
//  Created by Walker on 2019/4/11.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import "AppDelegate.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

/**
 程序启动调用，当用户通过点击通知图标进入程序时可通过launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]进行获取推送消息，不建议使用此方法处理通知。
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSDictionary *notificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationUserInfo) {
        NSLog(@"%@ : %@",NSStringFromSelector(_cmd),notificationUserInfo);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [HBOAAlertView alertMessage:NSStringFromSelector(_cmd) delay:2];
        });
    }
    
    [self registerRemoteNotifications];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




//通知相关，不考虑iOS8以下通知

#pragma mark - 推送通知注册
/**
 注册远程推送通知，同本地通知注册，不同的是远程推送通知授权成功时候需要调用：[[UIApplication sharedApplication] registerForRemoteNotifications];
 
 权限申请：
 iOS10以后，权限申请通过requestAuthorizationWithOptions进行
 iOS8---iOS10以下，权限申请回调通过UIApplicationDelegate的- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings代理方法进行告知应用
 */
- (void)registerRemoteNotifications {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (granted) {
                //请求推送授权成功，下面注册远程推送
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else {
        /**
         iOS8 --- iOS10之前注册远程通知方法
         如果iOS10及以上系统还用该方法进行注册通知也是可以，但是APNs注册就比较乱了，会忽略用户授权直接注册成功APNs返回DeviceToken，当用户授权成功了还会重复的回调application:didRegisterForRemoteNotificationsWithDeviceToken方法。不建议这样使用。
         */
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        //注册远程推送
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

/**
 进入应用后如果没有注册通知，需要首先注册通知请求用户允许通知；一旦调用完注册方法，无论用户是否选择允许通知此刻都会调用该代理方法。
 只要应用启动注册通知，每次都会调用该方法
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:]") __TVOS_PROHIBITED;{
    
}

/**
 注册APNs成功，并返回deviceToken
 只要应用启动注册通知成功，每次都会调用该方法
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 获取并处理deviceToken
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"DeviceToken:%@\n", token);
}

/**
 注册APNs失败
 只要应用启动注册通知失败，每次都会调用该方法
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

#pragma mark - 收到通知

/**
 收到本地通知，iOS10以下可用
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification NS_DEPRECATED_IOS(4_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]") __TVOS_PROHIBITED; {
    
}

/**
 iOS10以下可用，收到远程推送通知
 app进程终止情况下，该方法不会被调用。
 app在后台挂起状态时，只有用户点击了通知消息时会调用该方法。
 app在前台状态时，会直接调用该方法。
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_DEPRECATED_IOS(3_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications") {
    NSLog(@"%@ : %@",NSStringFromSelector(_cmd),userInfo);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [HBOAAlertView alertMessage:NSStringFromSelector(_cmd)];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self handleRemoteNotification:userInfo completionHandler:nil cmdStr:NSStringFromSelector(_cmd)];
//        });
//    });
    [self handleRemoteNotification:userInfo completionHandler:nil cmdStr:NSStringFromSelector(_cmd)];
}

/**
 告诉应用程序收到远程推送通知，有需要提取的数据
 此方法与application:didReceiveRemoteNotification（简称方法一）还是有些不同，当两个方法都实现的情况下，方法一并不会被调用，所以iOS8--iOS10以下系统适配只需要实现该方法即可。
 注意：当用户通过点击通知栏的通知打开app，系统还是会再次调用该方法，以方便开发者处理事件
 如果
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler NS_AVAILABLE_IOS(7_0) {
    NSLog(@"%@ : %@",NSStringFromSelector(_cmd),userInfo);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [HBOAAlertView alertMessage:NSStringFromSelector(_cmd)];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self handleRemoteNotification:userInfo completionHandler:^{
//                completionHandler(UIBackgroundFetchResultNewData);
//            }];
//        });
//    });
    [self handleRemoteNotification:userInfo completionHandler:^{
        completionHandler(UIBackgroundFetchResultNewData);
    } cmdStr:NSStringFromSelector(_cmd)];
}


//iOS>=10 中收到推送消息（远程/本地）
/**
 询问UNUserNotificationCenterDelegate如何处理应用程序在前台运行时到达的通知
 ？？？？……
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (userInfo) {
        NSLog(@"%@ : %@",NSStringFromSelector(_cmd),userInfo);
//        NSLog(@"app位于前台通知(willPresentNotification:):%@", userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
/**
 <#Description#>
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (userInfo) {
        NSLog(@"%@ : %@",NSStringFromSelector(_cmd),userInfo);
//        NSLog(@"点击通知进入App时触发(didReceiveNotificationResponse:):%@", userInfo);
    }
    completionHandler();
}




#pragma mark - custom methods
/**
 处理收到的远程通知
 */
- (void)handleRemoteNotification:(nullable NSDictionary *)userInfo completionHandler:(nullable void (^)(void))completionHandler cmdStr:(NSString *)cmdStr {
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive:
        {
            //应用程序运行在前台，接收事件。
            NSLog(@"UIApplicationStateActive");
            [HBOAAlertView alertMessage:@"UIApplicationStateActive"];
        }
            break;
        case UIApplicationStateInactive:
        {
            /**
             应用程序运行在前台但不接收事件。这可能发生的由于一个中断或因为应用过渡到后台或者从后台过度到前台。
             三个场景：
             1>电话进来或者其他中断事件
             2>从前台进入后台的过度时间
             3>从后台进入前台的过度时间
             */
            NSLog(@"UIApplicationStateInactive");
            [HBOAAlertView alertMessage:@"UIApplicationStateInactive"];
        }
            break;
        case UIApplicationStateBackground:
        {
            //应用程序在后台运行。
            NSLog(@"UIApplicationStateBackground");
//            [HBOAAlertView alertMessage:@"UIApplicationStateBackground" delay:5];
            
            [self saveText:[NSString stringWithFormat:@"%@ : %@",cmdStr,userInfo]];
        }
            break;
    }
    if (completionHandler) {
        completionHandler();
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)saveText:(NSString *)text {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"notification.txt"];
    BOOL res = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (!res) {
        return;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [handle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

@end
