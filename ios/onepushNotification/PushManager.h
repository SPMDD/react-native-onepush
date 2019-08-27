//
//  PushManager.h
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
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventEmitter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PushManager : RCTEventEmitter

+ (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
//收到远程推送消息
+ (void)didReceiveRemoteNotification:(NSDictionary *)notification;
//收到本地推送消息
+ (void)didReceiveLocalNotification:(UILocalNotification *)notification;
//用户点击消息回送事件
//+ (void)didReceiveNotificationResponse:(NSDictionary *)notification;

@end

NS_ASSUME_NONNULL_END
