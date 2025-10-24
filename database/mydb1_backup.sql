-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: localhost    Database: charge
-- ------------------------------------------------------
-- Server version	8.0.26

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `charging_alarm`
--

DROP TABLE IF EXISTS `charging_alarm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `charging_alarm` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `device_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '设备编号',
  `alarm_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '告警类型（over_voltage / over_current / over_temp / offline）',
  `alarm_value` decimal(10,2) DEFAULT NULL COMMENT '触发值',
  `threshold` decimal(10,2) DEFAULT NULL COMMENT '阈值参考',
  `alarm_level` tinyint DEFAULT '1' COMMENT '告警等级（1普通，2严重）',
  `alarm_time` datetime NOT NULL COMMENT '告警时间',
  `status` tinyint DEFAULT '0' COMMENT '处理状态（0未处理，1处理中，2已处理）',
  `handler` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '处理人',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '处理备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`,`alarm_time`),
  KEY `idx_device_alarm` (`device_id`,`alarm_type`),
  KEY `idx_status` (`status`),
  KEY `idx_alarm_time` (`alarm_time`),
  KEY `idx_alarm_level` (`alarm_level`),
  CONSTRAINT `chk_alarm_level` CHECK ((`alarm_level` in (1,2))),
  CONSTRAINT `chk_alarm_status` CHECK ((`status` in (0,1,2))),
  CONSTRAINT `chk_alarm_type` CHECK ((`alarm_type` in (_utf8mb4'over_voltage',_utf8mb4'over_current',_utf8mb4'over_temp',_utf8mb4'offline'))),
  CONSTRAINT `chk_alarm_value` CHECK (((`alarm_value` is null) or ((`alarm_value` >= 0) and (`alarm_value` <= 999999.999)))),
  CONSTRAINT `chk_threshold` CHECK (((`threshold` is null) or ((`threshold` >= 0) and (`threshold` <= 999999.999))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充电桩历史数据表'
/*!50100 PARTITION BY RANGE (((year(`alarm_time`) * 100) + month(`alarm_time`)))
(PARTITION p202510 VALUES LESS THAN (202511) ENGINE = InnoDB,
 PARTITION p202511 VALUES LESS THAN (202512) ENGINE = InnoDB,
 PARTITION p202512 VALUES LESS THAN (202601) ENGINE = InnoDB,
 PARTITION p_future VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charging_alarm`
--

LOCK TABLES `charging_alarm` WRITE;
/*!40000 ALTER TABLE `charging_alarm` DISABLE KEYS */;
/*!40000 ALTER TABLE `charging_alarm` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `charging_control`
--

DROP TABLE IF EXISTS `charging_control`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `charging_control` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键，非负',
  `device_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '设备编号',
  `command` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '控制命令（start / stop）',
  `command_code` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '加密后的指令码',
  `operator` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作人',
  `execute_status` tinyint DEFAULT '0' COMMENT '执行状态（0待执行、1成功、2失败）',
  `execute_time` datetime NOT NULL COMMENT '执行时间',
  `result_msg` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '硬件返回时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`,`execute_time`),
  KEY `idx_device_command` (`device_id`,`execute_status`),
  KEY `idx_operator` (`operator`),
  KEY `idx_execute_time` (`execute_time`),
  CONSTRAINT `chk_command` CHECK ((`command` in (_utf8mb4'start',_utf8mb4'stop'))),
  CONSTRAINT `chk_execute_status` CHECK ((`execute_status` in (0,1,2)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充电桩控制指令记录表'
/*!50100 PARTITION BY RANGE (((year(`execute_time`) * 100) + month(`execute_time`)))
(PARTITION p202510 VALUES LESS THAN (202511) ENGINE = InnoDB,
 PARTITION p202511 VALUES LESS THAN (202512) ENGINE = InnoDB,
 PARTITION p202512 VALUES LESS THAN (202601) ENGINE = InnoDB,
 PARTITION p_future VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charging_control`
--

LOCK TABLES `charging_control` WRITE;
/*!40000 ALTER TABLE `charging_control` DISABLE KEYS */;
/*!40000 ALTER TABLE `charging_control` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_charging_control_after_update` AFTER UPDATE ON `charging_control` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `charging_history`
--

DROP TABLE IF EXISTS `charging_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `charging_history` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键,非负',
  `device_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '设备编号',
  `voltage_avg` decimal(8,2) DEFAULT NULL COMMENT '平均电压',
  `current_avg` decimal(8,2) DEFAULT NULL COMMENT '平均电流',
  `power_avg` decimal(10,2) DEFAULT NULL COMMENT '平均功率',
  `energy_total` decimal(12,3) DEFAULT NULL COMMENT '累计充电量（kWh）',
  `record_time` datetime NOT NULL COMMENT '记录时间（统计周期）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_device_time` (`device_id`,`record_time`),
  KEY `idx_device_id` (`device_id`),
  KEY `idx_record_time` (`record_time`),
  CONSTRAINT `chk_current_avg` CHECK (((`current_avg` is null) or ((`current_avg` >= 0) and (`current_avg` <= 200)))),
  CONSTRAINT `chk_energy_total` CHECK (((`energy_total` is null) or ((`energy_total` >= 0) and (`energy_total` <= 999999.999)))),
  CONSTRAINT `chk_power_avg` CHECK (((`power_avg` is null) or ((`power_avg` >= 0) and (`power_avg` <= 100000)))),
  CONSTRAINT `chk_voltage_avg` CHECK (((`voltage_avg` is null) or ((`voltage_avg` >= 0) and (`voltage_avg` <= 1000))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充电桩历史数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charging_history`
--

LOCK TABLES `charging_history` WRITE;
/*!40000 ALTER TABLE `charging_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `charging_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `charging_log`
--

DROP TABLE IF EXISTS `charging_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `charging_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK，自增',
  `user` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作用户',
  `module` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作模块（data_collect, control, alert等）',
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行动作说明',
  `result` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '结果描述',
  `log_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '日志时间',
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作来源IP',
  PRIMARY KEY (`id`,`log_time`),
  KEY `idx_user` (`user`),
  KEY `idx_module` (`module`),
  KEY `idx_log_time` (`log_time`),
  KEY `idx_ip_address` (`ip_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统操作日志表'
/*!50100 PARTITION BY RANGE (((year(`log_time`) * 100) + month(`log_time`)))
(PARTITION p202510 VALUES LESS THAN (202511) ENGINE = InnoDB,
 PARTITION p202511 VALUES LESS THAN (202512) ENGINE = InnoDB,
 PARTITION p202512 VALUES LESS THAN (202601) ENGINE = InnoDB,
 PARTITION p_future VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charging_log`
--

LOCK TABLES `charging_log` WRITE;
/*!40000 ALTER TABLE `charging_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `charging_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `charging_realtime`
--

DROP TABLE IF EXISTS `charging_realtime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `charging_realtime` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键，非负',
  `device_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '充电桩编号',
  `status` tinyint NOT NULL COMMENT '运行状态：0空闲，1充电，2故障，3离线',
  `voltage` decimal(8,2) DEFAULT NULL COMMENT '当前电压（V）',
  `current` decimal(8,2) DEFAULT NULL COMMENT '当前电流（A）',
  `power` decimal(10,2) DEFAULT NULL COMMENT '实时功率（W）',
  `temperature` decimal(5,2) DEFAULT NULL COMMENT '设备温度（℃）',
  `collect_time` datetime NOT NULL COMMENT '采集时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_device_id` (`device_id`),
  KEY `idx_collect_time` (`collect_time`),
  KEY `idx_status` (`status`),
  KEY `idx_device_status` (`device_id`,`status`),
  CONSTRAINT `chk_current` CHECK (((`current` is null) or ((`current` >= 0) and (`current` <= 200)))),
  CONSTRAINT `chk_power` CHECK (((`power` is null) or ((`power` >= 0) and (`power` <= 100000)))),
  CONSTRAINT `chk_status` CHECK ((`status` in (0,1,2,3))),
  CONSTRAINT `chk_temperature` CHECK (((`temperature` is null) or ((`temperature` >= -(40)) and (`temperature` <= 100)))),
  CONSTRAINT `chk_voltage` CHECK (((`voltage` is null) or ((`voltage` >= 0) and (`voltage` <= 1000))))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充电桩实时数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charging_realtime`
--

LOCK TABLES `charging_realtime` WRITE;
/*!40000 ALTER TABLE `charging_realtime` DISABLE KEYS */;
INSERT INTO `charging_realtime` VALUES (1,'CP0001',0,220.40,0.00,0.00,23.40,'2025-10-24 13:59:45','2025-10-24 13:59:45','2025-10-24 13:59:45'),(2,'CP0002',1,220.00,20.00,4400.00,30.50,'2025-10-24 13:59:45','2025-10-24 13:59:45','2025-10-24 13:59:45'),(3,'CP0003',2,0.00,0.00,0.00,50.00,'2025-10-24 13:59:45','2025-10-24 13:59:45','2025-10-24 13:59:45'),(4,'CP0004',3,NULL,NULL,NULL,NULL,'2025-10-24 13:59:45','2025-10-24 13:59:45','2025-10-24 13:59:45');
/*!40000 ALTER TABLE `charging_realtime` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_charging_realtime_after_insert` AFTER INSERT ON `charging_realtime` FOR EACH ROW BEGIN
#   插入或更改数据时注意是否触发告警提示
#   例如 电压>300V就是高压电了，电流>50A，温度>70℃
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `charging_user`
--

DROP TABLE IF EXISTS `charging_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `charging_user` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK,自增主键',
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录用户名',
  `password` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '加密密码（不可明文）',
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户角色（admin/operator/viewer）',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号（用于告警短信）',
  `status` tinyint DEFAULT '1' COMMENT '用户状态（1启用，0禁用）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  CONSTRAINT `chk_phone` CHECK (((`phone` is null) or (length(`phone`) >= 11))),
  CONSTRAINT `chk_role` CHECK ((`role` in (_utf8mb4'admin',_utf8mb4'operator',_utf8mb4'viewer'))),
  CONSTRAINT `chk_user_status` CHECK ((`status` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='运维用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `charging_user`
--

LOCK TABLES `charging_user` WRITE;
/*!40000 ALTER TABLE `charging_user` DISABLE KEYS */;
INSERT INTO `charging_user` VALUES (1,'admin','admin','admin','18559113752',1,'2025-10-24 13:59:30'),(2,'operator','operator','operator','13366167958',1,'2025-10-24 13:59:30'),(3,'viewer','viewer','viewer','13615978848',1,'2025-10-24 13:59:30');
/*!40000 ALTER TABLE `charging_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_charging_alarm`
--

DROP TABLE IF EXISTS `v_charging_alarm`;
/*!50001 DROP VIEW IF EXISTS `v_charging_alarm`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_charging_alarm` AS SELECT 
 1 AS `告警ID`,
 1 AS `设备编号`,
 1 AS `告警类型`,
 1 AS `告警次数`,
 1 AS `未处理`,
 1 AS `处理中`,
 1 AS `已处理`,
 1 AS `最新告警时间`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_charging_realtime_status`
--

DROP TABLE IF EXISTS `v_charging_realtime_status`;
/*!50001 DROP VIEW IF EXISTS `v_charging_realtime_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_charging_realtime_status` AS SELECT 
 1 AS `记录ID`,
 1 AS `设备编号`,
 1 AS `设备状态`,
 1 AS `设备电压`,
 1 AS `设备电流`,
 1 AS `设备功率`,
 1 AS `设备温度`,
 1 AS `采集时间`,
 1 AS `记录创建时间`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_charging_alarm`
--

/*!50001 DROP VIEW IF EXISTS `v_charging_alarm`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_charging_alarm` AS select `ca`.`id` AS `告警ID`,`ca`.`device_id` AS `设备编号`,`ca`.`alarm_type` AS `告警类型`,count(0) AS `告警次数`,count((case when (`ca`.`status` = 0) then 1 end)) AS `未处理`,count((case when (`ca`.`status` = 1) then 1 end)) AS `处理中`,count((case when (`ca`.`status` = 2) then 1 end)) AS `已处理`,max(`ca`.`alarm_time`) AS `最新告警时间` from `charging_alarm` `ca` group by `ca`.`device_id`,`ca`.`alarm_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_charging_realtime_status`
--

/*!50001 DROP VIEW IF EXISTS `v_charging_realtime_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_charging_realtime_status` AS select `cr`.`id` AS `记录ID`,`cr`.`device_id` AS `设备编号`,(case `cr`.`status` when 0 then '空闲' when 1 then '充电' when 2 then '故障' when 3 then '离线' else '未知' end) AS `设备状态`,concat(ifnull(`cr`.`voltage`,0),'V') AS `设备电压`,concat(ifnull(`cr`.`current`,0),'A') AS `设备电流`,concat(ifnull(`cr`.`power`,0),'W') AS `设备功率`,concat(ifnull(`cr`.`temperature`,0),'℃') AS `设备温度`,`cr`.`collect_time` AS `采集时间`,`cr`.`create_time` AS `记录创建时间` from `charging_realtime` `cr` order by `cr`.`collect_time` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-24 15:03:14
