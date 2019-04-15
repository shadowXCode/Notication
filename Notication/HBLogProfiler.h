//
//  HBLogProfiler.h
//  Notication
//
//  Created by Walker on 2019/4/15.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBLogProfiler : NSObject

+ (void)saveText:(NSString *)text fileName:(NSString *)fileName;

+ (void)clearedNotificationDirectory;

@end

NS_ASSUME_NONNULL_END
