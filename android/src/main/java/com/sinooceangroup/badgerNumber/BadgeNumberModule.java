package com.sinooceangroup.badgerNumber;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.sinooceangroup.badgerNumber.ShortcutBadger;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.lzy.okgo.OkGo;
import com.lzy.okgo.callback.StringCallback;
import com.lzy.okgo.model.Response;
import com.sinooceangroup.badgerNumber.util.Utils;
import com.sinooceangroup.onepush.BuildConfig;
import com.xiaomi.mipush.sdk.MiPushClient;

/**
 * <p>文件描述：<p>
 * <p>作者：Mike<p>
 * <p>创建时间：2019/2/20<p>
 * <p>更改时间：2019/2/20<p>
 */
public class BadgeNumberModule extends ReactContextBaseJavaModule {

    private final String TAG = "BadgeNumberManager";


    public BadgeNumberModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "BadgeNumberManager";
    }

    @ReactMethod
    public void setApplicationIconBadgeNumber(int badge, Promise promise) {
        Log.d(TAG, "setApplicationIconBadgeNumber-badge-" + badge);
        SharedPreferences sharedPreferences = getCurrentActivity().getSharedPreferences("Badge", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt("Badge", badge);
        editor.commit();
        ShortcutBadger.applyCount(getReactApplicationContext(), badge);

    }

    @ReactMethod
    public void getApplicationIconBadgeNumber(Promise promise) {
        Log.d(TAG, "getApplicationIconBadgeNumber");

        SharedPreferences sharedPreferences = getCurrentActivity().getSharedPreferences("Badge", Context.MODE_PRIVATE);

        int badge = sharedPreferences.getInt("badge", 0);
        promise.resolve(badge);
        ShortcutBadger.applyCount(getReactApplicationContext(), badge);

    }

}
