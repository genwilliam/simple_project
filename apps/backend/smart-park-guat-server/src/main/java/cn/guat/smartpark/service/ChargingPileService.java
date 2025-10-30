package cn.guat.smartpark.service;

import cn.guat.smartpark.entity.ChargingRealtime;
import cn.guat.smartpark.mapper.ChargingRealtimeMapper;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;


/**
 * 充电桩服务类
 * 提供充电桩的实时数据查询
 */
@Service
public class ChargingPileService {
    @Resource
    private ChargingRealtimeMapper chargingRealtimeMapper;

    /**
     * 获取所有充电桩的实时数据
     * @return
     */
    public List<ChargingRealtime> getAllPileData(){
        return chargingRealtimeMapper.findAll();
    }

    /**
     * 根据ID获取充电桩的实时数据
     * @param id
     * @return
     */
    public ChargingRealtime getPileDataById(Long id){
        return chargingRealtimeMapper.findById(id);
    }
}
