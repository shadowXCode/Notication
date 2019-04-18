//
//  HBOAReachability.m
//  HBOpenAccountDemo
//
//  Created by Walker on 2017/1/5.
//  Copyright © 2017年 Touker. All rights reserved.
//

#import "HBOAReachability.h"
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString * const HBOANetworkingReachabilityDidChangeNotification = @"com.HBOpenAccount.networking.reachability.change";
NSString * const HBOANetworkingReachabilityNotificationStatusItem = @"HBOANetworkingReachabilityNotificationStatusItem";

typedef void (^HBOANetworkReachabilityStatusBlock)(HBOANetworkStatus status);

NSString * HBOAStringFromNetworkReachabilityStatus(HBOANetworkStatus status) {
    switch (status) {
        case kHBOAConnectToWifi:
            return @"WIFI";
        case kHBOAConnectTo4G:
            return @"4G";
        case kHBOAConnectTo3G:
            return @"3G";
        case kHBOAConnectTo2G:
            return @"2G";
        case kHBOAConnectToWWAN:
        {
            return @"WWAN";
        }
        default:
            return @"NONE";
    }
}

static HBOANetworkStatus HBOANetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    HBOANetworkStatus status = kHBOAConnectToUnknown;
    if (isNetworkReachable == NO) {
        status = kHBOAConnectToNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                   CTRadioAccessTechnologyGPRS,
                                   CTRadioAccessTechnologyCDMA1x];
        
        NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                   CTRadioAccessTechnologyWCDMA,
                                   CTRadioAccessTechnologyHSUPA,
                                   CTRadioAccessTechnologyCDMAEVDORev0,
                                   CTRadioAccessTechnologyCDMAEVDORevA,
                                   CTRadioAccessTechnologyCDMAEVDORevB,
                                   CTRadioAccessTechnologyeHRPD];
        
        NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
        CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
        NSString *accessString = teleInfo.currentRadioAccessTechnology;
        if ([typeStrings4G containsObject:accessString]) {
            status = kHBOAConnectTo4G;
        } else if ([typeStrings3G containsObject:accessString]) {
            status = kHBOAConnectTo3G;
        } else if ([typeStrings2G containsObject:accessString]) {
            status = kHBOAConnectTo2G;
        } else {
            status = kHBOAConnectToWWAN;
        }
    }
#endif
    else {
        status = kHBOAConnectToWifi;
    }
    
    return status;
}

static void HBOAPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, HBOANetworkReachabilityStatusBlock block) {
    HBOANetworkStatus status = HBOANetworkReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ HBOANetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:HBOANetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static void HBOANetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    HBOAPostReachabilityStatusChange(flags, (__bridge HBOANetworkReachabilityStatusBlock)info);
}

static const void * HBOANetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void HBOANetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface HBOAReachability()
@property (readwrite, nonatomic, assign) HBOANetworkStatus currentNetStatus;
@property (readwrite, nonatomic, copy) HBOANetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@end

@implementation HBOAReachability

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static HBOAReachability *_reachability = nil;
    dispatch_once(&once, ^{
        _reachability = [self manager];
    });
    return _reachability;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }

    _networkReachability = CFRetain(reachability);
    self.currentNetStatus = kHBOAConnectToUnknown;
    
    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

+ (instancetype)manager
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    HBOAReachability *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    HBOAReachability *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

- (void)startMonitoring {
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    HBOANetworkReachabilityStatusBlock callback = ^(HBOANetworkStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.currentNetStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
    };
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, HBOANetworkReachabilityRetainCallback, HBOANetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, HBOANetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            HBOAPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

- (NSString *)localizedNetworkReachabilityStatusString {
    return HBOAStringFromNetworkReachabilityStatus(self.currentNetStatus);
}

- (void)setReachabilityStatusChangeBlock:(void (^)(HBOANetworkStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

@end
