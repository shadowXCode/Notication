//
//  MoLocationManager.h
//  Notication
//
//  Created by Walker on 2019/4/18.
//  Copyright © 2019 ershuai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MoLocationSuccess) (double lat, double lng);
typedef void(^MoLocationFailed) (NSError *error);

@interface MoLocationManager : NSObject<CLLocationManagerDelegate>

+ (MoLocationManager *) sharedGpsManager;

+ (void) getMoLocationWithSuccess:(MoLocationSuccess)success Failure:(MoLocationFailed)failure;

+ (void) stop;

@end

NS_ASSUME_NONNULL_END
