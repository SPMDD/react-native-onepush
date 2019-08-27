
import {
    NativeModules,
} from 'react-native'

const _BadgeNumberManager = NativeModules.BadgeNumberManager;

//推送消息管理者
export default class BadgeNumberManager {

    /**
     * 设置应用卓面角标数
     */
    static setApplicationIconBadgeNumber(number: number) {
      _BadgeNumberManager.setApplicationIconBadgeNumber(number);
    }

    /**
     * 获取当前应用桌面角标数
     */
    static getApplicationIconBadgeNumber() : Promise {
      return _BadgeNumberManager.getApplicationIconBadgeNumber();
    }
}
