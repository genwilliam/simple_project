package cn.guat.smartpark.mapper;

import cn.guat.smartpark.entity.ChargingRealtime;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface ChargingRealtimeMapper {

    // 批量插入数据（新增）
    int batchInsert(List<ChargingRealtime> records);

    List<ChargingRealtime> findRecent();
    List<ChargingRealtime> findAll();
    ChargingRealtime findById(Long id);
}


