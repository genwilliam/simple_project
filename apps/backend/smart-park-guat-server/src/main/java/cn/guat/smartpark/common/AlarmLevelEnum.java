package cn.guat.smartpark.common;


import lombok.Getter;

@Getter
public enum AlarmLevelEnum {
    NORMAL(1, "普通"),
    SERIOUS(2, "严重");
    private Integer code;
    private String chineseName;

    AlarmLevelEnum(Integer code, String chineseName) {
        this.code = code;
        this.chineseName = chineseName;
    }

    // 根据数字编码获取中文描述
    public static String getChineseNameByCode(Integer code) {
        if (code == null) {
            return "未知级别"; // 处理空值
        }
        for (AlarmLevelEnum level : values()) {
            if (level.code.equals(code)) {
                return level.chineseName;
            }
        }
        return "未知级别"; // 处理未匹配的编码
    }

}
