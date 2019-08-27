import {
  NativeAppEventEmitter,
  NativeEventEmitter,
  NativeModules,
  Platform,
} from 'react-native'
import { AppDeviceInfo } from 'react-native-yuanxinkit'
import Config from 'react-native-config'

const _PushManager = NativeModules.PushManager

var listeners = {}
var eventEmitters = new Map()
var PushEmitter;
(function () {
  if (!PushEmitter) {
    PushEmitter = new NativeEventEmitter(_PushManager)
    if (PushEmitter) {
    } else {
      PushEmitter = NativeAppEventEmitter
    }
  }
})()
//推送消息管理者
export default class PushManager {

  /**
   * 注册推送服务
   */
  static register (access_token, UserId) {
    global.pushInfo = {}
    this.UserId = UserId
    this.addPushEventListener(_PushManager.PUSH_TOKEN, (res) => {
      global.pushInfo.push = JSON.stringify(res)
      this.push_id = res.pushToken
      this.pushChannel = res.pushChannel.toLowerCase()
      let body = JSON.stringify({
        AppId: Config.AppID,
        AppVersion: (Platform.OS === 'ios') ? Config.iOSVersionName : Config.AndroidVersionName,
        DeviceBrand: AppDeviceInfo.Brand,
        DeviceType: Platform.OS,
        Manufacturer: AppDeviceInfo.SystemManufacturer,
        DeviceId: AppDeviceInfo.DeviceId,
        DeviceModel: AppDeviceInfo.Model,
        DeviceLanguage: AppDeviceInfo.DeviceLocale,
        TimeZone: AppDeviceInfo.Timezone,
        PushToken: this.push_id,
        PushChannel: this.pushChannel,
        SystemVersion: AppDeviceInfo.SystemVersion,

      })
      console.log('PushManager-init.body:', body)
      fetch(Config.PushAddress + '/yuanxin.platform.pushService/settings/uploadDevice', {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          Authorization: 'Bearer ' + access_token,
        },
        body: body,
      })
        .then(response => {
          return response.text().then(text => {
            global.pushInfo.uploadDevice = text
            return JSON.parse(text)
          })
        })
        .then((res) => {
          console.log('PushManager-init.then:', JSON.stringify(res))
          this.bindingUser(access_token)
        }).catch((err) => {
        console.log('PushManager-init.catch', err)
      })
    })
    //
    _PushManager.registerPush()
  }

  /**
   * 绑定用户和推送token
   * @param access_token
   */
  static bindingUser (access_token) {
    let body = JSON.stringify({
      pushToken: this.push_id,
      PushChannel: this.pushChannel,
    })
    console.log('PushManager-bindingUser.body', body)
    fetch(Config.PushAddress + '/yuanxin.platform.pushService/settings/bindingUser', {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + access_token,
      },
      body: body,
    }).then(response => {
      return response.text().then(text => {
        global.pushInfo.bindingUser = text
        return JSON.parse(text)
      })
    })
      .then((res) => {
        console.log('PushManager-bindingUser.then:' + JSON.stringify(res))
      }).catch((err) => {
      console.log('PushManager-bindingUser.catch:' + err)
    })
  }

  /**
   * 解绑用户和推送token
   */
  static unBindingUser (): Promise {
    return new Promise((resolve, reject) => {
      let body = JSON.stringify({
        pushToken: this.push_id,
        PushChannel: this.pushChannel,
        userId: this.UserId,
      })
      console.log('PushManager-unBindingUser.body', body)
      fetch(Config.PushAddress + '/yuanxin.platform.pushService/settings/unbindingUser', {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      })
        .then(response => {
          return response.text().then(text => {
            global.pushInfo.unBindingUser = text
            return JSON.parse(text)
          })
        })
        .then((res) => {
          console.log('PushManager-unBindingUser.then:' + JSON.stringify(res))
          resolve(res.isSuccess)
        }).catch((err) => {
        console.log('PushManager-unBindingUser.error', err)
        reject(err)
      })
    })
  }

  /**
   * 推送设置
   * @param enable 1开启推送，2关闭推送，3根据时段免打扰（暂未实现）
   */
  static pushSetting (enable, access_token) {
    let body = JSON.stringify({
      Switch: enable,
    })
    console.log('PushManager-pushSetting.body', body)
    fetch(Config.PushAddress + '/yuanxin.platform.pushService/settings/pushSetting', {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + access_token,
      },
      body: body,
    }).then(response => {
      return response.text().then(text => {
        global.pushInfo.pushSetting = text
        return JSON.parse(text)
      })
    })
      .then((res) => {
        console.log('PushManager-pushSetting.then', JSON.stringify(res))
      }).catch((err) => {
      console.log('PushManager-pushSetting.error', err)
    })
  }

  /**
   * 通知接收处理器
   * @param handler
   */
  static onReceiveNotification (handler: Function) {
    this.addPushEventListener(_PushManager.RECEIVE_NOTIFICATION, handler)
  }

  /**
   * 移除通知接收监听
   */
  static removeReceiveNotification (handler: Function) {
    this.removePushEventListener(_PushManager.RECEIVE_NOTIFICATION, handler)
  }

  /**
   * 通知点击处理器
   * @param handler
   */
  static onReceiveNotificationClick (handler: Function) {
    this.addPushEventListener(_PushManager.RECEIVE_NOTIFICATION_CLICK, handler)
  }

  /**
   * 移除通知点击监听
   */
  static removeReceiveNotificationClick (handler: Function) {
    this.removePushEventListener(_PushManager.RECEIVE_NOTIFICATION_CLICK, handler)
  }

  static formatDate (now) {
    let year = now.getFullYear()
    let month = now.getMonth() + 1
    let date = now.getDate()
    let hour = now.getHours()
    let minute = now.getMinutes()
    let second = now.getSeconds()
    return year + '-' + month + '-' + date + ' ' + hour + ':' + minute + ':' + second
  }

  /**
   * 上报用户消息被展示日志
   * @param MessageId
   */
  static reportNotificationOpened (MessageId) {
    let body = JSON.stringify({
      MessageId: MessageId,
      UserId: this.UserId,
      isChecked: true,
      CheckTime: PushManager.formatDate(new Date()),
    })
    console.log('PushManager-UpdateCheckStatus.body', body)
    fetch(Config.PlatformAddress + '/YuanXin.Report.LogCollect/pushmessage/UpdateCheckStatus', {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    }).then(response => response.json())
      .then((res) => {
        console.log('PushManager-UpdateCheckStatus.then', JSON.stringify(res))
      }).catch((err) => {
      console.log('PushManager-UpdateCheckStatus.error', err)
    })
  }

  /**
   * 透传消息处理器
   * @param handler
   */
  static onReceiveMessage (handler: Function) {
    this.addPushEventListener(_PushManager.RECEIVE_MESSAGE, handler)
  }

  /**
   * 移除透传消息监听
   */
  static removeReceiveMessage (handler: Function) {
    this.removePushEventListener(_PushManager.RECEIVE_MESSAGE, handler)
  }

  /**
   *  添加事件的监听
   * @param {*} eventName
   * @param {*} handler
   */
  static addPushEventListener (eventName: string, handler: Function) {
    //判断是否系统做了相关的事件处理
    var callBacks = []
    var isAddListener = true
    if (listeners[eventName]) {
      callBacks = listeners[eventName]
      isAddListener = false
    }
    callBacks.push(handler)
    listeners[eventName] = callBacks
    if (isAddListener) {
      let currentListener = PushEmitter.addListener(
        eventName,
        (notifSource) => {
          let notifName = notifSource.name
          // let notifData = this.parseNotification(notifSource.data) // Static member is not accessible
          let notifData = PushManager.parseNotification(notifSource.data, eventName)
          if (listeners[notifName])
            for (let i = 0; i < listeners[notifName].length; i++) {
              let actionBack = listeners[notifName][i]
              if (actionBack) {
                actionBack(notifData)
              }
            }
        },
      )
      eventEmitters.set(eventName, currentListener)
    }
  }

  static removePushEventListener (eventName: string, handler: Function) {
    if (listeners[eventName]) {
      var i = listeners[eventName].indexOf(handler)
      if (i != -1) {
        listeners[eventName].splice(i, 1)
      }

      if (!listeners[eventName].length) {
        let listener = eventEmitters.get(eventName)
        if (!listener) {
          return
        }

        listener.remove()
        eventEmitters.delete(eventName)
      }
    }
  }

  /**
   * 解析处理通知消息
   * @param {Object} data 要解析的数据
   * @param {string} eventName 消息类型
   */
  static parseNotification (data: Object, eventName: string) {
    let result
    if (Platform.OS === 'ios') {
      let notification = data
      notification = Object.assign({}, data)
      console.log('原始消息格式：' + JSON.stringify(data))
      if (eventName === _PushManager.PUSH_TOKEN) {

      } else if (eventName === _PushManager.RECEIVE_NOTIFICATION || eventName === _PushManager.RECEIVE_NOTIFICATION_CLICK) {
        if (data.hasOwnProperty('aps')) {
          let aps = data.aps
          let alert = aps.alert
          let notif = {}

          if (typeof alert === 'string') {
            notif = {
              title: alert,
            }
          } else if (typeof alert === 'object') {
            notif = {
              title: alert.title,
              subtitle: alert.subtitle,
              content: alert.body,
            }
          }
          delete notification.aps
          notification = Object.assign({}, notif, { keyValue: notification })
        }
      } else if (eventName === _PushManager.RECEIVE_MESSAGE) {
        notification = {
          title: data.title,
          subtitle: data.subtitle,
          content: data.content,
          keyValue: data.extras,
        }
      }
      result = notification
    } else {
      result = JSON.parse(data)
    }
    return result
  }

  /**
   * 反注册并解绑推送
   * @param accessToken
   */
  static unregister () {
    global.pushInfo = {}
    this.unBindingUser().then(result => {
      _PushManager.unregisterPush()
      //清理所有推送的监听
      this.cleanListeners()
    }).catch(error => {
      _PushManager.unregisterPush()
      //清理所有推送的监听
      this.cleanListeners()
    })
  }

  static cleanListeners () {
    listeners[_PushManager.PUSH_TOKEN].forEach(
      handler => {
        console.log('PushManager-cleanListeners.key:' + _PushManager.PUSH_TOKEN, handler)
        this.removePushEventListener(_PushManager.PUSH_TOKEN, handler)
      }
    )
    delete listeners[_PushManager.PUSH_TOKEN]
  }

  /**
   * 获取设置中通知的允许状态
   * @returns {Promise}
   */
  static areNotificationsEnabled (): Promise {
    return _PushManager.areNotificationsEnabled()
  }

  /**
   * 跳转到通知设置界面或者应用设置界面
   * @returns {*}
   */
  static startNotificationSettings () {
    return _PushManager.startNotificationSettings()
  }

  /**
   * 获取缓存的消息 ios不存在此问题 ，只有Android平台出现app启动后无法收到点击消息的问题。
   */
  static getCacheMessage(){
    if(Platform.OS === 'android'){
      console.log('getCacheMessage...');
      _PushManager.getCacheMessage();
    }
  }
}
