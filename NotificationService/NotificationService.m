//
//  NotificationService.m
//  NotificationService
//
//  Created by Walker on 2019/4/16.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end


//多个NotificationCategories在info.plist中该如何配置????
@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"[modified]：%@", self.bestAttemptContent.title];
    
    //设置category 要保证注册的categorys中有self.bestAttemptContent.categoryIdentifier，远程推送过来payload数据会自动转换为UNNotificationContent对象
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:[NotificationService notificationCategoryExampleWithIdentifier:[NotificationService inviteCategoryIdentifier]]]];
    
    //当存在media资源时进行网络请求
    NSDictionary *userInfo = self.bestAttemptContent.userInfo;
    NSString *mediaUrl = userInfo[@"media"][@"url"];
    NSString *mediaType = userInfo[@"media"][@"type"];
    if (!mediaUrl.length) {
        self.contentHandler(self.bestAttemptContent);
    } else {
        [self loadAttachmentForUrlString:mediaUrl withType:mediaType completionHandle:^(UNNotificationAttachment *attach) {
            
            if (attach) {
                self.bestAttemptContent.attachments = [NSArray arrayWithObject:attach];
            }
            self.contentHandler(self.bestAttemptContent);
        }];
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}


#pragma mark - custom methods

- (void)loadAttachmentForUrlString:(NSString *)urlStr withType:(NSString *)type completionHandle:(void(^)(UNNotificationAttachment *attach))completionHandler {
    
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSString *fileExt = [self getfileExtWithMediaType:type];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"加载多媒体失败 %@", error.localizedDescription);
        } else {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
            
            // 自定义推送UI需要
            NSMutableDictionary * dict = [self.bestAttemptContent.userInfo mutableCopy];
            [dict setObject:[NSData dataWithContentsOfURL:localURL] forKey:@"image"];
            self.bestAttemptContent.userInfo = dict;
            
            NSError *attachmentError = nil;
            attachment = [UNNotificationAttachment attachmentWithIdentifier:[NotificationService inviteCategoryIdentifier]
                                                                        URL:localURL
                                                                    options:nil
                                                                      error:&attachmentError];
            if (attachmentError) {
                NSLog(@"%@", attachmentError.localizedDescription);
            }
        }
        completionHandler(attachment);
    }] resume];
}

- (NSString *)getfileExtWithMediaType:(NSString *)mediaType {
    NSString *fileExt = mediaType;
    if ([mediaType isEqualToString:@"image"]) {
        fileExt = @"jpg";
    }
    if ([mediaType isEqualToString:@"video"]) {
        fileExt = @"mp4";
    }
    if ([mediaType isEqualToString:@"audio"]) {
        fileExt = @"mp3";
    }
    return [@"." stringByAppendingString:fileExt];
}


+ (NSString *)inviteCategoryIdentifier {
    return @"InviteCategoryIdentifier";
}

+ (UNNotificationCategory *)notificationCategoryExampleWithIdentifier:(NSString *)identifier {
    //action中的标识符不可重复，哪怕不在同一个category下。每组category中的action最多不能超过4个
    
    UNNotificationAction *actionA = [UNNotificationAction actionWithIdentifier:@"actionA" title:@"接受邀请" options:UNNotificationActionOptionAuthenticationRequired];//UNNotificationActionOptionAuthenticationRequired 黑色文字，需要解锁显示，点击不会进app。
    
    UNNotificationAction *actionB = [UNNotificationAction actionWithIdentifier:@"actionB" title:@"查看邀请" options:UNNotificationActionOptionForeground];//UNNotificationActionOptionForeground 黑色文字。点击会进app。
    
    UNTextInputNotificationAction *inputAction = [UNTextInputNotificationAction actionWithIdentifier:@"inputAction" title:@"回复" options:UNNotificationActionOptionAuthenticationRequired textInputButtonTitle:@"发送" textInputPlaceholder:@"input some words here ..."];
    
    UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"cancelAction" title:@"取消" options:UNNotificationActionOptionDestructive];//UNNotificationActionOptionDestructive 红色文字。点击不会进app。
    
    /**
     + (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<UNNotificationAction *> *)actions intentIdentifiers:(NSArray<NSString *> *)intentIdentifiers options:(UNNotificationCategoryOptions)options;
     方法中：
     identifier 标识符是这个category的唯一标识，用来区分多个category。要与推送的设定的categoryid保持一致
     actions 是你创建action的操作数组
     intentIdentifiers 意图标识符 可在SiriKit中 <Intents/INIntentIdentifiers.h> 中查看，主要是针对电话、carplay 等开放的 API
     options 通知选项 枚举类型 也是为了支持 carplay
     
     UNNotificationCategoryOptions各种类型下含义
     UNNotificationCategoryOptionCustomDismissAction 是否在action执行完后回调UNUserNotificationCenterDelegate
     UNNotificationCategoryOptionAllowInCarPlay 是否允许在CarPlay中进行此类通知
     UNNotificationCategoryOptionHiddenPreviewsShowTitle    如果用户已关闭预览，是否显示标题
     UNNotificationCategoryOptionHiddenPreviewsShowSubtitle 如果用户已关闭预览，是否显示副标题
     */
    UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:identifier actions:@[actionA,actionB,inputAction,cancelAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    return notificationCategory;
}


@end
