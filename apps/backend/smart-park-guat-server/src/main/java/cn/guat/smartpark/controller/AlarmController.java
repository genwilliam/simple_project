package cn.guat.smartpark.controller;

import cn.guat.smartpark.common.R;
import cn.guat.smartpark.service.AlarmService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * 告警控制器类
 * 处理与告警相关的HTTP请求
 */
@RestController
@RequestMapping("/global")
public class AlarmController {
    @Resource
    private AlarmService alarmService;

    /**
     * 驾驶舱2-告警事件预览
     * 告警级别分布（紧急、重要、一般）饼图

     *
     * @return 返回告警级别分布的响应结果
     */
    @GetMapping("/alarmLevel")
    public R alarmLevel() {
        return R.success(alarmService.alarmLevel());
    }

    /**
     * 驾驶舱2-告警事件预览
     * TOP5告警类型（如空调故障、电源异常、网络中断等。）
     *
     * @return 返回TOP5告警类型数据的响应结果
     */
    @GetMapping("/AlarmClassifyTop5")
    public R AlarmClassifyTop5() {
        return R.success(alarmService.AlarmClassifyTop5());
    }
}
