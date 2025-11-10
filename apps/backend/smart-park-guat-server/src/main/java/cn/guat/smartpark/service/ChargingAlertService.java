package cn.guat.smartpark.service;

import cn.guat.smartpark.common.AlarmLevelEnum;

import cn.guat.smartpark.config.AlertThresholdConfig;
import cn.guat.smartpark.dto.AlarmListDto;
import cn.guat.smartpark.entity.ChargingAlarm;
import cn.guat.smartpark.entity.ChargingRealtime;
import cn.guat.smartpark.mapper.ChargingAlarmMapper;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;


/**
 * 充电桩异常告警服务类
 */

@Service
public class ChargingAlertService {

    @Resource
    private ChargingAlarmMapper chargingAlarmMapper;
    @Autowired
    private ChargingPileService chargingPileService;
    @Autowired
    private AlertThresholdConfig alertThresholdConfig;
    @Autowired
    private ChargingAlertHandlerService chargingAlertHandlerService;;


    //定时任务,每三十秒执行一次检测
    @Scheduled(fixedRate = 60000)
    public void detectAbnormal() {
        List<ChargingRealtime> allPileData = chargingPileService.getAllPileData();
        for (ChargingRealtime pile : allPileData){
            checkAndHandlerAlert(pile);
        }
    }

    private  void checkAndHandlerAlert(ChargingRealtime charge) {
        //获取设备id
        String deviceID = charge.getDeviceId();
        //1.检测过压
        if (charge.getVoltage() != null && charge.getVoltage().compareTo(alertThresholdConfig.getMaxVoltage()) > 0) {
            chargingAlertHandlerService.triggerAlert(
                    deviceID,
                    "over_voltage",
                    charge.getVoltage(),
                    alertThresholdConfig.getMaxVoltage());
            }
        //2.检测过流
        if(charge.getCurrent() != null && charge.getCurrent().compareTo(alertThresholdConfig.getMaxCurrent()) > 0){
            chargingAlertHandlerService.triggerAlert(
                    deviceID,
                    "over_current",
                    charge.getCurrent(),
                    alertThresholdConfig.getMaxCurrent());
        }
        //3.检测过温
        if (charge.getTemperature() != null && charge.getTemperature().compareTo(alertThresholdConfig.getMaxTemperature()) > 0){
            chargingAlertHandlerService.triggerAlert(
                    deviceID,
                    "over_temp",
                    charge.getTemperature(),
                    alertThresholdConfig.getMaxTemperature());
        }
        //4.检测掉线
        Date collectTimeDate = charge.getCollectTime();
        Date now = new Date();
        long diffMills = now.getTime() - collectTimeDate.getTime();
        long minutesDiff = diffMills / (1000 * 60);
        if ((minutesDiff ) > alertThresholdConfig.getOffLineMinutes()){
            chargingAlertHandlerService.triggerAlert(
                    deviceID,
                    "offline",
                    new BigDecimal(minutesDiff),
                    new BigDecimal(alertThresholdConfig.getOffLineMinutes()));
        }
        }

    /**
     * 查询充电桩告警列表,挑选需要的字段放入
     * @return
     */
    public List<AlarmListDto> getAlarmList(){
        List<ChargingAlarm> alarmList = chargingAlarmMapper.findAll();
        return alarmList.stream().map(item -> {
            AlarmListDto dto = new AlarmListDto();
            BeanUtils.copyProperties(item,dto);
            dto.setAlarmLevel(AlarmLevelEnum.getChineseNameByCode(item.getAlarmLevel()));
            return dto;
        }).collect(Collectors.toList());
    }

    /**
     * 更新充电桩告警信息
     *
     * @param alarmListDto
     */
    public void updateSelective(AlarmListDto alarmListDto) {
        // 关键：将前端传递的中文告警等级转换为整数
        if (alarmListDto.getAlarmLevel() != null) {
            String levelStr = alarmListDto.getAlarmLevel();
            Integer levelCode = null;
            if ("普通".equals(levelStr)) {
                levelCode = AlarmLevelEnum.NORMAL.getCode(); // 1
            } else if ("严重".equals(levelStr)) {
                levelCode = AlarmLevelEnum.SERIOUS.getCode(); // 2
            } else {
                throw new IllegalArgumentException("无效的告警等级：" + levelStr);
            }
            alarmListDto.setAlarmLevelCode(levelCode); // 新增字段用于传递int值
        }
        chargingAlarmMapper.updateSelective(alarmListDto);
    }

    /**
     * 删除充电桩告警信息
     * @param id
     */
    public void delete(Long id) {
        chargingAlarmMapper.delete(id);
    }

    /**
     * 根据ID返回数据跟前端
     * @param id
     * @return
     */
    public ChargingAlarm getById(Long id) {
        return chargingAlarmMapper.getById(id);
    }
}



