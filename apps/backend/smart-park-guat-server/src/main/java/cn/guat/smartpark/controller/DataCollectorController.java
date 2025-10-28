package cn.guat.smartpark.controller;

import cn.guat.smartpark.entity.ChargingRealtime;
import cn.guat.smartpark.service.DataCollectorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * 数据采集控制器
 * 负责处理与数据采集相关的HTTP请求，提供手动触发采集和查询最近采集结果的接口
 */
@RestController
@RequestMapping("/api/collector") // 统一请求路径前缀，所有接口均以该路径开头
public class DataCollectorController {

    /**
     * 注入数据采集服务对象
     * 用于调用具体的数据采集业务逻辑
     */
    @Autowired
    private DataCollectorService collectorService;

    /**
     * 手动触发一次数据采集操作
     * 接口说明：通过POST请求触发单次数据采集，调用服务层的采集方法
     * @return 字符串提示信息，返回"数据采集完成！"表示采集操作执行完毕
     */
    @PostMapping("/run") // 接口路径：/api/collector/run，接收POST请求
    public String runCollect() {
        collectorService.collectOnce(); // 调用服务层方法执行一次采集
        return "数据采集完成！";
    }

    /**
     * 查询最近的采集结果
     * 接口说明：通过GET请求获取最近采集到的实时充电数据列表
     * @return 实时充电数据列表（List<ChargingRealtime>），包含最近采集的结果信息
     */
    @GetMapping("/list") // 接口路径：/api/collector/list，接收GET请求
    public List<ChargingRealtime> listRecent() {
        // 调用服务层方法获取最近采集结果并返回
        return collectorService.listRecent();
    }
}
