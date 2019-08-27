//
//  PushManager.m
//  OnepushNotification
//
//  Created by GJS on 2019/3/11.
//  Copyright © 2019 GJS. All rights reserved.
//

#import "PushManager.h"
#import "JPushManager.h"

#if __has_include(<UserNotifications/UserNotifications.h>)
#import <UserNotifications/UserNotifications.h>
#endif

@interface PushManager ()

@end

@implementation PushManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [JPushManager sharedManager].notificationHandler = ^(NSDictionary * _Nonnull userInfo, NSString * _Nonnull eventType) {
            // 和 Android 统一
            NSDictionary *data = @{@"name": eventType, @"data": userInfo};
            [self postMessageNotif:data messageType:eventType];
        };
    }
    return self;
}

- (void)dealloc {
    
}

RCT_EXPORT_MODULE();

#pragma mark - constants to export

- (NSDictionary *)constantsToExport
{
    return [[JPushManager sharedManager] constantsToExport];
}

#pragma mark - supported events

- (NSArray<NSString *> *)supportedEvents
{
    return [[JPushManager sharedManager] supportedEvents];
}

#pragma mark - Lifecycle

- (void)startObserving
{
    
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- export method to js

/**
 注册远程推送
 
 @param NSDictionary options
 */
RCT_EXPORT_METHOD(registerPush){
    //  | JIGUANG | W - [JIGUANGService] 请将JPush的初始化方法，添加到[UIApplication application: didFinishLaunchingWithOptions:]方法中，否则JPush将不能准确的统计到通知的点击数量。参考文档：https://docs.jiguang.cn/jpush/client/iOS/ios_guide_new/#_6
    // 必须在 didFinishLaunchingWithOptions 方法中初始化
    // 极光推送SDK 在 react-native 项目中似乎怎么弄都会打印这个log。。
    // 因为有解绑和绑定的业务需求，这里放在登录后调用该方法时初始化极光推送
    
    //初始化极光推送
    //初始化 APNs 代码
    [[JPushManager sharedManager] registerPush];
    //初始化 JPush 代码
    [[JPushManager sharedManager] setupJpush];
    [[JPushManager sharedManager] registrationIDCompletionHandler:nil];
}

/**
 注销远程推送
 
 @param NSDictionary options
 */
RCT_EXPORT_METHOD(unregisterPush){
    //详解极光推送的 4 种消息形式—— iOS 篇
    //https://community.jiguang.cn/t/topic/11243
    
    //APNs 通知的几个特点
    
    //7.JPush 无法控制 APNs 通知的展示与否，不过如果你想实现关闭 APNs 通知，有如下方法：
    //一般是给一个文字说明：请在手机[设置]-[通知]-[XX App]选择打开或关闭通知；
    //也可以调用反注册代码
    //[[UIApplication sharedApplication] unregisterForRemoteNotifications]；进行关闭。或者
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]// iOS 8 以上用此方法可以进入应用设置页面使用户可以手动变更是否允许通知的设置。不手动操作不会直接关掉推送
    //但有一个影响是：iOS9 设备使用代码反注册 APNs ，再调用代码注册 APNs ，需要杀死应用后，再重新开启应用才会有 APNs 提示（这里可能与系统本身 bug 有关）。
    //也可以用 Android 篇 42的置空别名的方法
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

RCT_EXPORT_METHOD(areNotificationsEnabled:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [self isUserNotificationEnable:^(BOOL enabled) {
        if (resolve) {
            resolve(@(enabled));
        }
    }];
}

RCT_EXPORT_METHOD(startNotificationSettings)
{
    [self goToAppSystemSetting];
}

/**
 * 从通知启动App，临时存储的数据
 */
RCT_EXPORT_METHOD(getCacheMessage) {
    [[JPushManager sharedManager] postCachedMessageTriggeredLaunch];
}

#pragma mark - Utils

- (void)postMessageNotif:(NSDictionary *)data messageType:(NSString *)type{
    
#if __has_include(<React/RCTEventEmitter.h>)
    if (self.bridge) {
        [self sendEventWithName:type body:data];
    }
#else
    if (self.bridge) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:type
                                                        body:data];
    }
#endif
    
}

/*
- (BOOL)isUserNotificationEnable { // 判断用户是否允许接收通知
    BOOL isEnable = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) { // iOS版本 >=8.0 处理逻辑
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        isEnable = (UIUserNotificationTypeNone == setting.types) ? NO : YES;
    } else { // iOS版本 <8.0 处理逻辑
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        isEnable = (UIRemoteNotificationTypeNone == type) ? NO : YES;
    }
    return isEnable;
}
*/

- (void)isUserNotificationEnable:(void (^)(BOOL))block { // 判断用户是否允许接收通知
    BOOL __block isEnable = NO;
    
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                // 用户未授权通知
            }else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                isEnable = YES;
            }
            RCTExecuteOnMainQueue(^{
                block(isEnable);
            });
        }];
    } else {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIRemoteNotificationTypeNone) {
        }else {
            isEnable = YES;
        }
        RCTExecuteOnMainQueue(^{
            block(isEnable);
        });
    }
}

// 如果用户关闭了接收通知功能，该方法可以跳转到APP设置页面进行修改  iOS版本 >=8.0 处理逻辑
- (void)goToAppSystemSetting {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([application canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [application openURL:url options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [application openURL:url];
        }
    }
}

#pragma mark - Handlers

+ (void)didRegisterUserNotificationSettings:(__unused UIUserNotificationSettings *)notificationSettings
{
    [JPushManager didRegisterUserNotificationSettings:notificationSettings];
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPushManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)notification
{
    [JPushManager didReceiveRemoteNotification:notification];
}

+ (void)didReceiveNotificationResponse:(NSDictionary *)notification{
    
}

+ (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    [JPushManager didReceiveLocalNotification:notification];
}

@end
