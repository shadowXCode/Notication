//
//  HBOAAlertView.h
//  HBOpenAccountDemo
//
//  Created by Walker on 2017/1/4.
//  Copyright © 2017年 Touker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBOAAlertView : UIView
/**
 默认延迟是1.5s
 */
+ (instancetype)alertViewWithSuperView:(UIView *)superView message:(NSString *)message;

+ (instancetype)alertViewWithSuperView:(UIView *)superView message:(NSString *)message delay:(CGFloat)delay;
/**
 在当前程序window上弹出提示
 */
+ (instancetype)alertMessage:(NSString *)message;

+ (instancetype)alertMessage:(NSString *)message delay:(CGFloat)delay;

@end

@interface HBOAProgressHUD : UIView

+ (instancetype)showHUDAddedTo:(UIView *)view message:(NSString *)message;

+ (BOOL)hideHUDForView:(UIView *)view;

+ (NSUInteger)hideAllHUDsForView:(UIView *)view;

@end
