package cn.guat.smartpark.service;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class WebSocketService {
    public void sendAlertToFronted(String deviceId, String alertType, BigDecimal alertValue){

        System.out.println("发送充电桩异常告警到前端");
    }
}
