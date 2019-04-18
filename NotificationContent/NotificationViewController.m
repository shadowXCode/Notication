//
//  NotificationViewController.m
//  NotificationContent
//
//  Created by Walker on 2019/4/16.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

/**
 收到通知，填充页面信息。可以调整整个页面高度，忽略宽度。
 */
- (void)didReceiveNotification:(UNNotification *)notification {
    //提取附件
    UNNotificationAttachment *attachment = notification.request.content.attachments.firstObject;
    //startAccessingSecurityScopedResource 表示在应用程序沙盒中url可以安全的指向资源文件
    if ([attachment.URL startAccessingSecurityScopedResource]) {
        NSData *imageData = [NSData dataWithContentsOfURL:attachment.URL];
        UIImage *image = [UIImage imageWithData:imageData];
        
        CGSize size = self.view.bounds.size;
        CGFloat height = (size.width / image.size.width) * image.size.height;
        self.preferredContentSize = CGSizeMake(size.width, height);//viewController的view首选大小进行设置
        
        [self.imageView setImage:[UIImage imageWithData:imageData]];
        //stopAccessingSecurityScopedResource 停止应用程序沙盒内rul安全资源访问
        [attachment.URL stopAccessingSecurityScopedResource];
    } else {
        //当附件没有下载成功导致不存在时，调整展示大小
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 0.1);
    }
}

/**
 在content extension中响应action时也可以进行网络请求，来处理部分业务。因为每个扩展都相当于一个独立app，只是依附于主app上共用同一个沙盒，所以在info.plist中开启App Transport Security Settings --> Allow Arbitrary Loads == YES 也是有一定必要。
 */
- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion;{

    if ([response.actionIdentifier isEqualToString:@"ActionA"]) {
//        [self loadAttachmentForUrlString:@"http://www.fotor.com/images2/features/photo_effects/e_bw.jpg" completionHandler:^{
//
//        }];
        completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
    } else if ([response.actionIdentifier isEqualToString:@"ActionB"]) {
        completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
    } else if ([response.actionIdentifier isEqualToString:@"InputAction"]) {
//        UNTextInputNotificationResponse *textInputResponse = (UNTextInputNotificationResponse *)response;
        completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
    } else if ([response.actionIdentifier isEqualToString:@"CancelAction"]) {
        completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
    }
//    completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);//移除通知弹框，并且执行事件（会唤醒app执行事件，会传递UNTextInputNotificationResponse）
    //    completion(UNNotificationContentExtensionResponseOptionDismiss);//移除通知弹框，不做任何操作（不会唤醒app执行事件）
    //    completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);//不做任何操作（关闭通知时会唤醒app执行事件，不会传递UNTextInputNotificationResponse；哪怕对应action的options设定为UNNotificationActionOptionForeground也不会响应）
}


- (void)loadAttachmentForUrlString:(NSString *)urlStr completionHandler:(void (^)(void))compeltionHandler {
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"加载多媒体失败 %@", error.localizedDescription);
        } else {
            NSLog(@"加载多媒体成功");
        }
        compeltionHandler();
    }] resume];
}


@end


