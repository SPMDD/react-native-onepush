package com.sinooceangroup.onepush;

/**
 * <p>文件描述：<p>
 * <p>作者：Mike<p>
 * <p>创建时间：2019/2/20<p>
 * <p>更改时间：2019/2/20<p>
 */
public enum EventType {
    /**
     * 推送标识
     */
    PUSH_TOKEN,
    /**
     * 接收通知
     */
    RECEIVE_NOTIFICATION,
    /**
     * 点击通知
     */
    RECEIVE_NOTIFICATION_CLICK,
    /**
     * 接收透传消息
     */
    RECEIVE_MESSAGE,
}
