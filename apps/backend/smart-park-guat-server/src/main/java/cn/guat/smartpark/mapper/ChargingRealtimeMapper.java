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
     * 批量插入充电实时数据记录
     * @param records 充电实时数据实体列表
     * @return 影响的行数
     */
    int batchInsert(@Param("records") List<ChargingRealtime> records);

    /**
     * 查询最近采集的充电实时数据
     * 按数据采集时间（collect_time）降序排列，默认返回最近的20条记录
     * @return 最近采集的充电实时数据列表（List<ChargingRealtime>）
     */
    @Select("select * from charging_realtime order by collect_time desc limit 15")
    List<ChargingRealtime> findRecent();

    /**
     * 查询所有充电实时数据
     * @return 所有充电实时数据列表（List<ChargingRealtime>）
     */
    @Select("select * from charging_realtime")
    List<ChargingRealtime> findAll();

    /**
     * 根据ID查询充电实时数据
     * @param id 充电实时数据ID
     * @return 匹配的充电实时数据对象（ChargingRealtime），如果不存在则返回null
     */
    @Select("select * from charging_realtime where id = #{id}")
    ChargingRealtime findById(Long id);
}


