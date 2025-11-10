package cn.guat.smartpark.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;


@Data
public class AlarmListDto {
    private Long id;
    private String deviceId;
    private String alarmType;
    private String alarmLevel;//前端传入的中文描述
    private Integer alarmLevelCode;//新增:转换后的整数,供数据库使用
    private Date alarmTime;
    private Integer status;
}
