package cn.guat.smartpark.service;

import org.springframework.stereotype.Service;

@Service
public class SmsService {
    public void sendSms(String phone, String content) {
        // 模拟发送短信
        System.out.println("已向手机号" + phone + "发送短信：" + content);
    }
}
