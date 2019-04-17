//
//  NotificationService.h
//  NotificationService
//
//  Created by Walker on 2019/4/16.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

@interface NotificationService : UNNotificationServiceExtension

@end

//// apsModel示例
/*
 特殊说明：
 加载并处理附件时间上限为30秒，否则，通知按系统默认形式弹出；
 UNNotificationAttachment的url接收的是本地文件的url；
 mutable-content这个键值为1，说明此条推送可以被 Service Extension 进行更改。
 
 */

/**
 payload数据结构说明：
 aps中主要是系统内定keys，在远程推送中会自动映射成UNNotificationContent对象
 */

/**
 {"aps":{"alert":{"title":"通知的title","subtitle":"通知的subtitle","body":"通知的body","title-loc-key":"TITLE_LOC_KEY","title-loc-args":["t_01","t_02"],"loc-key":"LOC_KEY","loc-args":["l_01","l_02"]},"sound":"sound01.wav","badge":1,"mutable-content":1,"category": "InviteCategoryIdentifier"},"msgid":"123"}
 */

/**
 {"aps":{"alert":{"title":"Title...","subtitle":"Subtitle...","body":"Body..."},"sound":"default","badge": 1,"mutable-content": 1,"category": "InviteCategoryIdentifier"},"msgid":"123","media":{"type":"image","url":"https://www.fotor.com/images2/features/photo_effects/e_bw.jpg"}}
 */
