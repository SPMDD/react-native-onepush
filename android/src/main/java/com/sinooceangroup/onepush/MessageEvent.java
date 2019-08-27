package com.sinooceangroup.onepush;

import java.io.Serializable;
import java.util.Map;

/**
 * <p>文件描述：<p>
 * <p>作者：Mike<p>
 * <p>创建时间：2019/2/21<p>
 * <p>更改时间：2019/2/21<p>
 */
public class MessageEvent implements Serializable {
    private EventType type;
    private String dataJson;

    public MessageEvent(EventType type,String dataJson){
        this.type = type;
        this.dataJson = dataJson;
    }

    public EventType getType() {
        return type;
    }

    public void setType(EventType type) {
        this.type = type;
    }

    public String getDataJson() {
        return dataJson;
    }

    public void setDataJson(String dataJson) {
        this.dataJson = dataJson;
    }

    @Override
    public String toString() {
        return "MessageEvent{" +
                "type=" + type +
                ", dataJson='" + dataJson + '\'' +
                '}';
    }
}
