//
//  AppDelegate.h
//  Notication
//
//  Created by Walker on 2019/4/11.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 iOS远程推送
 1、远程推送原理，推送证书配置的两种方式
 2、远程推送注册、接收远程推送，代码解读（iOS8以上）
 3、如何进行后台静默推送，干一些事情
 4、推送扩展的作用
 5、远程推送数据结构解读
 6、本地推送
 7、查漏补缺，探讨推送
 8、接入极光推送，第二种证书使用
*/

/**
 推送的json数据以下简称payload
 发送一个远程推送到用户设备通过payload传递信息，推送类型有alert、sound、badge、silent四种均通过payload数据进行控制。
 如果payload数据大小超过4k，则不会进行推送。
 payload数据结构中除了苹果定义的keys，开发者可以自定义keys，自定义的keys在UNNotificationContent中userInfo属性中。
 sound字段中的音频文件必须是在设备中已存在的或者app的bundle中存在的。
 避免在推送payload中放入一些敏感字段，防止信息泄露；如果迫不得已，需要对该信息进行加密。
 官方已定义keys可参考文档有：https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification
 
 关于silent推送：
 APNS去掉alert、badge、sound字段实现静默推送，增加增加字段"content-available":1，也可以在后台做一些事情。
 
 
 本地推送和远程推送同时都可支持附带Media Attachments。不过远程通知需要实现通知服务扩展UNNotificationServiceExtension，在service extension里面去下载attachment，但是需要注意，service extension会限制下载的时间（30s），并且下载的文件大小也会同样被限制
 关于Media Attachments限制可参考：https://developer.apple.com/documentation/usernotifications/unnotificationattachment?preferredLanguage=occ
 

 1、怎么设置进行通知栏消息合并、分组，有哪些限制？
 iOS12才能进行通知分组，在通知设置页面可以进行设定。在自动模式下会按照UNMutableNotificationContent中的threadIdentifier进行分组
 2、为何debug模式下远程推送侧滑没有管理按钮？
 iOS12新特性
 */

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end
NS_ASSUME_NONNULL_END

