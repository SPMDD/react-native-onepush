# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in D:\DevelopTools\android-sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}
-ignorewarning

-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

-keep class com.hianalytics.android.**{*;}
-keep class com.huawei.updatesdk.**{*;}
-keep class com.huawei.hms.**{*;}
-keep class com.huawei.gamebox.plugin.gameservice.**{*;}
-keep public class com.huawei.android.hms.agent.** extends android.app.Activity { public *; protected *; }
-keep interface INoProguard {*;}
-keep class * extends INoProguard {*;}

-keep class GetTokenHandler{*;}

-keepattributes *Annotation*
-keepclassmembers class ** {
    @org.greenrobot.eventbus.Subscribe <methods>;
}
-keep enum org.greenrobot.eventbus.ThreadMode { *; }
-keepclassmembers class * extends org.greenrobot.eventbus.util.ThrowableFailureEvent {
    <init>(java.lang.Throwable);
}

-dontwarn com.yanzhenjie.permission.**

-keepclassmembers class * extends com.huawei.hms.** {
    <init> (java.lang.String, com.huawei.hms.core.aidl.IMessageEntity, java.lang.Class);
}

-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# okgo
-dontwarn com.lzy.okgo.**
-keep class com.lzy.okgo.**{*;}

#Gson相关的不混淆配置
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class com.envy15.cherry.fragment.crossover.model.** { *; }
-dontwarn com.envy15.cherry.fragment.crossover.model.**
-keep class com.envy15.cherry.fragment.discover.model.** { *; }
-dontwarn com.envy15.cherry.fragment.discover.model.**
-keep class com.envy15.cherry.fragment.local.model.** { *; }
-dontwarn com.envy15.cherry.fragment.local.model.**
-keep class com.envy15.cherry.fragment.setting.model.** { *; }
-dontwarn com.envy15.cherry.fragment.setting.model.**

# 基本配置
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Fragment
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# support.v4/v7
-keep class android.support.** { *; }
-keep class android.support.v4.** { *; }
-keep public class * extends android.support.v4.**
-keep interface android.support.v4.app.** { *; }
-keep class android.support.v7.** { *; }
-keep public class * extends android.support.v7.**
-keep interface android.support.v7.app.** { *; }
-dontwarn android.support.**

# Serializable实现类
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 枚举enum类
-keepclassmembers enum * {
  public static **[] values();
 public static ** valueOf(java.lang.String);
}

# 自定义组件
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# 资源类
-keepclassmembers class **.R$* {
    public static <fields>;
}

-keep,allowobfuscation @interface com.facebook.proguard.annotations.DoNotStrip
-keep,allowobfuscation @interface com.facebook.proguard.annotations.KeepGettersAndSetters
-keep,allowobfuscation @interface com.facebook.common.internal.DoNotStrip

# Do not strip any method/class that is annotated with @DoNotStrip
-keep @com.facebook.proguard.annotations.DoNotStrip class *
-keep @com.facebook.common.internal.DoNotStrip class *
-keepclassmembers class * {
    @com.facebook.proguard.annotations.DoNotStrip *;
    @com.facebook.common.internal.DoNotStrip *;
}

-keepclassmembers @com.facebook.proguard.annotations.KeepGettersAndSetters class * {
  void set*(***);
  *** get*();
}

-keep class * extends com.facebook.react.bridge.JavaScriptModule { *; }
-keep class * extends com.facebook.react.bridge.NativeModule { *; }
-keepclassmembers,includedescriptorclasses class * { native <methods>; }
-keepclassmembers class *  { @com.facebook.react.uimanager.UIProp <fields>; }
-keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactProp <methods>; }
-keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }

-dontwarn com.facebook.react.**

-keep class com.sinooceanland.commonutils.DeviceUtil{*;}
-keep class com.sinooceanland.commonutils.SharedPreferencesUtil{*;}
-keep class com.sinooceanland.commonutils.StringUtil{*;}

-keep class com.sinooceangroup.onepush.**{*;}
-keep class com.sinooceangroup.badgerNumber.**{*;}
-keep class com.sinooceangroup.PushPackage{*;}


#这里com.xiaomi.mipushdemo.DemoMessageRreceiver改成app中定义的完整类名
-keep class com.peng.one.push.xiaomi.XiaomiPushReceiver {*;}

-keep class com.common.InitOptionParams{*;}
-keep class com.common.InitShowNotification{*;}

-keep class com.huawei.hms.support.api.push.**{*;}

-keep class com.google.protobuf.micro.**{*;}

-dontshrink


#极光推送混淆
-dontoptimize
-dontpreverify

-dontwarn cn.jpush.**
-keep class cn.jpush.** { *; }
-keep class * extends cn.jpush.android.helpers.JPushMessageReceiver { *; }

-dontwarn cn.jiguang.**
-keep class cn.jiguang.** { *; }

-dontwarn com.google.**
-keep class com.google.gson.** {*;}
-keep class com.google.protobuf.** {*;}

#onepush混淆
-dontoptimize
-dontpreverify
-dontwarn com.taobao.**
-dontwarn anet.channel.**
-dontwarn anetwork.channel.**
-dontwarn org.android.**
-dontwarn org.apache.thrift.**
-dontwarn com.xiaomi.**
-dontwarn com.huawei.**
-dontwarn com.peng.one.push.**
-dontwarn com.igexin.**
-dontwarn cn.jpush.**
-dontwarn cn.jiguang.**
-keepattributes *Annotation*

-keep class cn.jpush.** { *; }
-keep class * extends cn.jpush.android.helpers.JPushMessageReceiver { *; }
-keep class cn.jiguang.** { *; }
-keep class com.taobao.** {*;}
-keep class org.android.** {*;}
-keep class anet.channel.** {*;}
-keep class com.umeng.** {*;}
-keep class com.xiaomi.** {*;}
-keep class com.huawei.** {*;}
-keep class com.hianalytics.android.** {*;}
-keep class com.meizu.cloud.**{*;}
-keep class org.apache.thrift.** {*;}
-keep class com.igexin.** { *; }
-keep class org.json.** { *; }
-keep class com.alibaba.sdk.android.**{*;}
-keep class com.ut.**{*;}
-keep class com.ta.**{*;}

-keep public class **.R$*{
   public static final int *;
}

#（可选）避免Log打印输出
-assumenosideeffects class android.util.Log {
   public static *** v(...);
   public static *** d(...);
   public static *** i(...);
   public static *** w(...);
 }

 # OnePush的混淆
-keep class * extends com.peng.one.push.core.IPushClient{*;}