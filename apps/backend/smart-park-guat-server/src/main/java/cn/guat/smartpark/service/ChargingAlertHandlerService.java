package cn.guat.smartpark.service;


import cn.guat.smartpark.entity.ChargingAlarm;
import cn.guat.smartpark.mapper.ChargingAlarmMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Date;


@Service
public class ChargingAlertHandlerService {

    @Autowired
    private ChargingAlarmMapper chargingAlarmMapper;
    @Autowired
    private SmsService smsService;
    @Autowired
    private WebSocketService webSocketService;


    @Transactional
    public void triggerAlert(String deviceID, String alertType, BigDecimal alertValue, BigDecimal threshold) {
        //1.判断是否已经存在相同告警
        ChargingAlarm existAlarm = chargingAlarmMapper.getUnProcessedAlarm(deviceID, alertType);
        if(existAlarm != null){
            //已有相同告警,忽略防止重复提交
            return;
        }

        System.out.println("已触发告警"+alertType);
        //2.记录告警到数据库
        ChargingAlarm chargingAlarm = new ChargingAlarm();
        chargingAlarm.setDeviceId(deviceID);
        chargingAlarm.setAlarmType(alertType);
        chargingAlarm.setAlarmValue(alertValue);
        chargingAlarm.setThreshold(threshold);
        chargingAlarm.setAlarmTime(new Date());

        chargingAlarmMapper.save(chargingAlarm);

        //2.触发前端弹窗
        webSocketService.sendAlertToFronted(deviceID,alertType,alertValue);

        //3.发送短信给管理员(实际手机号从数据库当中拿取)
        smsService.sendSms("12345678901", "充电桩" + deviceID + "发生" + alertType + "，请及时处理");
    }
}
