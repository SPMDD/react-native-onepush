import _BadgeNumberManager from './js/BadgeNumberManager'
import _PushManager from './js/PushManager'
//获取pushId并上传  注释原因：登录后进行启动
// (function () {
//   console.log("init");
//   _PushManager.register();
// })();

export const BadgeNumberManager = _BadgeNumberManager;
export const PushManager = _PushManager;
