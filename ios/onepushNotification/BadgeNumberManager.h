//
//  BadgeNumberManager.h
//  OnepushNotification
//
//  Created by GJS on 2019/3/11.
//  Copyright © 2019 GJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#else
#import "RCTBridgeModule.h"
#import "RCTBridge.h"
#import "RCTConvert.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BadgeNumberManager : NSObject <RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
