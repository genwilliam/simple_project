package cn.guat.smartpark.service;


import cn.guat.smartpark.mapper.AlarmMapper;
import com.alibaba.fastjson2.JSONObject;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * 告警服务类
 * 提供告警相关的业务逻辑处理
 */


@Service
public class AlarmService {
    @Resource
    private AlarmMapper alarmMapper;

    /**
     * 驾驶舱2-告警事件预览
     * 告警级别分布（紧急、重要、一般）饼图
     *
     * @return 返回包含告警级别分布
     */
    public JSONObject alarmLevel() {
        JSONObject result = new JSONObject();
        //告警级别分布
        List<JSONObject> jsonList = alarmMapper.alarmLevel();
        jsonList.forEach(json -> {
            switch (json.getInteger("level")) {
                case 1:
                    json.put("name", "紧急");
                    break;
                case 2:
                    json.put("name", "次要");
                    break;
                case 3:
                    json.put("name", "一般");
                    break;
            }
        });
        result.put("alarmLevel", jsonList);
        return result;
    }

    /**
     * 驾驶舱2-告警事件预览
     * TOP5告警类型（如空调故障、电源异常、网络中断等。）
     *
     * @return 返回TOP5告警类型的JSON对象
     */
    public JSONObject AlarmClassifyTop5() {
        JSONObject result = new JSONObject();
        //TOP5告警类型（如空调故障、电源异常、网络中断等。
        List<JSONObject> top5 = alarmMapper.AlarmClassifyTop5();
        result.put("globalAlarmClassifyTop5", top5);
        return result;
    }
}
