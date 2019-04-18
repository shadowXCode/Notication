//
//  LocalNotificationViewController.m
//  Notication
//
//  Created by 张二帅 on 2019/4/16.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import "LocalNotificationViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
#import <CoreLocation/CoreLocation.h>

#import "NotificationAction.h"

NSString * const LocalNotiReqIdentifer = @"LocalNotiReqIdentifer";


@interface LocalNotificationViewController ()

@end

@implementation LocalNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"本地推送";
}

- (IBAction)delayNotificationClick:(UIButton *)sender {
    [self sendDelayLocalNotification];
}

- (IBAction)calendarNotificationClick:(id)sender {
    if (@available(iOS 10.0, *)) {
        [self sendCalendarNotification];
    }
}

- (IBAction)locationNotificationClick:(id)sender {
    if (@available(iOS 10.0, *)) {
        [self sendLocationNotification];
    }
}

- (IBAction)cancelocalNotification:(id)sender {
    [self cancelLocalNotificaitons];
}

//定时推送
- (void)sendDelayLocalNotification {
    NSString *title = @"定时推送";
    NSInteger timeInteval = 5;
    NSDictionary *userInfo = @{@"id":@"LOCAL_NOTIFY_SCHEDULE_ID"};
    if (@available(iOS 10.0, *)) {
        // 3.触发模式
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInteval repeats:NO];
        // 4.设置UNNotificationRequest
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:LocalNotiReqIdentifer content:[self notificationContentWithTitle:@"定时推送"] trigger:trigger];
        
        //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
        
    } else {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        // 1.设置触发时间（如果要立即触发，无需设置）
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
        // 2.设置通知标题
        localNotification.alertBody = title;
        
        // 3.设置通知动作按钮的标题
        localNotification.alertAction = @"查看";
        
        // 4.设置提醒的声音
        localNotification.soundName = @"sound01.wav";// UILocalNotificationDefaultSoundName;
        
        // 5.设置通知的 传递的userInfo
        localNotification.userInfo = userInfo;
        
        // 6.在规定的日期触发通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        // 6.立即触发一个通知
        //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

//定期推送
- (void)sendCalendarNotification API_AVAILABLE(ios(10.0)){
    //创建日期组件
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday = 4;
    components.hour = 13;
    components.minute = 29;
    UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:LocalNotiReqIdentifer content:[self notificationContentWithTitle:@"定期通知"] trigger:calendarTrigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

//定点推送
- (void)sendLocationNotification API_AVAILABLE(ios(10.0)){
    //创建位置信息
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(31.185362, 121.482136);
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center radius:500 identifier:@"宝武大厦"];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
    // region 位置信息 repeats 是否重复
    UNLocationNotificationTrigger *locationTrigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:LocalNotiReqIdentifer content:[self notificationContentWithTitle:@"定点推送"] trigger:locationTrigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}


- (void)cancelLocalNotificaitons {
    //! 取消一个特定的通知
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //获取当前所有的本地通知
    if (!notificaitons || notificaitons.count <= 0) { return; }
    for (UILocalNotification *notify in notificaitons) {
        if ([[notify.userInfo objectForKey:@"id"] isEqualToString:@"LOCAL_NOTIFY_SCHEDULE_ID"]) {
            if (@available(iOS 10.0, *)) {
                [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[LocalNotiReqIdentifer]];
            } else {
                [[UIApplication sharedApplication] cancelLocalNotification:notify];
            }
            break;
        }
    }
    //! 取消所有的本地通知
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (UNMutableNotificationContent *)notificationContentWithTitle:(NSString *)title API_AVAILABLE(ios(10.0)) {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.subtitle = @"通知-subtitle";
    content.body = @"通知-body";
    content.badge = @1;
    content.userInfo = @{@"id":@"LOCAL_NOTIFY_SCHEDULE_ID"};
    
    //    设置声音，默认声音为：[UNNotificationSound defaultSound];
    content.sound = [UNNotificationSound soundNamed:@"sound01.wav"];
    
    //如果使用action时设置category标识符，保证该标识符已注册
    content.categoryIdentifier = Invite_Dely_locationCategoryIdentifier;
    [NotificationAction addInviteNotificationAction];
    
    //增加附件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"logo_img_02@2x" ofType:@"png"];
    UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:nil];
    content.attachments = @[att];
    
    content.launchImageName = @"logo_img_02";
    
    return content;
}





@end
