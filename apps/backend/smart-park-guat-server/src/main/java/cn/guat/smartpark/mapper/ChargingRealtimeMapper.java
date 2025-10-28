package cn.guat.smartpark.mapper;

import cn.guat.smartpark.entity.ChargingRealtime;
import org.apache.ibatis.annotations.*;
import java.util.List;

/**
 * 充电实时数据Mapper接口
 * 提供与充电实时数据表（charging_realtime）的交互方法，包括数据插入和最近记录查询
 */
@Mapper
public interface ChargingRealtimeMapper {

    /**
     * 插入一条充电实时数据记录
     * 将充电设备的实时状态数据（设备ID、状态、电压、电流等）插入到数据库表中
     * @param record 充电实时数据实体对象，包含待插入的字段值
     * @return 影响的行数（1表示插入成功，0表示插入失败）
     */
    @Insert("INSERT INTO charging_realtime(device_id,status,voltage,current,power,temperature,collect_time) " +
            "VALUES (#{deviceId},#{status},#{voltage},#{current},#{power},#{temperature},#{collectTime})")
    int insert(ChargingRealtime record);


    /**
     * 查询最近采集的充电实时数据
     * 按数据采集时间（collect_time）降序排列，默认返回最近的20条记录
     * @return 最近采集的充电实时数据列表（List<ChargingRealtime>）
     */
    @Select("SELECT * FROM charging_realtime ORDER BY collect_time DESC LIMIT 20")
    List<ChargingRealtime> findRecent();
}