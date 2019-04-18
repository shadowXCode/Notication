//
//  HBOAReachability.h
//  HBOpenAccountDemo
//
//  Created by Walker on 2017/1/5.
//  Copyright © 2017年 Touker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>



/**
 网络状态

 - kHBOAConnectToUnknown: 未知
 - kHBOAConnectToNotReachable: 无网络
 - kHBOAConnectToWWAN: 蜂窝网络
 - kHBOAConnectTo2G: 2G
 - kHBOAConnectTo3G: 3G
 - kHBOAConnectTo4G: 4G
 - kHBOAConnectToWifi: Wifi
 */
typedef NS_ENUM(NSUInteger,HBOANetworkStatus) {
    kHBOAConnectToUnknown = -1,
    kHBOAConnectToNotReachable = 0,
    kHBOAConnectToWWAN = 1,
    kHBOAConnectTo2G = 2,
    kHBOAConnectTo3G = 3,
    kHBOAConnectTo4G = 4,
    kHBOAConnectToWifi = 5,
};

NS_ASSUME_NONNULL_BEGIN

@interface HBOAReachability : NSObject

+ (instancetype)sharedInstance;

@property (readonly, nonatomic, assign) HBOANetworkStatus currentNetStatus;

/**
 Creates and returns a network reachability manager with the default socket address.
 
 @return An initialized network reachability manager, actively monitoring the default socket address.
 */
+ (instancetype)manager;

/**
 Creates and returns a network reachability manager for the specified domain.
 
 @param domain The domain used to evaluate network reachability.
 
 @return An initialized network reachability manager, actively monitoring the specified domain.
 */
+ (instancetype)managerForDomain:(NSString *)domain;

/**
 Creates and returns a network reachability manager for the socket address.
 
 @param address The socket address (`sockaddr_in6`) used to evaluate network reachability.
 
 @return An initialized network reachability manager, actively monitoring the specified socket address.
 */
+ (instancetype)managerForAddress:(const void *)address;

/**
 Initializes an instance of a network reachability manager from the specified reachability object.
 
 @param reachability The reachability object to monitor.
 
 @return An initialized network reachability manager, actively monitoring the specified reachability.
 */
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

///--------------------------------------------------
/// @name Starting & Stopping Reachability Monitoring
///--------------------------------------------------

/**
 Starts monitoring for changes in network reachability status.
 */
- (void)startMonitoring;

/**
 Stops monitoring for changes in network reachability status.
 */
- (void)stopMonitoring;

///-------------------------------------------------
/// @name Getting Localized Reachability Description
///-------------------------------------------------

/**
 Returns a localized string representation of the current network reachability status.
 */
- (NSString *)localizedNetworkReachabilityStatusString;

///---------------------------------------------------
/// @name Setting Network Reachability Change Callback
///---------------------------------------------------

/**
 Sets a callback to be executed when the network availability of the `baseURL` host changes.
 
 @param block A block object to be executed when the network availability of the `baseURL` host changes.. This block has no return value and takes a single argument which represents the various reachability states from the device to the `baseURL`.
 */
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(HBOANetworkStatus status))block;

@end

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when network reachability changes.
 This notification assigns no notification object. The `userInfo` dictionary contains an `NSNumber` object under the `HBOANetworkingReachabilityNotificationStatusItem` key, representing the `HBOANetworkStatus` value for the current network reachability.
 
 @warning In order for network reachability to be monitored, include the `SystemConfiguration` framework in the active target's "Link Binary With Library" build phase, and add `#import <SystemConfiguration/SystemConfiguration.h>` to the header prefix of the project (`Prefix.pch`).
 */
FOUNDATION_EXPORT NSString * const HBOANetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const HBOANetworkingReachabilityNotificationStatusItem;

NS_ASSUME_NONNULL_END
