package com.sinooceangroup.onepush;

import android.app.ActivityManager;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Process;
import android.provider.Settings;
import android.support.annotation.Nullable;
import android.support.v4.app.NotificationManagerCompat;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;
import com.peng.one.push.OnePush;
import com.peng.one.push.core.OnOnePushRegisterListener;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static android.provider.Settings.EXTRA_APP_PACKAGE;
import static android.provider.Settings.EXTRA_CHANNEL_ID;

/**
 * <p>文件描述：推送原生模块<p>
 * <p>作者：Mike<p>
 * <p>创建时间：2019/3/6<p>
 * <p>更改时间：2019/3/6<p>
 */
public class OnePushModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private static String TAG = "OnePushModule";

    public static void init(Application application) {
        //只在主进程中注册(注意：umeng推送，除了在主进程中注册，还需要在channel中注册)
        if (application.getApplicationContext().getPackageName().equals
                (getCurrentProcessName(application))) {
            //platformCode和platformName就是在<meta/>标签中，对应的"平台标识码"和平台名称
            OnePush.setDebug(true);
            OnePush.init(application, new OnOnePushRegisterListener() {
                @Override
                public boolean onRegisterPush(int platformCode, String platformName) {
                    boolean result = false;
                    if (RomUtils.isMiuiRom()) {
                        result = platformCode == 101;
                    } else if (RomUtils.isHuaweiRom()) {
                        if (checkEmuiVersion() >= 11)//华为推送官方建议最好是EMUI5.0以及以上。 EMUI5.0 == 11
                            result = platformCode == 108;
                        else
                            result = platformCode == 106;
                        //} else if (RomUtils.isFlymeRom()) {
                        //result = platformCode == 103;
                    } else {
                        result = platformCode == 106;
                    }
                    Log.i(TAG, "Register-> code: " + platformCode + " name: " + platformName + " result: " + result);
                    return result;
                }
            });
        }
    }

    private static int checkEmuiVersion() {
        int emuiApiLevel = 0;
        try {
            Class cls = Class.forName("android.os.SystemProperties");
            Method method = cls.getDeclaredMethod("get", new Class[]{String.class});
            emuiApiLevel = Integer.parseInt((String) method.invoke(cls, new Object[]{"ro.build.hw_emui_api_level"}));
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i(TAG, "emuiApiLevel-> code: " + emuiApiLevel);
        return emuiApiLevel;
    }


    /**
     * 获取当前进程名称
     *
     * @return processName
     */
    public static String getCurrentProcessName(Application application) {
        int currentProcessId = Process.myPid();
        ActivityManager activityManager = (ActivityManager) application.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> runningAppProcesses = activityManager.getRunningAppProcesses();
        for (ActivityManager.RunningAppProcessInfo runningAppProcess : runningAppProcesses) {
            if (runningAppProcess.pid == currentProcessId) {
                return runningAppProcess.processName;
            }
        }
        return null;
    }

    public OnePushModule(ReactApplicationContext reactContext) {
        super(reactContext);
        EventBus.getDefault().register(this);
        getReactApplicationContext().addLifecycleEventListener(this);
    }

    @Override
    public String getName() {
        return "PushManager";
    }

    @ReactMethod
    public void registerPush() {
        Log.i(TAG, "register");
        OnePush.register();
    }

    @ReactMethod
    public void unregisterPush() {
        Log.i(TAG, "unregisterPush");
        OnePush.unRegister();
    }

    @ReactMethod
    public void areNotificationsEnabled(Promise promise) {
        Log.i(TAG, "areNotificationsEnabled");
        promise.resolve(NotificationManagerCompat.from(getCurrentActivity()).areNotificationsEnabled());
    }

    @ReactMethod
    public void startNotificationSettings() {
        Log.i(TAG, "areNotificationsEnabled");
        try {
            // 根据isOpened结果，判断是否需要提醒用户跳转AppInfo页面，去打开App通知权限
            Intent intent = new Intent();
            intent.setAction(Settings.ACTION_APP_NOTIFICATION_SETTINGS);
            //这种方案适用于 API 26, 即8.0（含8.0）以上可以用
            intent.putExtra(EXTRA_APP_PACKAGE, getCurrentActivity().getPackageName());
            intent.putExtra(EXTRA_CHANNEL_ID, getCurrentActivity().getApplicationInfo().uid);

            //这种方案适用于 API21——25，即 5.0——7.1 之间的版本可以使用
            intent.putExtra("app_package", getCurrentActivity().getPackageName());
            intent.putExtra("app_uid", getCurrentActivity().getApplicationInfo().uid);

            // 小米6 -MIUI9.6-8.0.0系统，是个特例，通知设置界面只能控制"允许使用通知圆点"——然而这个玩意并没有卵用，我想对雷布斯说：I'm not ok!!!
            //  if ("MI 6".equals(Build.MODEL)) {
            //      intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            //      Uri uri = Uri.fromParts("package", getPackageName(), null);
            //      intent.setData(uri);
            //      // intent.setAction("com.android.settings/.SubSettings");
            //  }
            getCurrentActivity().startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
            // 出现异常则跳转到应用设置界面：锤子坚果3——OC105 API25
            Intent intent = new Intent();

            //下面这种方案是直接跳转到当前应用的设置界面。
            //https://blog.csdn.net/ysy950803/article/details/71910806
            intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            Uri uri = Uri.fromParts("package", getCurrentActivity().getPackageName(), null);
            intent.setData(uri);
            getCurrentActivity().startActivity(intent);
        }
    }

    /**
     * 如果app在挂掉的情况下，临时存储的数据
     */
    private MessageEvent messageEvent;

    @ReactMethod
    public void getCacheMessage() {
        if (messageEvent != null) {
            Log.d(TAG, "messageEvent send：" + messageEvent.toString());
            send(messageEvent);
            messageEvent = null;
        } else
            Log.d(TAG, "messageEvent send：null");
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void setMessageEvent(Object message) {
        Log.d(TAG, "setMessageEvent:" + message.toString());
        if (!(message instanceof MessageEvent)) {
            return;
        }
        send((MessageEvent) message);
    }


    private void send(MessageEvent m) {
        WritableMap map = Arguments.createMap();
        map.putString("name", m.getType().toString());
        map.putString("data", m.getDataJson());
        emit(m.getType(), map);
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put(EventType.PUSH_TOKEN.toString(), EventType.PUSH_TOKEN.toString());
        constants.put(EventType.RECEIVE_NOTIFICATION.toString(), EventType.RECEIVE_NOTIFICATION.toString());
        constants.put(EventType.RECEIVE_NOTIFICATION_CLICK.toString(), EventType.RECEIVE_NOTIFICATION_CLICK.toString());
        constants.put(EventType.RECEIVE_MESSAGE.toString(), EventType.RECEIVE_MESSAGE.toString());
        return constants;
    }

    public void emit(EventType eventType, ReadableMap map) {
        if (getReactApplicationContext().hasActiveCatalystInstance()) {
            Log.d(TAG, eventType.toString() + "|" + map.toHashMap().toString());
            getReactApplicationContext().getJSModule(RCTNativeAppEventEmitter.class)
                    .emit(eventType.toString(), map);
        }
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        EventBus.getDefault().unregister(this);
        getReactApplicationContext().removeLifecycleEventListener(this);
    }

    @Override
    public void onHostResume() {
        MessageEvent messageEvent = (MessageEvent) getCurrentActivity().getIntent().getSerializableExtra("cacheMessage");
        if (messageEvent != null) {
            getCurrentActivity().getIntent().removeExtra("cacheMessage");
            //保存
            this.messageEvent = messageEvent;
            Log.d(TAG, "onHostResume save：" + messageEvent.toString());
        }
    }

    @Override
    public void onHostPause() {

    }

    @Override
    public void onHostDestroy() {

    }
}
