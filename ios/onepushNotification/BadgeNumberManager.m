//
//  BadgeNumberManager.m
//  OnepushNotification
//
//  Created by GJS on 2019/3/11.
//  Copyright © 2019 GJS. All rights reserved.
//

#import "BadgeNumberManager.h"
#import "JPUSHService.h"

@implementation BadgeNumberManager

RCT_EXPORT_MODULE();

#pragma mark -- export method to js

/**
 * Update the application icon badge number on the home screen
 */
RCT_EXPORT_METHOD(setApplicationIconBadgeNumber:(NSInteger)number)
{
    [JPUSHService setBadge:number];
    RCTSharedApplication().applicationIconBadgeNumber = number;
}

/**
 * Get the current application icon badge number on the home screen
 */
//RCT_EXPORT_METHOD(getApplicationIconBadgeNumber:(RCTResponseSenderBlock)callback)
//{
//    callback(@[@(RCTSharedApplication().applicationIconBadgeNumber)]);
//}
RCT_EXPORT_METHOD(getApplicationIconBadgeNumber:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (resolve) {
        resolve(@(RCTSharedApplication().applicationIconBadgeNumber));
    }
}

@end
