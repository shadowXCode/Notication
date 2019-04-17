//
//  NotificationViewController.h
//  NotificationContent
//
//  Created by Walker on 2019/4/16.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController

@end

/**
 
 info.plist中NSExtension各种key含义
 更多信息可参考官方文档：https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html
 
 NSExtensionAttributes中keys：
 UNNotificationExtensionCategory：对应这个key的值，可以是一个字符串，也可以是一个数组。要和设置的UNNotificationCategory中的identifiery或UNMutableNotificationContent中的categoryIdentifier保持一致。
 UNNoficicationExtensionInitialContentSizeRatio：当用户展开通知时，content extension可能没能立刻加载完成，在这段短暂的时间内，界面应该有多高，就依靠这个字段来指定。
  UNNotificationExtensionDefaultContentHidden：把这个字段设为YES，那么当用户展开一个通知时，上下的通知界面就能被隐藏。可选参数
 UNNotificationExtensionOverridesDefaultTitle：是否让系统采用消息的标题作为通知的标题，可选参数。
 
 NSExtensionMainStoryboard：通过storyboard加载页面，通常value为storyboard的名称，默认为：MainInterface
 NSExtensionPrincipalClass：如果不通过storyboard加载页面，需要设定该值为当前加载ViewController的名称。与NSExtensionMainStoryboard属于二选一设定。
 NSExtensionPointIdentifier：标示key，默认创建，不需要改动。
 
 
 payload数据结构aps中通过category指定调用分类
 
 
 app扩展执行时，并不是代表唤醒了app，仅仅执行该扩展逻辑。当扩展需要用到app内部分功能时，最好通过封装动态库调用。
 */
