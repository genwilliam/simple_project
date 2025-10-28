package cn.guat.smartpark.entity;

import lombok.Data;
import java.util.Date;

@Data
public class ChargingRealtime {
    /** 主键ID，唯一标识一条实时数据记录 */
    private Long id;

    /** 设备唯一标识ID，关联具体的充电设备 */
    private String deviceId;

    /** 设备状态（0：空闲；1：充电；2：故障；3：离线） */
    private Integer status;

    /** 电压值（单位：V） */
    private Double voltage;

    /** 电流值（单位：A） */
    private Double current;

    /** 功率值（单位：W） */
    private Double power;

    /** 设备温度（单位：℃） */
    private Double temperature;

    /** 数据采集时间，记录该条实时数据的采集时刻 */
    private Date collectTime;
}

