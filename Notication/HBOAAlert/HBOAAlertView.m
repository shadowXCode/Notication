//
//  HBOAAlertView.m
//  HBOpenAccountDemo
//
//  Created by Walker on 2017/1/4.
//  Copyright © 2017年 Touker. All rights reserved.
//

#import "HBOAAlertView.h"

@interface HBOAAlertManager : NSObject

@end

@implementation HBOAAlertManager

+ (id)generateAlertView {
    return [[NSBundle mainBundle] loadNibNamed:@"HBOAAlertView" owner:nil options:nil][0];
}

+ (id)generateProgressHUD {
    return [[NSBundle mainBundle] loadNibNamed:@"HBOAAlertView" owner:nil options:nil][1];
}


@end


@interface HBOAAlertView()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (nonatomic) CGFloat delay;
@property (nonatomic, copy) dispatch_block_t nextAlertBlock;
@end

@implementation HBOAAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
    self.backView.layer.cornerRadius = 5.0f;
    self.backView.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat width = (screenSize.width - self.backView.bounds.size.width) < 16 ? screenSize.width - 16 : self.backView.bounds.size.width;
    self.bounds = CGRectMake(0, 0, width, CGRectGetHeight(self.backView.bounds));
}

+ (instancetype)alertViewWithSuperView:(UIView *)superView message:(NSString *)message delay:(CGFloat)delay {
    HBOAAlertView *alertView = (HBOAAlertView *)[HBOAAlertManager generateAlertView];
    alertView.frame = superView.bounds;
    alertView.messageLabel.text = message;
    alertView.delay = delay;
    [superView addSubview:alertView];
    [alertView show];
    return alertView;
}

+ (instancetype)alertViewWithSuperView:(UIView *)superView message:(NSString *)message {
    return [self alertViewWithSuperView:superView message:message delay:1.5];
}

+ (instancetype)alertMessage:(NSString *)message delay:(CGFloat)delay {
    return [HBOAAlertView alertViewWithSuperView:[UIApplication sharedApplication].keyWindow message:message delay:delay];
}

+ (instancetype)alertMessage:(NSString *)message; {
    return [self alertMessage:message delay:1.5];
}

+ (instancetype)viewWithParentView:(UIView *)parentView cur:(UIView *)cur {
    for (UIView *subView in [parentView subviews]) {
        if ([subView isKindOfClass:[HBOAAlertView class]]&&cur != subView) {
            return (HBOAAlertView *)subView;
        }
    }
    return nil;
}

- (void)show {
    __weak typeof(self)weakSelf = self;
    dispatch_block_t showBlock = ^{
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            weakSelf.alpha = 1;
            weakSelf.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            [weakSelf performSelector:@selector(hide:) withObject:@(YES) afterDelay:weakSelf.delay];
        }];
    };
    HBOAAlertView *lastAlertView = [HBOAAlertView viewWithParentView:self.superview cur:self];
    if (lastAlertView) {
        lastAlertView.nextAlertBlock = ^{
            showBlock();
        };
        [lastAlertView hide:@(NO)];
    } else {
        showBlock();
    }
}

- (void)hide:(NSNumber *)isAnimation {
    if (isAnimation.boolValue) {
        __weak typeof(self)weakSelf = self;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide:) object:nil];
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.alpha = 0;
            weakSelf.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            if (weakSelf.nextAlertBlock) {
                weakSelf.nextAlertBlock();
                weakSelf.nextAlertBlock = nil;
            }
            [weakSelf removeFromSuperview];
        }];
    } else {
        self.alpha = 0;
        if (self.nextAlertBlock) {
            self.nextAlertBlock();
            self.nextAlertBlock = nil;
        }
        [self removeFromSuperview];
    }
    
}

@end


@interface HBOAProgressHUD()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation HBOAProgressHUD

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.backView.layer.cornerRadius = 5.0f;
    self.backView.layer.masksToBounds = YES;
}

+ (instancetype)showHUDAddedTo:(UIView *)view message:(NSString *)message {
    HBOAProgressHUD *hud = [HBOAAlertManager generateProgressHUD];
    hud.frame = view.bounds;
    hud.backView.alpha = 0;
    hud.messageLabel.text = message;
    [view addSubview:hud];
    [hud show];
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view {
    HBOAProgressHUD *hud = [self HUDForView:view];
    if (hud != nil) {
        [hud hide];
    }
    return NO;
}

+ (NSUInteger)hideAllHUDsForView:(UIView *)view {
    NSArray *huds = [self allHUDsForView:view];
    for (HBOAProgressHUD *hud in huds) {
        [hud hide];
    }
    return [huds count];
}

+ (instancetype)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (HBOAProgressHUD *)subview;
        }
    }
    return nil;
}

+ (NSArray *)allHUDsForView:(UIView *)view {
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews = view.subviews;
    for (UIView *aView in subviews) {
        if ([aView isKindOfClass:self]) {
            [huds addObject:aView];
        }
    }
    return [NSArray arrayWithArray:huds];
}

- (void)show {
    self.backView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backView.alpha = 1;
        self.backView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
        self.backView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end







