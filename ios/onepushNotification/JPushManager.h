//
//  PushManager.h
//  OnepushNotification
//
//  Created by GJS on 2019/3/11.
//  Copyright © 2019 GJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPushManager : NSObject

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, assign) BOOL isProduction;
@property (nonatomic, copy) NSDictionary *launchOptions;
@property (nonatomic, assign, readonly) BOOL isHandledLaunchTrigger;
@property (nonatomic, copy, readonly) NSString *pushToken;
@property (nonatomic, copy) NSString *baseAPI;

@property (nonatomic, copy) void (^notificationHandler)(NSDictionary *userInfo, NSString *eventType);


- (void)setupJpushWithOption:(NSDictionary *)launchingOption
                      appKey:(NSString *)appKey
                     channel:(NSString *)channel
            apsForProduction:(BOOL)isProduction;
- (void)setupJpush;
- (void)registerPush;
- (void)registrationIDCompletionHandler:(void(^ _Nullable )(int resCode,NSString *registrationID))completionHandler;
- (NSDictionary *)constantsToExport;
- (NSArray<NSString *> *)supportedEvents;
- (void)postCachedMessageTriggeredLaunch;

+ (instancetype)sharedManager;

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
