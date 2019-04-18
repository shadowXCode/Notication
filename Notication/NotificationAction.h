//
//  NotificationAction.h
//  Notication
//
//  Created by Walker on 2019/4/18.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const Invite_Dely_locationCategoryIdentifier;

@interface NotificationAction : NSObject

+ (void)addInviteNotificationAction API_AVAILABLE(ios(10.0));

@end

NS_ASSUME_NONNULL_END
