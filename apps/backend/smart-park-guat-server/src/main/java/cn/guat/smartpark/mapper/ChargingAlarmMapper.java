package cn.guat.smartpark.mapper;

import cn.guat.smartpark.entity.ChargingAlarm;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;


@Mapper
public interface ChargingAlarmMapper {

    /**
     * 保存充电桩异常告警
     * @param chargingAlarm
     */
    @Select("insert into charging_alarm(device_id, alarm_type, alarm_value, threshold ,alarm_time) values(#{deviceId}, #{alarmType}, #{alarmValue}, #{threshold} , #{alarmTime})")
    public void save(ChargingAlarm chargingAlarm);

    /**
     * 获取充电桩异常告警列表
     * @return
     */
    @Select("select * from charging_alarm")
    public List<ChargingAlarm> findAll();

    /**
     * 更新充电桩告警信息,可选的动态修改
     * @param chargingAlarm
     */
   void updateSelective(ChargingAlarm chargingAlarm);

   /**
     * 获取未处理的告警
     * @param deviceId
     * @param alarmType
     * @return
     */
     ChargingAlarm getUnProcessedAlarm(@Param("deviceId") String deviceId, @Param("alarmType") String alarmType);


     /**
      * 删除充电桩异常告警
      * @param id
      */
    void delete(Long id);

    /**
     * 根据id获取充电桩异常告警
     * @param id
     * @return
     */
    ChargingAlarm getById(Long id);
}
