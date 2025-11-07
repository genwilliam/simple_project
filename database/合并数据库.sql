-- 这版相对原先的来说，合并了charge库和platform_smart_park数据库，基本功能没变，但是做了如下改变：
#   一、合并两个库的用户表，依旧是charging_user表，不过加了三个字段，分别是user_id、email和sex。对于email我并未设置任何约束，所以乱填也是可以的；sex我设置了必须为1和2，1男2女
#   二、直接把platform_smart_park库里面的sp_alarm表完完全全copy过来了，什么都没改，也没有和charge库里面的任何表做联动

# 设置会话参数
SET NAMES  utf8mb4;/*字符集统一*/
SET FOREIGN_KEY_CHECKS = 0;/*临时禁用外键约束检查*/
SET AUTOCOMMIT = 0;/*自动提交事务关闭*/

-- -------------------------------------------
# 一、创建数据库
DROP DATABASE IF EXISTS charge;
CREATE DATABASE charge
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;/*表示该表或字段采用 utf8mb4_unicode_ci 排序规则*/

USE charge;

-- -------------------------------------------
# 二、建表
# 2.1 charging_realtime（充电桩实时数据表）
CREATE TABLE IF NOT EXISTS charging_realtime(
    id BIGINT UNSIGNED AUTO_INCREMENT COMMENT '自增主键，非负',
    device_id VARCHAR(32) NOT NULL COMMENT '充电桩编号',
    status TINYINT NOT NULL  COMMENT '运行状态：0空闲，1充电，2故障，3离线',
    voltage DECIMAL(8,2) NULL COMMENT '当前电压（V）',
    current DECIMAL(8,2) NULL COMMENT '当前电流（A）',
    power DECIMAL(10,2) NULL COMMENT '实时功率（W）',
    temperature DECIMAL(5,2) NULL COMMENT '设备温度（℃）',
    collect_time DATETIME NOT NULL COMMENT '采集时间',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

#   创建主键id
    PRIMARY KEY (id),
#   普通索引
    INDEX idx_device_id (device_id),
    INDEX idx_collect_time (collect_time),
    INDEX idx_status (status),
    INDEX idx_device_status (device_id, status),
#   创建外键和检查 当前电压（V），当前电流（A），实时功率（W），设备温度（℃）
#   运行状态：0 空闲，1 充电，2 故障，3 离线
    CONSTRAINT chk_status CHECK ( status IN (0, 1, 2, 3) ),
#   电压可为空，区间[0,9999]
    CONSTRAINT chk_voltage CHECK ( voltage IS NULL OR (voltage >= 0 AND voltage <=9999)),
#   电流可为空，区间[0,9999]
    CONSTRAINT chk_current CHECK ( current IS NULL OR (current >= 0 AND current <= 9999)),
#   功率可为空，区间[0,99980001]
    CONSTRAINT chk_power CHECK ( power IS NULL OR (power >= 0 AND power <= 99980001)),
#   设备温度可为空，区间[-40,200]
    CONSTRAINT chk_temperature CHECK ( temperature IS NULL OR (temperature >= -40 AND temperature <=200))

) /*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '充电桩实时数据表';

# 表2.1索引——不需要了
# CREATE INDEX idx_device_id ON charging_realtime(device_id);
/*为device_id（充电桩编号）创建名为idx_device_id的索引*/
# CREATE INDEX idx_collect_time ON charging_realtime(collect_time);
/*为collect_time（采集时间）创建名为idx_collect_time的索引*/


# 2.2 charging_history（充电桩历史数据表）
CREATE TABLE IF NOT EXISTS charging_history(
    id BIGINT UNSIGNED AUTO_INCREMENT COMMENT '自增主键,非负',
    device_id VARCHAR(32) NOT NULL COMMENT '设备编号',
    voltage_avg DECIMAL(8,2) NULL COMMENT '平均电压',
    current_avg DECIMAL(8,2) NULL COMMENT '平均电流',
    power_avg DECIMAL(10,2) NULL COMMENT '平均功率',
    energy_total DECIMAL(12,3) NULL COMMENT '累计充电量（kWh）',
    record_time DATETIME NOT NULL COMMENT '记录时间（统计周期）',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (id),
#   普通索引 设备编号，记录时间（统计周期）
    INDEX idx_device_id (device_id),
    INDEX idx_record_time (record_time),
#   设置唯一索引，因为同一时间只能有一条相同的数据
    UNIQUE INDEX uk_device_time (device_id, record_time),
#   设置外键和检查
#   平均电压区间[0，1000]
    CONSTRAINT chk_voltage_avg CHECK ( voltage_avg IS NULL OR (voltage_avg >= 0 AND voltage_avg <=1000)),
#   平均电流区间[0，200]
    CONSTRAINT chk_current_avg CHECK ( current_avg IS NULL OR (current_avg >= 0 AND current_avg <= 200)),
#   平均功率区间[0，100000]
    CONSTRAINT chk_power_avg CHECK ( power_avg IS NULL OR(power_avg >= 0 AND power_avg <= 100000)),
#   累计充电量区间[0，999999.999]
    CONSTRAINT chk_energy_total CHECK ( energy_total IS NULL OR (energy_total >=0 AND energy_total <= 999999.999))

) /*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '充电桩历史数据表';


# 2.3 charging_alarm（充电桩告警记录表）
DROP TABLE IF EXISTS charging_alarm;
CREATE TABLE IF NOT EXISTS charging_alarm(
    id BIGINT UNSIGNED AUTO_INCREMENT COMMENT '自增主键',
    device_id VARCHAR(32) NOT NULL COMMENT '设备编号',
    alarm_type VARCHAR(20) NOT NULL COMMENT '告警类型（over_voltage / over_current / over_temp / offline）',
    alarm_value DECIMAL(10,2) NULL COMMENT '触发值',
    threshold DECIMAL(10,2) NULL COMMENT '阈值参考',
    alarm_level TINYINT DEFAULT 1 COMMENT '告警等级（1普通，2严重）',
    alarm_time DATETIME NOT NULL COMMENT '告警时间',
    status TINYINT DEFAULT 0 COMMENT '处理状态（0未处理，1处理中，2已处理）',
    handler VARCHAR(50) NULL COMMENT '处理人',
    remark VARCHAR(255) NULL COMMENT '处理备注',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (id, alarm_time),
#   设置索引
#   普通索引，设备id和告警类型
    INDEX idx_device_alarm (device_id, alarm_type),
#   普通索引，设备状态(0未处理，1处理中，2已处理)
    INDEX idx_status (status),
    INDEX idx_alarm_time (alarm_time),
    INDEX idx_alarm_level (alarm_level),

#   设置外键和检查，
#   是否处于这四种状态
    CONSTRAINT chk_alarm_type CHECK ( alarm_type IN('over_voltage', 'over_current', 'over_temp', 'offline') ),
#   触发值区间[0，999999.999]
    CONSTRAINT chk_alarm_value CHECK ( alarm_value IS NULL OR (alarm_value >= 0 AND alarm_value <= 999999.999)),
#   阈值参考区间[0，999999.999]
    CONSTRAINT chk_threshold CHECK ( threshold IS NULL OR (threshold >= 0 AND threshold <= 999999.999)),
#   告警等级处于1或2
    CONSTRAINT chk_alarm_level CHECK ( alarm_level IN(1, 2) ),
#   告警状态处于0或1或2
    CONSTRAINT chk_alarm_status CHECK ( status IN(0, 1, 2))

) /*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '充电桩历史数据表';

# 2.4 charging_control（充电桩控制指令记录表）
DROP TABLE IF EXISTS charging_control;
CREATE TABLE IF NOT EXISTS charging_control(
    id BIGINT UNSIGNED AUTO_INCREMENT COMMENT '自增主键，非负',
    device_id VARCHAR(32) NOT NULL COMMENT '设备编号',
    command VARCHAR(20) NOT NULL COMMENT '控制命令（start / stop）',
    command_code VARCHAR(64) NULL COMMENT '加密后的指令码',
    operator VARCHAR(50) NOT NULL COMMENT '操作人',
    execute_status TINYINT DEFAULT 0 COMMENT '执行状态（0待执行、1成功、2失败）',
    execute_time DATETIME NOT NULL COMMENT '执行时间',
    result_msg VARCHAR(255) NULL COMMENT '硬件返回时间',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (id, execute_time),
#   普通索引
    INDEX idx_device_command (device_id, execute_status),
    INDEX idx_operator (operator),
    INDEX idx_execute_time (execute_time),
#   外键和检查
    CONSTRAINT chk_command CHECK ( command IN('start', 'stop') ),
    CONSTRAINT chk_execute_status CHECK ( execute_status IN(0, 1, 2) )

) /*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '充电桩控制指令记录表';


# 2.5 charging_user（运维用户表）
DROP TABLE IF EXISTS charging_user;
CREATE TABLE IF NOT EXISTS charging_user(
    id BIGINT UNSIGNED AUTO_INCREMENT COMMENT 'PK,自增主键',
#   user_id BIGINT UNSIGNED NOT NULL DEFAULT 3 COMMENT '用户id，手动添加，默认为3，也就是只读',
    user_name VARCHAR(50) NOT NULL COMMENT '登录用户名',
    password VARCHAR(128) NOT NULL COMMENT '加密密码（不可明文）',
    role VARCHAR(20) NULL COMMENT '用户角色（admin/operator/viewer）',
    phone VARCHAR(20) NULL COMMENT '手机号（用于告警短信）',
    email VARCHAR(255) NULL COMMENT '邮箱',
    sex INT NULL COMMENT '性别，1男 2女',
    status TINYINT DEFAULT 1 COMMENT '用户状态（1启用，0禁用）',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (id),
#   唯一索引

    UNIQUE INDEX uk_user_name (user_name),
    INDEX idx_role (role),
    INDEX idx_status (status),
#   外键和检查

    CONSTRAINT chk_role CHECK ( role IN('admin', 'operator', 'viewer')),
    CONSTRAINT chk_user_status CHECK ( status IN(0, 1) ),
    CONSTRAINT chk_phone CHECK ( phone IS NULL OR LENGTH(phone) >= 11)

#   邮箱和性别不设置检查约束了，前后端自己加

) /*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '运维用户表';


# 2.6 charging_log（系统操作日志表）
DROP TABLE IF EXISTS charging_log;
CREATE TABLE IF NOT EXISTS charging_log(
    id BIGINT UNSIGNED AUTO_INCREMENT COMMENT 'PK，自增',
    user VARCHAR(50) NOT NULL COMMENT '操作用户',
    module VARCHAR(50) NOT NULL COMMENT '操作模块（data_collect, control, alert等）',
    action VARCHAR(255) NOT NULL COMMENT '执行动作说明',
    result VARCHAR(255) NULL COMMENT '结果描述',
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '日志时间',
    ip_address VARCHAR(50) NULL COMMENT '操作来源IP',

    PRIMARY KEY (id, log_time),
#   普通索引
    INDEX idx_user (user),
    INDEX idx_module (module),
    INDEX idx_log_time (log_time),
    INDEX idx_ip_address (ip_address)

) /*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '系统操作日志表';

# 2.7 园区预警（直接从smart_park库里面copy过来的，啥都没改）
    create table sp_alarm
(
    id          bigint auto_increment primary key comment '告警记录ID',
    station_id  bigint                        null comment '站点/园区ID',
    room_id     bigint                        null comment '告警机房ID',
    cabinet_id  bigint                        null comment '告警机柜ID （机柜设备告警时必填）',
    device_id   bigint                        not null comment '告警设备ID',
    status      int                           null comment '告警状态 0结束告警 1正在告警',
    level       int                           null comment '告警类型 1紧急告警Critical 2次要告警Minor 3一般告警',
    type        varchar(255) default '1'      not null comment '告警类型 1紧急告警Critical 2次要告警Minor 3一般告警',
    content     varchar(255)                  not null comment '告警内容',
    tenant_id   varchar(20)  default '000000' null comment '租户编号',
    dept_id     bigint                        null comment '部门ID',
    del_flag    char         default '0'      null comment '删除标志（0代表存在 2代表删除）',
    create_dept bigint                        null comment '创建部门',
    create_by   bigint                        null comment '创建者',
    create_time datetime                      null comment '创建时间',
    update_by   bigint                        null comment '更新者',
    update_time datetime                      null comment '更新时间',
    remark      varchar(500)                  null comment '备注'
)/*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci comment '告警表' row_format = DYNAMIC;

# 2.8 创建用户权限编码表
DROP TABLE IF EXISTS permission;
CREATE TABLE IF NOT EXISTS permission(
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY  COMMENT '自增主键',
    permission_code VARCHAR(32) NOT NULL  UNIQUE COMMENT '权限编码',
    permission_name VARCHAR(64) NOT NULL COMMENT '权限名称',

    -- 给 permission 表的 permission_code 加唯一索引
    UNIQUE INDEX uk_permission_code (permission_code)
)/*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '权限字典表';

# 2.9
DROP TABLE IF EXISTS user_permission;
CREATE TABLE IF NOT EXISTS user_permission(
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '自增主键',
    user_id BIGINT UNSIGNED NOT NULL  COMMENT '用户ID',
    permission_code VARCHAR(32) NOT NULL COMMENT '权限编码',

#   设置外键,user_permission
    CONSTRAINT fk_up_user FOREIGN KEY (user_id) REFERENCES charging_user(id),
    CONSTRAINT fk_up_permission FOREIGN KEY (permission_code) REFERENCES permission(permission_code)

)/*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '用户-权限关联表';

# 三、不写外键了，避免高并发场景的性能问题
-- -------------------------------------------------
# 四、创建视图
# 4.1 充电桩实时状态视图
# 可以查看记录ID，设备编号，设备运行状态，设备电压、电流、功率、温度，采集时间，记录创建时间 6个类型的数据
CREATE OR REPLACE VIEW v_charging_realtime_status AS
SELECT
    cr.id AS 记录ID, cr.device_id AS 设备编号,
# 不用 if 嵌套，流程控制语句CASE语句的核心作用是实现 “条件判断与值转换”，多条件分支更适合用CASE；case流程函数语句用end结尾，case流程控制语句用end case结尾
# 运行状态：0=空闲，1=充电，2=故障，3=离线
    CASE cr.status
        WHEN 0 THEN '空闲'
        WHEN 1 THEN '充电'
        WHEN 2 THEN '故障'
        WHEN 3 THEN '离线'
        ELSE '未知'
    END AS 设备状态,
# 告诉现在需要输出什么语句方便理解，用字符拼接函数
# 流程函数IFNULL，如果value不为空，返回value值1，否则返回value2，例如IFNULL(value1, value2)
    CONCAT(IFNULL(cr.voltage,0),'V') AS 设备电压,
    CONCAT(IFNULL(cr.current,0),'A')AS 设备电流,
    CONCAT(IFNULL(cr.power,0),'W')AS 设备功率,
    CONCAT(IFNULL(cr.temperature,0),'℃')AS 设备温度,
    cr.collect_time AS 采集时间,
    cr.create_time AS 记录创建时间
# 充电桩实时数据表
FROM charging_realtime AS cr
# 根据采集时间，降序排序
ORDER BY cr.collect_time DESC;

# 4.2 告警统计视图
CREATE OR REPLACE VIEW v_charging_alarm AS
SELECT
    ca.device_id AS 设备编号,
    ca.alarm_type AS 告警类型,
#   ca.alarm_level AS 告警等级, 是否需要将阈值参考加入进来确认是什么等级
    COUNT(*) AS 告警次数,
#   THEN 后面写 1 并非固定要求，换成其他数字甚至非数字，结果都是完全相同的。核心原因在于 COUNT() 函数的统计逻辑 —— 它只关心 “括号内的值是否为非 NULL”，而非具体数值
    COUNT(CASE WHEN ca.status = 0 THEN 1 END) AS 未处理,
    COUNT(CASE WHEN ca.status = 1 THEN 1 END) AS 处理中,
    COUNT(CASE WHEN ca.status = 2 THEN 1 END) AS 已处理,
    MAX(ca.alarm_time) AS 最新告警时间
FROM charging_alarm AS ca
# 使用分组查询是因为我们需要根据告警的类型来区分，我需要知道每一种告警发生了多少次，所以才做的视图并且用GROUP BY分组
GROUP BY ca.device_id, ca.alarm_type;

# 4.3 设备使用率统计试图
CREATE OR REPLACE VIEW v_device_usage_rate AS
SELECT
    cr.device_id AS 设备编号,
    COUNT(*) AS 总记录数,
    COUNT(CASE WHEN cr.status = 1 THEN 1 END) AS 设备充电中次数,
    ROUND(COUNT(CASE WHEN cr.status = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS 设备使用率,
    MAX(cr.collect_time) AS 最后记录时间
FROM charging_realtime cr
WHERE cr.collect_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY cr.device_id;


-- --------------------------------------------
# 五、存储过程
# 5.1 数据采集存储过程
DELIMITER //
CREATE PROCEDURE sp_collect_charging_data(
    IN p_device_id VARCHAR(32),
    IN p_status TINYINT,
    IN p_voltage DECIMAL(8,2),
    IN p_current DECIMAL(8,2),
    IN p_power DECIMAL(10,2),
    IN p_temperature DECIMAL(5,2),
    IN p_collect_time DATETIME
)
BEGIN
#   当SQL语句有异常时中断进程，指定触发处理器的条件为 “任何 SQL 异常”（如语法错误、主键冲突、外键约束失败、数据类型不匹配等）
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

#   开启事务
    START TRANSACTION;

#   开始插入数据，存储过程的变量加入到charging_realtime表中
    INSERT INTO charging_realtime
        (device_id, status, voltage, current, power, temperature, collect_time)
    VALUES
        (p_device_id, p_status, p_voltage, p_current ,p_power, p_temperature, p_collect_time);

#   系统自动记录操作日志
    INSERT INTO charging_log
        (user, module, action, result, ip_address)
    VALUES
#       user变成SYSTEM是为了区分自动保存日志和手动保存日志的区别，这里是利用插入数据这个行为直接让系统保存插入日志;
#       data_collect是module的一种类型，说明这次操作的类型是收集数据
#       ip地址定死了，暂时不变化
        ('SYSTEM', 'data_collect', CONCAT('采集设备编号：', p_device_id), 'SUCCESS', '10.1.2.3');

#   提交事务
    COMMIT;

END //
DELIMITER ;

#  5.2 告警过程存储过程
DELIMITER //
CREATE PROCEDURE sp_handle_alarm(
    IN p_alarm_id VARCHAR(32),
    IN p_handler VARCHAR(50),
    IN p_remark VARCHAR(255)
)
BEGIN
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
       BEGIN
          ROLLBACK;
          RESIGNAL;
       END ;

#  开启事务
   START TRANSACTION;

#  告警状态更新，这里默认一次性处理完成后调用该存储过程，而不分阶段，所以状态码为2
    UPDATE charging_alarm
    SET status = 2, handler = p_handler, remark = p_remark
    WHERE id = p_alarm_id;

#   系统自动记录操作日志
    INSERT INTO charging_log (user, module, action, result, ip_address)
    VALUES (p_handler, 'alert', CONCAT('告警处理ID', p_alarm_id),'SUCCESS', '10.1.2.3');

   COMMIT;
END //
DELIMITER ;

# 5.3 历史数据归档(archive) 存储过程
DROP PROCEDURE IF EXISTS sp_archive_history_data;
DELIMITER //
CREATE PROCEDURE sp_archive_history_data()
BEGIN
#  抛出异常
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END ;

    START TRANSACTION;

#   7天前的实时数据归档到charging_history
    INSERT INTO charging_history (device_id, voltage_avg, current_avg, power_avg, energy_total, record_time)
    SELECT
        cr.device_id,
        AVG(cr.voltage) AS voltage_avg,
        AVG(cr.current) AS current_avg,
        AVG(cr.power) AS power_avg,
#       30s采集一次，功率单位kWh
        SUM(power * 0.5 / 1000) AS energy_total,
        DATE(collect_time) AS record_time
    FROM charging_realtime cr
    WHERE collect_time < DATE_SUB(NOW(), INTERVAL 7 DAY)
    GROUP BY device_id, DATE(collect_time);

#   删除已归档的实时数据
    DELETE FROM charging_realtime WHERE collect_time < DATE_SUB(NOW(), INTERVAL 7 DAY);

#   系统自动记录归档日志
    INSERT INTO charging_log (user, module, action, result, ip_address)
    VALUES ('SYSTEM', 'data_archive'/*归档*/, '历史数据7天归档','SUCCESS', '10.1.2.3');

    COMMIT;
END //
DELIMITER ;

-- -------------------------------------------------
# 六、函数
# 6.1 计算设备使用率函数
DELIMITER //
CREATE FUNCTION fn_calculate_usage_rate(p_device_id VARCHAR(32), p_hours INT)
    RETURNS DECIMAL(5,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_total_count INT DEFAULT 0;
    DECLARE v_charging_count INT DEFAULT 0;
    DECLARE v_usage_rate DECIMAL(5,2) DEFAULT 0;

    SELECT COUNT(*) INTO v_total_count
    FROM charging_realtime
    WHERE device_id = p_device_id AND collect_time >= DATE_SUB(NOW(), INTERVAL p_hours HOUR);

    SELECT COUNT(*) INTO v_charging_count
    FROM charging_realtime
    WHERE device_id = p_device_id AND status = 1 AND collect_time >= DATE_SUB(NOW(), INTERVAL p_hours HOUR);

    IF v_total_count > 0 THEN
        SET v_usage_rate = ROUND(v_charging_count * 100.0 / v_total_count, 2);
    END IF;

    RETURN v_usage_rate;
END //
DELIMITER ;

# 6.2 检查设备状态函数
DELIMITER //
CREATE FUNCTION fn_check_device_status(p_device_id VARCHAR(32))
RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_status TINYINT DEFAULT 3; /*默认离线状态*/
    DECLARE v_status_name VARCHAR(20) DEFAULT '离线';

    SELECT status INTO v_status
    FROM charging_realtime
    WHERE device_id = p_device_id
    ORDER BY collect_time DESC
    limit 1;

    CASE v_status
        WHEN 0 THEN SET v_status_name = '空闲';
        WHEN 1 THEN SET v_status_name = '充电';
        WHEN 2 THEN SET v_status_name = '故障';
        WHEN 3 THEN SET v_status_name = '离线';
        ELSE SET v_status_name = '未知';
    END CASE;

    RETURN v_status_name;
END //
DELIMITER ;

-- -------------------------------------------------
# 七、触发器
# SHOW TRIGGERS FROM charge;
# 7.1 数据更新触发器
DROP TRIGGER IF EXISTS tr_charging_realtime_after_insert;
DELIMITER //
CREATE TRIGGER tr_charging_realtime_after_insert
AFTER INSERT ON charging_realtime
FOR EACH ROW
BEGIN
#   插入或更改数据时注意是否触发告警提示
#   例如 电压>300V就是高压电了，电流>50A，温度>60℃
    IF NEW.voltage >= 300 THEN
        INSERT INTO charging_alarm(device_id, alarm_type, alarm_value, threshold, alarm_time)
        VALUES (NEW.device_id, 'over_voltage', NEW.voltage, 300, NEW.collect_time);
    END IF;

    IF NEW.current >= 50 THEN
        INSERT INTO charging_alarm(device_id, alarm_type, alarm_value, threshold, alarm_time)
        VALUES (NEW.device_id, 'over_current', NEW.current, 50, NEW.collect_time);
    END IF;

    IF NEW.temperature >= 60 THEN
        INSERT INTO charging_alarm(device_id, alarm_type, alarm_value, threshold, alarm_time)
        VALUES (NEW.device_id, 'over_temp', NEW.temperature, 60, NEW.collect_time);
    END IF;

END//
DELIMITER ;

# 7.2 控制指令执行触发器
DROP TRIGGER IF EXISTS tr_charging_control_after_update;
DELIMITER //
CREATE TRIGGER tr_charging_control_after_update
AFTER UPDATE ON charging_control
FOR EACH ROW
BEGIN
    INSERT INTO charging_log(user, module, action, result, ip_address)
    VALUES (
        NEW.operator,
        'control',
        CONCAT('执行控制指令：', NEW.command, '；设备：', NEW.device_id),
        CASE NEW.execute_status
            WHEN 1 THEN 'SUCCESS'
            WHEN 2 THEN 'FAILED'
            ELSE 'PENDING'/*挂起中。某个操作或任务已被发起，但尚未执行完成、未得到最终结果，处于等待处理的中间状态*/
        END,
        '10.1.2.3'
           );
END//
DELIMITER ;

-- ---------------------------------------------
# 八、定时任务，事件调度器
# 8.1 启动事件调动器
SET GLOBAL event_scheduler = ON;

# 8.2 历史数据自动归档事件
CREATE EVENT ev_archive_history_data
ON SCHEDULE EVERY 1 DAY
# 每天凌晨3点自动执行
STARTS '2025-10-24 03:00:00'
DO
CALL sp_archive_history_data();

# 8.3创建日志清理事件，清理30天前的日志
CREATE EVENT ev_cleanup_old_30days_logs
ON SCHEDULE EVERY 1 DAY
STARTS '2025-10-24 03:00:00'
DO
DELETE FROM charging_log WHERE log_time < DATE_SUB(NOW(), INTERVAL 30 DAY);


-- --------------------------------------------------
# 九、插入初始数据
# 9.1 插入3个默认管理员，密码使用MD5+salt加密
DELETE FROM charging_user;
INSERT INTO charging_user(user_name, password, role, phone, email, sex, status)
VALUES
('admin', MD5(CONCAT('charge_salt_2025_', 'admin123')), 'admin', '18559113752', '123@1qq.com', 1, 1),/*管理员启用*/
('operator', MD5(CONCAT('charge_salt_2025_', 'operator123')), 'operator', '13366167958', '124@2qq.com', 1, 1),/*操作人员启用*/
('viewer', MD5(CONCAT('charge_salt_2025_', 'viewer123')), 'viewer', '13615978848', '125@3qq.com', 2, 1);/*只读用户*/

# 9.2 插入示例数据
INSERT INTO charging_realtime(device_id, status, voltage, current, power, temperature, collect_time)
VALUES
#   功率P = 电流 * 电压
#   0：空闲
('CP0001', 0, 220.4, 0.0, 0.0, 23.4, NOW()),
#   1：充电
('CP0002', 1, 220.0, 20, 4400.0, 30.5, NOW()),
#   2：故障
('CP0003', 2, 0.0, 0.0, 0.0, 50, NOW()),
#   3：离线
('CP0004', 3, NULL, NULL, NULL, NULL, NOW());

# 插入权限数据
-- 初始化三种基础权限
INSERT INTO permission (permission_code, permission_name) VALUES
('CHARGING_QUERY', '充电桩查询权限'),
('CHARGING_MANAGE', '充电桩管理权限'),
('USER_VIEW', '用户信息查看权限');

-- admin分配所有权限
INSERT INTO user_permission (user_id, permission_code)
VALUES
(1, 'CHARGING_QUERY'),
(1, 'CHARGING_MANAGE'),
(1, 'USER_VIEW');

-- operator分配部分权限
INSERT INTO user_permission (user_id, permission_code)
VALUES
(2, 'CHARGING_QUERY'),
(2, 'CHARGING_MANAGE');

-- viewer分配只读权限
INSERT INTO user_permission (user_id, permission_code)
VALUES
(3, 'CHARGING_QUERY'),
(3, 'USER_VIEW');


-- -------------------------------------------------
# 十、创建数据库用户及权限授予
# 10.1 创建operator应用用户
CREATE USER IF NOT EXISTS
'charge_app'@'%' IDENTIFIED BY 'app123';
GRANT SELECT, INSERT, UPDATE, DELETE ON charge.* TO 'charge_app'@'%';

# 10.2 创建view只读用户
CREATE USER IF NOT EXISTS
'charge_read'@'%' IDENTIFIED BY 'read123';
GRANT SELECT ON charge.* TO 'charge_read'@'%';

# 10.3 创建admin管理员用户
CREATE USER IF NOT EXISTS
'charge_admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON charge.* TO 'charge_admin'@'%';

-- -------------------------------------------
# 十一、性能优化
# 11.1 创建分区表（按月分区charging_log表）
ALTER TABLE charging_log
PARTITION BY RANGE (YEAR(log_time) * 100 + MONTH(log_time)) (
#   2025.10及其之后的月份
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
#   26年的数据全部存在 p_future
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

# 11.2 为charging_alarm 告警表添加按时间分区
ALTER TABLE charging_alarm
PARTITION BY RANGE (YEAR(alarm_time) * 100 + MONTH(alarm_time)) (
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

# 11.3 为charging_control 控制表添加按时间分区
ALTER TABLE charging_control
PARTITION BY RANGE (YEAR(execute_time) * 100 + MONTH(execute_time)) (
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ---------------------------------------------
# 十二、慢查询日志及其监控, 还是在配置文件里面改，这里就不写性能了
# 12.1 慢日志查询配置
# SHOW VARIABLES LIKE 'slow_query_log';
# # 慢查询时间阈值3s
# SET GLOBAL long_query_time = 3;
# # 记录没有索引的查询
# SET GLOBAL log_queries_not_using_indexes = 'ON';
# # 记录慢管理语句
# SET GLOBAL log_slow_admin_statements = 'ON';

# 12.2 提高性能
# SET GLOBAL performance_schema = 'ON';
# -- 设置Performance Schema的最大表实例数
# SET GLOBAL performance_schema_max_table_instances = 10000;
# -- 设置Performance Schema的最大表句柄数
# SET GLOBAL performance_schema_max_table_handles = 10000;
#
# UPDATE performance_schema.setup_consumers SET ENABLED = 'YES';

# 12.3 连接和线程配置
# SET GLOBAL max_connections = 200;

# 插入realtime和sp_alarm数据
USE charge;
DELETE FROM charge.sp_alarm;
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (1, 1, 1, null, 1, null, 1, '服务器CPU温度过高', '服务器CPU温度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (2, 1, 1, null, 2, null, 2, '服务器内存使用率偏高', '服务器内存使用率偏高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (3, 1, 1, null, 3, null, 1, '服务器硬盘空间不足', '服务器硬盘空间不足', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (4, 1, 1, null, 4, null, 2, '服务器CPU温度异常', '服务器CPU温度异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (5, 1, 1, null, 5, null, 1, '服务器内存使用率过高', '服务器内存使用率过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (6, 1, 1, null, 6, null, 2, '服务器硬盘空间不足', '服务器硬盘空间不足', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (7, 1, 1, null, 7, null, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (8, 1, 1, null, 8, null, 2, '网络机柜湿度偏高', '网络机柜湿度偏高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (9, 1, 1, null, 9, null, 1, '网络机柜温度异常', '网络机柜温度异常', '000000', null, '0', null, null, '2025-09-18 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (10, 1, 1, null, 10, null, 2, '网络机柜湿度过高', '网络机柜湿度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (11, 1, 1, null, 11, null, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (12, 1, 2, null, 12, null, 2, '网络机柜湿度偏高', '网络机柜湿度偏高', '000000', null, '0', null, null, '2025-09-18 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (13, 1, 2, null, 13, null, 1, '网络机柜温度异常', '网络机柜温度异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (14, 1, 2, null, 14, null, 2, '网络机柜湿度过高', '网络机柜湿度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (15, 1, 2, null, 15, null, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (16, 1, 2, null, 16, null, 2, '网络机柜湿度偏高', '网络机柜湿度偏高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (17, 1, 1, null, 17, null, 1, '网络机柜温度异常', '网络机柜温度异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (18, 1, 1, null, 18, null, 2, '网络机柜湿度过高', '网络机柜湿度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (19, 1, 2, null, 19, null, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (20, 1, 1, null, 20, null, 2, '服务器CPU温度异常', '服务器CPU温度异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (21, 1, 2, null, 21, null, 1, '服务器内存使用率过高', '服务器内存使用率过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (22, 1, 1, null, 22, null, 2, '商用空调故障', '商用空调故障', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (23, 1, 2, null, 23, null, 1, '商用空调温度异常', '商用空调温度异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (24, 1, 1, null, 24, null, 2, '摄像头离线', '摄像头离线', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (25, 1, 2, null, 25, null, 1, '摄像头信号弱', '摄像头信号弱', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (26, 1, 1, null, 26, null, 2, '门禁系统故障', '门禁系统故障', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (27, 1, 2, null, 27, null, 3, '门禁系统识别异常', '门禁系统识别异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (28, 1, 1, null, 28, null, 3, '硬盘故障', '硬盘故障', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (29, 1, 2, null, 29, null, 1, '硬盘温度过高', '硬盘温度过高', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (30, 1, 1, null, 30, null, 2, '路由器故障', '路由器故障', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (31, 1, 2, null, 31, null, 1, '路由器端口异常', '路由器端口异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (32, 1, 1, null, 32, null, 2, '交换机故障', '交换机故障', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (33, 1, 2, null, 33, null, 1, '交换机端口拥塞', '交换机端口拥塞', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (34, 1, 1, null, 34, null, 2, 'UPS电源电压低', 'UPS电源电压低', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (35, 1, 2, null, 35, null, 1, 'UPS电源电池老化', 'UPS电源电池老化', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (36, 1, 1, null, 36, null, 2, '门禁系统通信异常', '门禁系统通信异常', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (37, 1, 1, null, 37, null, 1, '水浸传感器检测到水', '水浸传感器检测到水', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (38, 2, 1, null, 38, null, 2, '烟感传感器检测到烟雾', '烟感传感器检测到烟雾', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (39, 2, 1, null, 39, null, 1, '红外传感器检测到异常移动', '红外传感器检测到异常移动', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (40, 2, 1, null, 40, null, 2, '温度传感器故障', '温度传感器故障', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
INSERT INTO charge.sp_alarm (id, station_id, room_id, cabinet_id, device_id, status, level, type, content, tenant_id, dept_id, del_flag, create_dept, create_by, create_time, update_by, update_time, remark) VALUES (41, 2, 1, null, 41, null, 1, '湿度传感器故障', '湿度传感器故障', '000000', null, '0', null, null, '2025-09-16 11:02:53', null, null, null);
-- 从smart_park库里面搬过来的数据

USE charge;
DELETE FROM charging_realtime ;
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0001', 0, 220.40, 0.00, 0.00, 23.40, '2025-10-24 13:59:45', '2025-10-24 13:59:45', '2025-10-24 13:59:45');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0002', 1, 220.00, 20.00, 4400.00, 30.50, '2025-10-24 13:59:45', '2025-10-24 13:59:45', '2025-10-24 13:59:45');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0003', 2, 0.00, 0.00, 0.00, 50.00, '2025-10-24 13:59:45', '2025-10-24 13:59:45', '2025-10-24 13:59:45');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0004', 3, null, null, null, null, '2025-10-24 13:59:45', '2025-10-24 13:59:45', '2025-10-24 13:59:45');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0005', 1, 240.00, 11.00, 2640.00, 30.00, '2025-10-30 14:40:00', '2025-10-30 14:40:24', '2025-10-30 14:40:24');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0006', 1, 230.00, 21.46, 4935.80, 40.00, '2025-10-30 14:41:53', '2025-10-30 14:43:54', '2025-10-30 14:43:54');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0007', 1, 213.65, 31.47, 6723.57, 59.10, '2025-10-30 14:43:16', '2025-10-30 14:43:54', '2025-10-30 14:43:54');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0008', 2, 0.00, 100.00, 0.00, 90.00, '2025-10-30 14:43:51', '2025-10-30 14:43:54', '2025-10-30 14:43:54');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0009', 2, 777.00, 100.00, 77700.00, -40.00, '2025-10-30 14:44:58', '2025-10-30 14:49:04', '2025-10-30 14:49:04');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0010', 2, 1.00, 1.00, 1.00, 0.01, '2025-10-30 14:44:59', '2025-10-30 14:49:04', '2025-10-30 14:49:04');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0011', 3, null, null, null, null, '2025-10-30 14:44:22', '2025-10-30 14:49:04', '2025-10-30 14:49:04');
INSERT INTO charge.charging_realtime (device_id, status, voltage, current, power, temperature, collect_time, create_time, update_time) VALUES ('CP0012', 2, 1000.00, 100.00, 100000.00, -39.12, '2025-10-30 14:49:52', '2025-10-30 14:50:44', '2025-10-30 14:50:44');
-- 添加了多条不同状态的充电桩实时数据


# 恢复设置
SET FOREIGN_KEY_CHECKS = 1;
SET AUTOCOMMIT = 1;


-- 显示表结构统计
SELECT
    TABLE_NAME AS '表名',
    TABLE_COMMENT AS '表说明',
    TABLE_ROWS AS '预估行数',
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS '大小(MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'charge'
ORDER BY TABLE_NAME;




# # 查询设备实时状态
# SELECT * FROM v_charging_realtime_status WHERE 设备编号 = 'CP001';
# # 计算设备使用率
# SELECT fn_calculate_usage_rate('CP001', 24) AS 使用率;
# #  处理告警，日志记录到log
# CALL sp_handle_alarm(1, 'admin', '已现场检查，设备正常');
# # 采集数据，系统自动记录到log
# CALL sp_collect_charging_data('CP001', 1, 220.5, 15.2, 3350.0, 28.7, NOW());
