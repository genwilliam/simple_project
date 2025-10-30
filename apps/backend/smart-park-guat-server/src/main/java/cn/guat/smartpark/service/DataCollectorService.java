package cn.guat.smartpark.service;

import cn.guat.smartpark.entity.ChargingRealtime;
import cn.guat.smartpark.mapper.ChargingRealtimeMapper;
import cn.guat.smartpark.common.TcpDeviceClient;
import cn.guat.smartpark.common.TcpDeviceClient.DeviceData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class DataCollectorService {
    private static final Logger log = LoggerFactory.getLogger(DataCollectorService.class);
    @Autowired
    private ChargingRealtimeMapper realtimeMapper;

    // 模拟的充电桩设备编号列表
    private final List<String> deviceList = Collections.unmodifiableList(Arrays.asList("CP0001", "CP0002", "CP0003", "CP0004", "CP0005"));

    // 新增定时任务：每5分钟执行一次数据采集（cron表达式：秒 分 时 日 月 周）
    @Scheduled(cron = "0 0/1 * * * ?")
    public void autoCollect() {
        log.info("定时任务开始执行...");
        collectOnce(); // 调用已有的采集方法
    }

    /** 执行一次采集 */
    public void collectOnce() {
        for (String id : deviceList) {
            DeviceData data = TcpDeviceClient.queryDevice(id);
            ChargingRealtime record = new ChargingRealtime();
            record.setDeviceId(id);
            record.setCollectTime(new Date());

            if (data == null) {
                // 离线设备
                record.setStatus(3);
            } else {
                record.setStatus(data.getStatus());
                record.setVoltage(new BigDecimal(data.getVoltage()));
                record.setCurrent(new BigDecimal(data.getCurrent()));
                record.setPower(new BigDecimal(data.getPower()));
                record.setTemperature(new BigDecimal(data.getTemperature()));
            }

            realtimeMapper.insert(record);
        }
    }

    /** 查询最新数据 */
    public List<ChargingRealtime> listRecent() {
        return realtimeMapper.findRecent();
    }
}
