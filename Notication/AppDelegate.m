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
#import <CoreTelephony/CTCellularData.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

/**
 程序启动调用，当用户通过点击通知图标进入程序时可通过launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]进行获取推送消息，不建议使用此方法处理通知。
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //开启网络监控，在iOS10下会自动向用户请求网络通信权限。如果Notification Service Extension中需要进行网络请求，没有网络权限将会得到“The Internet connection appears to be offline.”错误信息。
    [[HBOAReachability sharedInstance] startMonitoring];
    [[HBOAReachability sharedInstance] setReachabilityStatusChangeBlock:^(HBOANetworkStatus status) {
        
    }];
    
    
    //通知注册
    NSDictionary *notificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationUserInfo) {
        NSLog(@"%@ : %@",NSStringFromSelector(_cmd),notificationUserInfo);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [HBOAAlertView alertMessage:NSStringFromSelector(_cmd) delay:2];
        });
    }

    [self registerRemoteNotifications];

    if (@available(iOS 10.0, *)) {
        //获取通知配置信息
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {

        }];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    //阻塞2s主线程
//    CFRunLoopRef ref = CFRunLoopGetCurrent();
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CFRunLoopStop(ref);
//    });
//    CFRunLoopRun();
    
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
 
 UNAuthorizationOptions授权类型：
 UNAuthorizationOptionBadge：更新应用角标的权限
 UNAuthorizationOptionSound：通知到达时的提示音权限
 UNAuthorizationOptionAlert：通知到达时弹窗权限
 UNAuthorizationOptionCarPlay：车载设备通知权限
 UNAuthorizationOptionCriticalAlert：iOS12引入；发送重要通知的权限，重要通知会无视静音和勿打扰模式，通知到达时会有提示音，此权限要通过苹果审核
 UNAuthorizationOptionProvisional：临时授权----无需用户授权也能给用户推送的新机制，默认为隐式推送（仅在通知中心显示通知，会包含两个按钮：保持、关闭。）
 UNAuthorizationOptionProvidesAppNotificationSettings：iOS12 通知管理->关闭 / 通知设置 页面会出现：在“Notication”中配置...选项，点击进入应用。主要是进入应用自身的通知设置页面
 */
- (void)registerRemoteNotifications {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
        if (@available(iOS 12.0, *)) {
            authOptions = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionProvisional;
        }
        [center requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError *_Nullable error) {
            //请求推送授权成功，下面注册远程推送。如果需要注册远程推送的话，无论用户是否授权都建议注册；否则一旦用户在设置页面开启推送，必须重新app才能注册成功。
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }];
    } else {
        /**
         iOS8 --- iOS10之前注册远程通知方法
         如果iOS10及以上系统还用该方法进行注册通知也是可以，但是APNs注册就比较乱了，会忽略用户授权直接注册成功APNs返回DeviceToken，当用户授权成功了还会重复的回调application:didRegisterForRemoteNotificationsWithDeviceToken方法。不建议这样使用。
         */
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        //iOS8和iOS9通过这种方式设置categorys，categorys生成&使用方式与iOS10类似
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
 收到本地通知，iOS10以下可用。
 若iOS10及以上未实现 -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] 则还执行该代理进行本地通知处理。
 若本地通知有自定义action事件，点击对应action事件，不会回调该代理
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
    [self handleRemoteNotification:userInfo completionHandler:nil cmdStr:NSStringFromSelector(_cmd)];
}

/**
 告诉应用程序收到远程推送通知，有需要提取的数据
 此方法与application:didReceiveRemoteNotification（简称方法一）还是有些不同，当两个方法都实现的情况下，方法一并不会被调用，所以iOS8--iOS10以下系统适配只需要实现该方法即可。
 注意：当用户通过点击通知栏的通知打开app，系统还是会再次调用该方法，以方便开发者处理事件
 系统版本>=iOS10，如果没有实现UNUserNotificationCenterDelegate代理则会通过该代理进行远程通知回调（app在前台收到通知回调，顶部没有alert告知；app在后台顶部会弹出alert，点击alert调用）；如果实现了UNUserNotificationCenterDelegate，则不会调用该方法。

 当推送内容设定了"content-available" : 1，会调用该代理方法，哪怕app进程不存在也会唤醒app（限制30s）
 需要在Capabilities中开启Background Modes勾选Remote notifications
 官方文档：https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_updates_to_your_app_silently
 一般用于静默推送（没有：alert、badge、sound）例如：
 {
 "aps" : {
 "content-available" : 1
 },
 "acme1" : "bar",
 "acme2" : 42
 }
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler NS_AVAILABLE_IOS(7_0) {
    NSLog(@"%@ : %@",NSStringFromSelector(_cmd),userInfo);
    [self handleRemoteNotification:userInfo completionHandler:^{
        completionHandler(UIBackgroundFetchResultNewData);
    } cmdStr:NSStringFromSelector(_cmd)];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


//iOS>=10 中收到推送消息（远程/本地），遵守UNUserNotificationCenterDelegate。
/**
 处理app在前台运行时到达的通知，这时通知并未提示，当处理完成后执行completionHandler来确定通知样式
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (userInfo) {
        NSLog(@"%@ : %@",NSStringFromSelector(_cmd),userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
/**
 本地、远程推送，点击通知进入app或者点击通知上的自定义action时触发，会唤醒app进行事件处理
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (userInfo) {
        NSLog(@"%@ : %@",NSStringFromSelector(_cmd),userInfo);
    }
    completionHandler();
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
/**
 iOS12 通知管理->关闭 / 通知设置 页面会出现：在“Notication”中配置...选项，点击进入应用。主要是进入应用自身的通知设置页面
 该方法调用需要在授权的时候增加这个选项 UNAuthorizationOptionProvidesAppNotificationSettings
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification __IOS_AVAILABLE(12.0) __OSX_AVAILABLE(10.14) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;{
    if (notification) {
        //从通知管理界面进入应用

    } else {
        //从通知设置页面进入应用

    }
}


#pragma mark - iOS8、iOS9本地、远程通知action事件回调处理
/**
 本地、远程推送会唤醒app执行
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
//本地推送
// Called when your app has been activated by the user selecting an action from a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling the action.
/**
 iOS8系统下本地推送点击action，回调该代理进行事件处理。
 iOS9系统下若未实现 -[UIApplicationDelegate application:handleActionWithIdentifier:forLocalNotification:withResponseInfo:completionHandler:] 则还会回调该代理进行处理事件
 iOS10及以上系统若未实现 -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] 则还会回调该代理进行处理事件
 */
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]") __TVOS_PROHIBITED;{

}
/**
 iOS9系统下本地推送点击action，回调该代理进行事件处理。
 iOS10及以上系统如果未实现UNUserNotificationCenterDelegate则还会回调该代理进行处理事件
 */
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(9_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]") __TVOS_PROHIBITED;{

}

//远程推送
// Called when your app has been activated by the user selecting an action from a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling the action.
/**
 iOS8系统下远程推送点击action，回调该代理进行事件处理。
 iOS9系统下若未实现 -[UIApplicationDelegate application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler:] 则还会回调该代理进行处理事件
 iOS10及以上系统若未实现 -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] 则还会回调该代理进行处理事件
 */
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]") __TVOS_PROHIBITED;{

}
/**
 iOS9系统下远程推送点击action，回调该代理进行事件处理。
 iOS10及以上系统如果未实现UNUserNotificationCenterDelegate则还会回调该代理进行处理事件
 */
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(9_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]") __TVOS_PROHIBITED;{

}
#pragma clang diagnostic pop



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

