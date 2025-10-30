package cn.guat.smartpark.dto;

import lombok.Data;

import java.util.Date;


@Data
public class AlarmListDto {
    private String deviceId;
    private String alarmType;
    private String alarmLevel;
    private Date alarmTime;
    private Integer status;
}
