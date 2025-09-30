package cn.guat.smartpark.mapper;

import com.alibaba.fastjson2.JSONObject;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 告警数据访问映射接口
 * 提供告警相关数据的查询操作
 */
@Mapper
public interface AlarmMapper {

    /**
     * 全国驾驶舱-统计告警数量
     * 按告警等级分组统计告警数量
     *
     * @return 返回包含告警等级和对应数量的列表
     */
    @Select("SELECT a.level,count(*) as `value` FROM sp_alarm a WHERE del_flag='0' GROUP BY a.level")
    public List<JSONObject> alarmLevel();

    /**
     * 全国驾驶舱-统计告警分类数量前五
     * 统计告警类型数量并按数量排序，取前5个
     *
     * @return 返回包含告警类型和对应数量的列表，最多5条记录
     */
    @Select("SELECT a.type,count(*) as count FROM sp_alarm a WHERE del_flag='0' GROUP BY a.type ORDER BY count desc limit 5")
    public List<JSONObject> AlarmClassifyTop5();
}
