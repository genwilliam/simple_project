package cn.guat.smartpark.controller;

import cn.guat.smartpark.common.R;
import cn.guat.smartpark.dto.AlarmListDto;
import cn.guat.smartpark.entity.ChargingAlarm;
import cn.guat.smartpark.service.ChargingAlertService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/charging/alert")
public class ChargingAlertController {

    @Resource
    private ChargingAlertService chargingAlertService;


    /**
     * 获取充电桩异常告警列表
     */
    @GetMapping("/list")
    public R<List<AlarmListDto>> list() {
        List<AlarmListDto> list = chargingAlertService.getAlarmList();
        return R.success(list);
    }

    /**
     * 更新充电桩告警信息
     */
    @PostMapping("/update")
    public R updateSelective(@RequestBody ChargingAlarm chargingAlarm) {
        chargingAlertService.updateSelective(chargingAlarm);
        return R.success();
    }

    /**
     * 删除充电桩告警信息
     * @param id
     * @return
     */
    @DeleteMapping("/delete/{id}")
    public R delete(@PathVariable Long id) {
        chargingAlertService.delete(id);
        return R.success();
    }

    @GetMapping("/get/{id}")
    public R<ChargingAlarm> get(@PathVariable Long id) {
        ChargingAlarm chargingAlarm = chargingAlertService.getById(id);
        return R.success(chargingAlarm);
    }
}
