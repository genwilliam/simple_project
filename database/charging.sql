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
#   电压可为空，区间[0,1000]
    CONSTRAINT chk_voltage CHECK ( voltage IS NULL OR (voltage >= 0 AND voltage <=1000)),
#   电流可为空，区间[0,200]
    CONSTRAINT chk_current CHECK ( current IS NULL OR (current >= 0 AND current <= 200)),
#   功率可为空，区间[0,100000]
    CONSTRAINT chk_power CHECK ( power IS NULL OR (power >= 0 AND power <= 100000)),
#   设备温度可为空，区间[-40,100]
    CONSTRAINT chk_temperature CHECK ( temperature IS NULL OR (temperature >= -40 AND temperature <=100))

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
CREATE TABLE IF NOT EXISTS charging_user(
    id BIGINT UNSIGNED AUTO_INCREMENT COMMENT 'PK,自增主键',
    username VARCHAR(50) NOT NULL COMMENT '登录用户名',
    password VARCHAR(128) NOT NULL COMMENT '加密密码（不可明文）',
    role VARCHAR(20) NOT NULL COMMENT '用户角色（admin/operator/viewer）',
    phone VARCHAR(20) NULL COMMENT '手机号（用于告警短信）',
    status TINYINT DEFAULT 1 COMMENT '用户状态（1启用，0禁用）',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (id),
#   唯一索引
    UNIQUE INDEX uk_username (username),
    INDEX idx_role (role),
    INDEX idx_status (status),
#   外键和检查
    CONSTRAINT chk_role CHECK ( role IN('admin', 'operator', 'viewer')),
    CONSTRAINT chk_user_status CHECK ( status IN(0, 1) ),
    CONSTRAINT chk_phone CHECK ( phone IS NULL OR LENGTH(phone) >= 11)

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
    ca.id AS 告警ID,
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

# 4.3


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


-- -------------------------------------------------
# 七、触发器
    SHOW TRIGGERS FROM charge;
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
        VALUES (NEW.device_id, 'over_temp', NEW.temperature, 70, NEW.collect_time);
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
# 9.1 插入3个默认管理员
INSERT INTO charging_user(username, password, role, phone, status)
VALUES
('admin', 'admin', 'admin', '18559113752', 1),/*管理员启用*/
('operator', 'operator', 'operator', '13366167958', 1),/*操作人员启用*/
('viewer', 'viewer', 'viewer', '13615978848', 1);/*只读用户*/

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
