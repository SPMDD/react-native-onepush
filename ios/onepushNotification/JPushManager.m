//
//  PushManager.m
//  OnepushNotification
//
//  Created by GJS on 2019/3/11.
//  Copyright © 2019 GJS. All rights reserved.
//

#import "JPushManager.h"
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define kCachePushMessageTriggeredLaunch @"kCachePushMessageTriggeredLaunch"

NSString *const PUSH_TOKEN = @"PUSH_TOKEN";
NSString *const RECEIVE_NOTIFICATION = @"RECEIVE_NOTIFICATION";
NSString *const RECEIVE_NOTIFICATION_CLICK = @"RECEIVE_NOTIFICATION_CLICK";
NSString *const RECEIVE_MESSAGE = @"RECEIVE_MESSAGE";

@interface JPushManager () <JPUSHRegisterDelegate,JPUSHGeofenceDelegate>

@property (nonatomic, copy, readwrite) NSString *pushToken;
@property (nonatomic, assign, readwrite) BOOL isHandledLaunchTrigger;

@end

@implementation JPushManager

+ (instancetype)sharedManager {
    static JPushManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[JPushManager alloc] init];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(networkDidSetup:)
                              name:kJPFNetworkDidSetupNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(networkDidClose:)
                              name:kJPFNetworkDidCloseNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(networkDidRegister:)
                              name:kJPFNetworkDidRegisterNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(networkDidLogin:)
                              name:kJPFNetworkDidLoginNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(networkDidReceiveMessage:)
                              name:kJPFNetworkDidReceiveMessageNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(serviceError:)
                              name:kJPFServiceErrorNotification
                            object:nil];
    }
    return self;
}

- (void)dealloc {
    [self unObserveAllNotifications];
}

- (void)unObserveAllNotifications {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidSetupNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidCloseNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidRegisterNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidLoginNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidReceiveMessageNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:kJPFServiceErrorNotification
                           object:nil];
}

#pragma mark - constants to export

- (NSDictionary *)constantsToExport
{
    return @{PUSH_TOKEN: PUSH_TOKEN,
             RECEIVE_NOTIFICATION: RECEIVE_NOTIFICATION,
             RECEIVE_NOTIFICATION_CLICK: RECEIVE_NOTIFICATION_CLICK,
             RECEIVE_MESSAGE: RECEIVE_MESSAGE,};
}

#pragma mark - supported events

- (NSArray<NSString *> *)supportedEvents
{
    return @[PUSH_TOKEN,
             RECEIVE_NOTIFICATION,
             RECEIVE_NOTIFICATION_CLICK,
             RECEIVE_MESSAGE,];
}

#pragma mark - 极光推送

//  | JIGUANG | W - [JIGUANGService] 请将JPush的初始化方法，添加到[UIApplication application: didFinishLaunchingWithOptions:]方法中，否则JPush将不能准确的统计到通知的点击数量。参考文档：https://docs.jiguang.cn/jpush/client/iOS/ios_guide_new/#_6

//添加初始化 APNs 代码
//请将以下代码添加到 -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
- (void)setupJpushWithOption:(NSDictionary *)launchingOption
                      appKey:(NSString *)appKey
                     channel:(NSString *)channel
            apsForProduction:(BOOL)isProduction {
    // Override point for customization after application launch.
    self.launchOptions = launchingOption;
    self.appKey = appKey;
    self.channel = channel;
    self.isProduction = isProduction;
    
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // 此接口必须在 App 启动时调用, 否则 JPush SDK 将无法正常工作.
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:self.launchOptions appKey:self.appKey
                          channel:self.channel
                 apsForProduction:self.isProduction
            advertisingIdentifier:advertisingId];
}

- (void)setupJpush {
    [self setupJpushWithOption:self.launchOptions appKey:self.appKey channel:self.channel apsForProduction:self.isProduction];
}

//添加初始化 JPush 代码
//请将以下代码添加到 -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
- (void)registerPush {
    
    // 3.0.0及以后版本注册
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        //    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //      NSSet<UNNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
        //    else {
        //      NSSet<UIUserNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    //注册地理围栏的代理
    //[JPUSHService registerLbsGeofenceDelegate:self withLaunchOptions:self.launchOptions];
}

- (void)registrationIDCompletionHandler:(void(^)(int resCode,NSString *registrationID))completionHandler {
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
            if (registrationID) {
                // 通知js
                [self postMessageNotif:@{@"pushToken": registrationID, @"pushChannel": @"jpush"} messageType:PUSH_TOKEN];
            }
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
        
        // 回调
        if (completionHandler) {
            completionHandler(resCode, registrationID);
        }
    }];
}

//与极光服务端建立长连接
- (void)networkDidSetup:(NSNotification *)notification {
    NSLog(@"已连接");
}

//长连接关闭
- (void)networkDidClose:(NSNotification *)notification {
    NSLog(@"未连接");
}

//注册成功
- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"%@", [notification userInfo]);
    NSLog(@"已注册");
}

//登录成功
- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
}

//客户端收到自定义消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSUInteger messageID = [[userInfo valueForKey:@"_j_msgid"] unsignedIntegerValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\nmessage:%ld\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, [self logDic:extra],(unsigned long)messageID];
    NSLog(@"%@", currentContent);
    
    NSLog(@"%@", [self logDic:extra]);
    
    // 通知js
    [self postMessageNotif:userInfo messageType:RECEIVE_MESSAGE];
}

- (void)serviceError:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *error = [userInfo valueForKey:@"error"];
    NSLog(@"%@", error);
}

#pragma mark - Utils

- (void)postMessageNotif:(NSDictionary *)data messageType:(NSString *)type{
    
    if (self.notificationHandler) {
        self.notificationHandler(data, type);
    }
    
}

- (void)postCachedMessageTriggeredLaunch {
    NSData *userInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:kCachePushMessageTriggeredLaunch];
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:userInfoData options:NSJSONReadingMutableLeaves error:nil];
    if (userInfo) {
        // 通知js
        [self postMessageNotif:userInfo messageType:RECEIVE_NOTIFICATION_CLICK];
        // 清除缓存
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachePushMessageTriggeredLaunch];
    }
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

#pragma mark - Handlers

+ (void)didRegisterUserNotificationSettings:(__unused UIUserNotificationSettings *)notificationSettings
{
    if ([UIApplication instancesRespondToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSMutableString *hexString = [NSMutableString string];
//    NSUInteger deviceTokenLength = deviceToken.length;
//    const unsigned char *bytes = deviceToken.bytes;
//    for (NSUInteger i = 0; i < deviceTokenLength; i++) {
//        [hexString appendFormat:@"%02x", bytes[i]];
//    }
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)notification
{
    [JPUSHService handleRemoteNotification:notification];
}

+ (void)didReceiveNotificationResponse:(NSDictionary *)notification{
    [[self sharedManager] handleDidReceiveNotificationResponse:notification];
}

+ (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    //本地通知，iOS10以下还可继续使用，iOS10以上在[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:]方法中调用completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);即可
    //[JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

- (void)handleLocalNotificationReceived:(UILocalNotification *)notification
{
    
}

- (void)handleRemoteNotificationReceived:(NSNotification *)notification
{
    /*{
     ac = Action;
     aps =     {
     alert = title;
     badge = 0;
     sound = default;
     };
     pa = "www.baidu.com";
     }
     */
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"remote"] = @YES;
    NSDictionary *remoteDic = notification.userInfo;
    
    NSString *messageID = [remoteDic objectForKey:@"un"];
    if(messageID){
        [userInfo setObject:messageID forKey:@"id"];
    }
    NSDictionary *aps = [remoteDic objectForKey:@"aps"];
    NSString *strAction = [remoteDic objectForKey:@"ac"];
    NSString *strParams = [remoteDic objectForKey:@"pa"];
    
    
    if(strAction || strParams){
        [userInfo setObject:strAction forKey:@"action"];
        if(strParams){
            [userInfo setObject:strParams forKey:@"params"];
        }else{
            [userInfo setObject:[NSNull null] forKey:@"params"];
        }
        [userInfo setObject:[aps objectForKey:@"alert"] forKey:@"title"];
        [userInfo setObject:[aps objectForKey:@"badge"] forKey:@"badge"];
        NSString *strContent = [remoteDic objectForKey:@"con"];
        if(strContent){
            [userInfo setObject:strContent forKey:@"content"];
            strContent =nil;
        }
    }else{
        [userInfo setDictionary:remoteDic];
    }
    
}

- (NSDictionary *)handleDidReceiveNotificationResponse:(NSDictionary *)notification{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"remote"] = @YES;
    //NSDictionary *remoteDic = notification.userInfo;
    NSDictionary *remoteDic = notification;
    NSDictionary *aps = [remoteDic objectForKey:@"aps"];
    NSString *strAction = [remoteDic objectForKey:@"ac"];
    NSString *strParams = [remoteDic objectForKey:@"pa"];
    
    if(strAction || strParams){
        [userInfo setObject:strAction forKey:@"action"];
        if(strParams){
            [userInfo setObject:strParams forKey:@"params"];
        }else{
            [userInfo setObject:[NSNull null] forKey:@"params"];
        }
        [userInfo setObject:[aps objectForKey:@"alert"] forKey:@"title"];
        [userInfo setObject:[aps objectForKey:@"badge"] forKey:@"badge"];
        NSString *strContent = [remoteDic objectForKey:@"con"];
        if(strContent){
            [userInfo setObject:strContent forKey:@"content"];
            strContent =nil;
        }
    }else{
        [userInfo setDictionary:remoteDic];
    }
    
    return userInfo;
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        // 通知js
        [self postMessageNotif:userInfo messageType:RECEIVE_NOTIFICATION];
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)){
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        if (![[self.class sharedManager] isHandledLaunchTrigger]) {
            NSDictionary *launchOptions = [[self.class sharedManager] launchOptions];
            NSDictionary *dictUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]; //若由远程通知启动，则 UIApplicationLaunchOptionsRemoteNotificationKey 对应的是启动应用程序的远程通知信息userInfo(NSDictionary)
            if(dictUserInfo) // 若由远程通知启动，缓存本次推送消息
            {
                NSData *data = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:nil];
                if(data) {
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCachePushMessageTriggeredLaunch];
                }
                [[self.class sharedManager] setIsHandledLaunchTrigger:YES];
            }
        }
        // 通知js
        [self postMessageNotif:userInfo messageType:RECEIVE_NOTIFICATION_CLICK];
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

#ifdef __IPHONE_12_0
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)){
    NSString *title = nil;
    if (notification) {
        title = @"从通知界面直接进入应用";
    }else{
        title = @"从系统设置界面进入应用";
    }
    NSLog(@"%@", title);
//    UIAlertView *test = [[UIAlertView alloc] initWithTitle:title
//                                                   message:@"pushSetting"
//                                                  delegate:self
//                                         cancelButtonTitle:@"yes"
//                                         otherButtonTitles:nil, nil];
//    [test show];
    
}
#endif

#pragma mark -JPUSHGeofenceDelegate
//进入地理围栏区域
- (void)jpushGeofenceIdentifer:(NSString * _Nonnull)geofenceId didEnterRegion:(NSDictionary * _Nullable)userInfo error:(NSError * _Nullable)error{
    NSLog(@"进入地理围栏区域");
    if (error) {
        NSLog(@"error = %@",error);
        return;
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //[self testAlert:userInfo];
    }else{
        // 进入后台
        [self geofenceBackgroudTest:userInfo];
    }
}
//离开地理围栏区域
- (void)jpushGeofenceIdentifer:(NSString * _Nonnull)geofenceId didExitRegion:(NSDictionary * _Nullable)userInfo error:(NSError * _Nullable)error{
    NSLog(@"离开地理围栏区域");
    if (error) {
        NSLog(@"error = %@",error);
        return;
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //[self testAlert:userInfo];
    }else{
        // 进入后台
        [self geofenceBackgroudTest:userInfo];
    }
}
//
- (void)geofenceBackgroudTest:(NSDictionary * _Nullable)userInfo{
    //静默推送：
    if(!userInfo){
        NSLog(@"静默推送的内容为空");
        return;
    }
    //TODO
    
}

- (void)testAlert:(NSDictionary*)userInfo{
    if(!userInfo){
        NSLog(@"messageDict 为 nil ");
        return;
    }
    NSString *title = userInfo[@"title"];
    NSString *body = userInfo[@"content"];
    if (title &&  body ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
