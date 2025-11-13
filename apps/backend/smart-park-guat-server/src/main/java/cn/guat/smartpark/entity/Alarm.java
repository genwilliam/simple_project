package cn.guat.smartpark.entity;

import lombok.Data;


/**
 * 告警实体类
 * 用于表示系统中的告警信息
 */
@Data
public class Alarm {

    /**
     * 告警记录ID
     */
    private Long id;

    /**
     * 告警机房ID
     */
    private Long roomId;

    /**
     * 告警机柜ID （机柜设备告警时必填）
     */
    private Long cabinetId;

    /**
     * 告警设备ID
     */
    private Long deviceId;

    /**
     * 告警等级 1紧急告警Critical 2次要告警Minor
     */
    private Integer level;

    /**
     * 告警类型
     */
    private String type;

    /**
     * 告警状态 0结束告警 1正在告警
     */
    private Integer status;

    /**
     * 告警内容
     */
    private String content;

    /**
     * 部门ID
     */
    private Long deptId;

    /**
     * 删除标志（0代表存在 2代表删除）
     */
    private String delFlag;

    /**
     * 备注
     */
    private String remark;


}
