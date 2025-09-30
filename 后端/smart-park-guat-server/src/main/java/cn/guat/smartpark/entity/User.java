package cn.guat.smartpark.entity;

import lombok.Data;

/**
 * 告警实体类
 * 用于表示系统中的告警信息
 */
@Data
public class User {
    private Long id;
    private String userName;
    private String password;
    private String phoneNumber;
    private String email;
    private Long sex;
    private Long status;
}
