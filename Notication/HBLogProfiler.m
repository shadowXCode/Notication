//
//  HBLogProfiler.m
//  Notication
//
//  Created by Walker on 2019/4/15.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import "HBLogProfiler.h"

@implementation HBLogProfiler

+ (void)saveText:(NSString *)text fileName:(NSString *)fileName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:[self notificationDirectoryName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",fileName]];
    BOOL res = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    if (!res) {
        return;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [handle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}


+ (void)clearedNotificationDirectory {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:[self notificationDirectoryName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
        if (error) {
            NSString *errorLog = [NSString stringWithFormat:@"%@ : %@",NSStringFromSelector(_cmd),error.localizedDescription];
            [HBOAAlertView alertMessage:errorLog];
        } else {
            [HBOAAlertView alertMessage:@"已清除沙盒日志"];
        }
    } else {
        [HBOAAlertView alertMessage:@"目录不存在"];
    }
}

+ (NSString *)notificationDirectoryName {
    return @"NotificationLogs";
}


@end
