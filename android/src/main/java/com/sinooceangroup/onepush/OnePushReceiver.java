package com.sinooceangroup.onepush;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.peng.one.push.OnePush;
import com.peng.one.push.entity.OnePushCommand;
import com.peng.one.push.entity.OnePushMsg;
import com.peng.one.push.receiver.BaseOnePushReceiver;

import org.greenrobot.eventbus.EventBus;

import java.util.List;

/**
 * <p>文件描述：<p>
 * <p>作者：Mike<p>
 * <p>创建时间：2019/3/6<p>
 * <p>更改时间：2019/3/6<p>
 */
public class OnePushReceiver extends BaseOnePushReceiver {
    public static final String LOG_LINE = "-------%s-------";
    private static final String TAG = "OnePushReceiver";

    @Deprecated
    @Override
    public void onReceiveNotification(Context context, OnePushMsg msg) {
        super.onReceiveNotification(context, msg);
        Log.d(TAG, "onReceiveNotification: " + msg.toString());
        EventBus.getDefault().post(new MessageEvent(EventType.RECEIVE_NOTIFICATION, new Gson().toJson(msg)));
    }

    @Override
    public void onReceiveNotificationClick(Context context, OnePushMsg msg) {
        Log.d(TAG, "onReceiveNotificationClick: " + msg.toString());
        //找到启动的activity，并启动APP
        Intent resolveIntent = new Intent(Intent.ACTION_MAIN, null);
        resolveIntent.addCategory(Intent.CATEGORY_LAUNCHER);
        resolveIntent.setPackage(context.getPackageName());
        PackageManager pManager = context.getPackageManager();
        List apps = pManager.queryIntentActivities(resolveIntent,
                0);
        ResolveInfo ri = (ResolveInfo) apps.iterator().next();
        if (ri != null) {
            String startappName = ri.activityInfo.packageName;
            String className = ri.activityInfo.name;
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_LAUNCHER);
            intent.addFlags( Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setComponent(new ComponentName(startappName, className));
            intent.putExtra("cacheMessage",new MessageEvent(EventType.RECEIVE_NOTIFICATION_CLICK, new Gson().toJson(msg)));
            context.startActivity(intent);
        }
        //发送消息给module，module发送给rn
        EventBus.getDefault().post(new MessageEvent(EventType.RECEIVE_NOTIFICATION_CLICK, new Gson().toJson(msg)));

    }

    @Override
    public void onReceiveMessage(Context context, OnePushMsg msg) {
        Log.d(TAG, "onReceiveMessage: " + msg.toString());
        EventBus.getDefault().post(new MessageEvent(EventType.RECEIVE_MESSAGE, new Gson().toJson(msg)));

    }

    @Override
    public void onCommandResult(Context context, OnePushCommand command) {
        Log.d(TAG, "onCommandResult: " + command.toString());
        if (command.getType() == OnePush.TYPE_REGISTER) {
            //注册消息推送失败，再次注册
            if (command.getResultCode() == OnePush.RESULT_ERROR)
                OnePush.register();
            else if (command.getResultCode() == OnePush.RESULT_OK && (!"".equals(command.getToken()) && null != command.getToken())) {
                EventBus.getDefault().post(new MessageEvent(EventType.PUSH_TOKEN, String.format("{\"pushToken\":\"%s\",\"pushChannel\":\"%s\"}", command.getToken(), OnePush.getPushPlatFormName())));
            } else
                OnePush.register();
        }
    }

    public String generateLogByOnePushMsg(String type, OnePushMsg onePushMsg) {
        StringBuilder builder = new StringBuilder();
        builder.append(String.format(LOG_LINE, type)).append("\n");
        if (onePushMsg.getMsg() != null) {
            builder.append("消息内容：" + onePushMsg.getMsg()).append("\n");
        } else {
            builder.append("通知标题：" + onePushMsg.getTitle()).append("\n");
            builder.append("通知内容：" + onePushMsg.getContent()).append("\n");
        }
        if (!TextUtils.isEmpty(onePushMsg.getExtraMsg())) {
            builder.append("额外信息：" + onePushMsg.getExtraMsg()).append("\n");
        }

        if (onePushMsg.getKeyValue() != null && !onePushMsg.getKeyValue().isEmpty()) {
            builder.append("键值对：").append(onePushMsg.getKeyValue().toString()).append("\n");
        }
        return builder.toString();
    }

    public String generateLogByOnePushCommand(OnePushCommand onePushCommand) {
        StringBuilder builder = new StringBuilder();
        String type = null;
        switch (onePushCommand.getType()) {
            case OnePushCommand.TYPE_ADD_TAG:
                type = "添加标签";
                break;
            case OnePushCommand.TYPE_DEL_TAG:
                type = "删除标签";
                break;
            case OnePushCommand.TYPE_BIND_ALIAS:
                type = "绑定别名";
                break;
            case OnePushCommand.TYPE_UNBIND_ALIAS:
                type = "解绑别名";
                break;
            case OnePushCommand.TYPE_REGISTER:
                type = "注册推送";
                break;
            case OnePushCommand.TYPE_UNREGISTER:
                type = "取消注册推送";
                break;
            case OnePushCommand.TYPE_AND_OR_DEL_TAG:
                type = "添加或删除标签";
                break;
            default:
                type = "未定义类型";
                break;
        }
        builder.append(String.format(LOG_LINE, type)).append("\n");
        if (!TextUtils.isEmpty(onePushCommand.getToken())) {
            builder.append("推送token：").append(onePushCommand.getToken()).append("\n");
        }
        if (!TextUtils.isEmpty(onePushCommand.getExtraMsg())) {
            builder.append("额外信息(tag/alias)：").append(onePushCommand.getExtraMsg()).append("\n");
        }
        builder.append("操作结果：").append(onePushCommand.getResultCode() == OnePushCommand.RESULT_OK ? "成功" : "code: " + onePushCommand.getResultCode() + " msg:失败");
        return builder.toString();
    }
}
