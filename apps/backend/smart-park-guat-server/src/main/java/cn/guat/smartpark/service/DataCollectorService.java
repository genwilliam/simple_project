package cn.guat.smartpark.service;

import cn.guat.smartpark.common.TcpDeviceClient;
import cn.guat.smartpark.common.TcpDeviceClient.DeviceData;
import cn.guat.smartpark.entity.ChargingRealtime;
import cn.guat.smartpark.mapper.ChargingRealtimeMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

/**
 * 充电桩数据采集服务
 * 优化点：
 * 1. 并行采集多设备数据，减少总耗时
 * 2. 批量插入数据库，降低IO开销
 * 3. 完善耗时监控与异常处理
 * 4. 新增创建时间和更新时间记录
 */
@Slf4j
@Service
public class DataCollectorService {

    @Resource
    private ChargingRealtimeMapper realtimeMapper;

    // 设备列表（从工具类获取15台设备编号：CP0001~CP0015）
    private final List<String> deviceList = TcpDeviceClient.getAllDeviceIds();

    /**
     * 定时采集任务（每30秒执行一次）
     * 替代原有串行逻辑，采用并行处理提升效率
     */
    @Scheduled(fixedRate = 60000)
    public void collectOnce() {
        long totalStart = System.currentTimeMillis();
        log.info("开始采集{}台设备数据", deviceList.size());

        try {
            // 1. 并行查询所有设备数据（使用默认 ForkJoinPool 线程池）
            List<CompletableFuture<ChargingRealtime>> futures = deviceList.stream()
                    .map(deviceId -> CompletableFuture.supplyAsync(() -> {
                        // 单台设备数据采集逻辑
                        return collectSingleDevice(deviceId);
                    }))
                    .collect(Collectors.toList());

            // 2. 等待所有并行任务完成并收集结果
            List<ChargingRealtime> records = futures.stream()
                    .map(CompletableFuture::join)  // 阻塞等待任务完成，获取结果
                    .filter(record -> record != null)  // 过滤异常记录
                    .collect(Collectors.toList());

            // 3. 批量插入数据库（核心优化点：减少IO次数）
            if (!records.isEmpty()) {
                long dbStart = System.currentTimeMillis();
                int insertCount = realtimeMapper.batchInsert(records);
                log.info("批量插入{}条数据，耗时: {}ms", insertCount, System.currentTimeMillis() - dbStart);
            }

            log.info("所有设备采集完成，总耗时: {}ms", System.currentTimeMillis() - totalStart);
        } catch (Exception e) {
            log.error("数据采集任务异常", e);
        }
    }

    /**
     * 采集单台设备数据
     * 包含数据转换、异常处理和耗时监控，新增创建时间和更新时间
     */
    private ChargingRealtime collectSingleDevice(String deviceId) {
        long deviceStart = System.currentTimeMillis();
        ChargingRealtime record = new ChargingRealtime();
        record.setDeviceId(deviceId);

        // 统一当前时间（采集时间、创建时间、更新时间保持一致）
        Date now = new Date();
        record.setCollectTime(now);  // 采集时间
        record.setCreateTime(now);
        record.setUpdateTime(now);

        try {
            // 调用TCP客户端获取设备数据（模拟TCP通信）
            DeviceData data = TcpDeviceClient.queryDevice(deviceId);

            if (data == null) {
                // 设备离线（TcpDeviceClient返回null表示离线）
                record.setStatus(3);
                log.debug("设备[{}]离线，耗时: {}ms", deviceId, System.currentTimeMillis() - deviceStart);
            } else {
                // 设备在线，转换数据格式（保留两位小数）
                record.setStatus(data.getStatus());
                record.setVoltage(new BigDecimal(data.getVoltage()).setScale(2, RoundingMode.HALF_UP));
                record.setCurrent(new BigDecimal(data.getCurrent()).setScale(2, RoundingMode.HALF_UP));
                record.setPower(new BigDecimal(data.getPower()).setScale(2, RoundingMode.HALF_UP));
                record.setTemperature(new BigDecimal(data.getTemperature()).setScale(1, RoundingMode.HALF_UP));
                log.debug("设备[{}]在线，状态: {}，耗时: {}ms", deviceId, data.getStatus(), System.currentTimeMillis() - deviceStart);
            }
            return record;
        } catch (Exception e) {
            log.error("设备[{}]采集异常", deviceId, e);
            return null;  // 异常记录不入库
        }
    }

    /**
     * 查询最近采集的15条数据（供前端展示）
     */
    public List<ChargingRealtime> listRecent() {
        return realtimeMapper.findRecent();
    }
}