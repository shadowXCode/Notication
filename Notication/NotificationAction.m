//
//  NotificationAction.m
//  Notication
//
//  Created by Walker on 2019/4/18.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import "NotificationAction.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

NSString * const Invite_Dely_locationCategoryIdentifier = @"Invite_Dely_locationCategoryIdentifier";

@implementation NotificationAction

+ (void)addInviteNotificationAction {
    //创建按钮Action
    UNNotificationAction *lookAction = [UNNotificationAction actionWithIdentifier:@"action.access" title:@"接收邀请" options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction *joinAction = [UNNotificationAction actionWithIdentifier:@"action.look" title:@"查看邀请" options:UNNotificationActionOptionForeground];
    UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"action.cancel" title:@"取消" options:UNNotificationActionOptionDestructive];
    
    // 注册 category
    // * identifier 标识符
    // * actions 操作数组
    // * intentIdentifiers 意图标识符 可在 <Intents/INIntentIdentifiers.h> 中查看，主要是针对电话、carplay 等开放的 API。
    // * options 通知选项 枚举类型 也是为了支持 carplay
    UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:Invite_Dely_locationCategoryIdentifier actions:@[lookAction, joinAction, cancelAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    // | UNNotificationCategoryOptionHiddenPreviewsShowTitle | UNNotificationCategoryOptionHiddenPreviewsShowSubtitle
    
    // 将 category 添加到通知中心
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[NSSet setWithObject:notificationCategory]];
}

@end
