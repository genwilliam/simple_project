package cn.guat.smartpark.entity;

import java.math.BigDecimal;
import java.util.Date;

import lombok.Data;



@Data
public class ChargingAlarm {
    /**
     * 自增主键
     */
    private Long id;

    /**
     * 告警时间
     */
    private Date alarmTime;

    /**
     * 设备编号
     */
    private String deviceId;

    /**
     * 告警类型（over_voltage / over_current / over_temp / offline）
     */
    private String alarmType;

    /**
     * 触发值
     */
    private BigDecimal alarmValue;

    /**
     * 阈值参考
     */
    private BigDecimal threshold;

    /**
     * 告警等级（1普通，2严重）
     */
    private Integer alarmLevel;

    /**
     * 处理状态（0未处理，1处理中，2已处理）
     */
    private Integer status;

    /**
     * 处理人
     */
    private String handler;

    /**
     * 处理备注
     */
    private String remark;

    /**
     * 创建时间
     */
    private Date createTime;

    @Override
    public boolean equals(Object that) {
        if (this == that) {
            return true;
        }
        if (that == null) {
            return false;
        }
        if (getClass() != that.getClass()) {
            return false;
        }
        ChargingAlarm other = (ChargingAlarm) that;
        return (this.getId() == null ? other.getId() == null : this.getId().equals(other.getId()))
            && (this.getAlarmTime() == null ? other.getAlarmTime() == null : this.getAlarmTime().equals(other.getAlarmTime()))
            && (this.getDeviceId() == null ? other.getDeviceId() == null : this.getDeviceId().equals(other.getDeviceId()))
            && (this.getAlarmType() == null ? other.getAlarmType() == null : this.getAlarmType().equals(other.getAlarmType()))
            && (this.getAlarmValue() == null ? other.getAlarmValue() == null : this.getAlarmValue().equals(other.getAlarmValue()))
            && (this.getThreshold() == null ? other.getThreshold() == null : this.getThreshold().equals(other.getThreshold()))
            && (this.getAlarmLevel() == null ? other.getAlarmLevel() == null : this.getAlarmLevel().equals(other.getAlarmLevel()))
            && (this.getStatus() == null ? other.getStatus() == null : this.getStatus().equals(other.getStatus()))
            && (this.getHandler() == null ? other.getHandler() == null : this.getHandler().equals(other.getHandler()))
            && (this.getRemark() == null ? other.getRemark() == null : this.getRemark().equals(other.getRemark()))
            && (this.getCreateTime() == null ? other.getCreateTime() == null : this.getCreateTime().equals(other.getCreateTime()));
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((getId() == null) ? 0 : getId().hashCode());
        result = prime * result + ((getAlarmTime() == null) ? 0 : getAlarmTime().hashCode());
        result = prime * result + ((getDeviceId() == null) ? 0 : getDeviceId().hashCode());
        result = prime * result + ((getAlarmType() == null) ? 0 : getAlarmType().hashCode());
        result = prime * result + ((getAlarmValue() == null) ? 0 : getAlarmValue().hashCode());
        result = prime * result + ((getThreshold() == null) ? 0 : getThreshold().hashCode());
        result = prime * result + ((getAlarmLevel() == null) ? 0 : getAlarmLevel().hashCode());
        result = prime * result + ((getStatus() == null) ? 0 : getStatus().hashCode());
        result = prime * result + ((getHandler() == null) ? 0 : getHandler().hashCode());
        result = prime * result + ((getRemark() == null) ? 0 : getRemark().hashCode());
        result = prime * result + ((getCreateTime() == null) ? 0 : getCreateTime().hashCode());
        return result;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(hashCode());
        sb.append(", id=").append(id);
        sb.append(", alarmTime=").append(alarmTime);
        sb.append(", deviceId=").append(deviceId);
        sb.append(", alarmType=").append(alarmType);
        sb.append(", alarmValue=").append(alarmValue);
        sb.append(", threshold=").append(threshold);
        sb.append(", alarmLevel=").append(alarmLevel);
        sb.append(", status=").append(status);
        sb.append(", handler=").append(handler);
        sb.append(", remark=").append(remark);
        sb.append(", createTime=").append(createTime);
        sb.append("]");
        return sb.toString();
    }
}