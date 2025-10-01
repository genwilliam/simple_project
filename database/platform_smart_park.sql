/*
 Navicat Premium Dump SQL

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80043 (8.0.43)
 Source Host           : localhost:3306
 Source Schema         : platform_smart_park

 Target Server Type    : MySQL
 Target Server Version : 80043 (8.0.43)
 File Encoding         : 65001

 Date: 18/09/2025 18:22:16
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sp_alarm
-- ----------------------------
DROP TABLE IF EXISTS `sp_alarm`;
CREATE TABLE `sp_alarm`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '告警记录ID',
  `station_id` bigint NULL DEFAULT NULL COMMENT '站点/园区ID',
  `room_id` bigint NULL DEFAULT NULL COMMENT '告警机房ID',
  `cabinet_id` bigint NULL DEFAULT NULL COMMENT '告警机柜ID （机柜设备告警时必填）',
  `device_id` bigint NOT NULL COMMENT '告警设备ID',
  `status` int NULL DEFAULT NULL COMMENT '告警状态 0结束告警 1正在告警',
  `level` int NULL DEFAULT NULL COMMENT '告警类型 1紧急告警Critical 2次要告警Minor 3一般告警',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1' COMMENT '告警类型 1紧急告警Critical 2次要告警Minor 3一般告警',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '告警内容',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_dept` bigint NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` bigint NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 42 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '告警表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sp_alarm
-- ----------------------------
INSERT INTO `sp_alarm` VALUES (1, 1, 1, NULL, 1, NULL, 1, '服务器CPU温度过高', '服务器CPU温度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (2, 1, 1, NULL, 2, NULL, 2, '服务器内存使用率偏高', '服务器内存使用率偏高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (3, 1, 1, NULL, 3, NULL, 1, '服务器硬盘空间不足', '服务器硬盘空间不足', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (4, 1, 1, NULL, 4, NULL, 2, '服务器CPU温度异常', '服务器CPU温度异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (5, 1, 1, NULL, 5, NULL, 1, '服务器内存使用率过高', '服务器内存使用率过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (6, 1, 1, NULL, 6, NULL, 2, '服务器硬盘空间不足', '服务器硬盘空间不足', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (7, 1, 1, NULL, 7, NULL, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (8, 1, 1, NULL, 8, NULL, 2, '网络机柜湿度偏高', '网络机柜湿度偏高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (9, 1, 1, NULL, 9, NULL, 1, '网络机柜温度异常', '网络机柜温度异常', '000000', NULL, '0', NULL, NULL, '2025-09-18 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (10, 1, 1, NULL, 10, NULL, 2, '网络机柜湿度过高', '网络机柜湿度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (11, 1, 1, NULL, 11, NULL, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (12, 1, 2, NULL, 12, NULL, 2, '网络机柜湿度偏高', '网络机柜湿度偏高', '000000', NULL, '0', NULL, NULL, '2025-09-18 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (13, 1, 2, NULL, 13, NULL, 1, '网络机柜温度异常', '网络机柜温度异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (14, 1, 2, NULL, 14, NULL, 2, '网络机柜湿度过高', '网络机柜湿度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (15, 1, 2, NULL, 15, NULL, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (16, 1, 2, NULL, 16, NULL, 2, '网络机柜湿度偏高', '网络机柜湿度偏高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (17, 1, 1, NULL, 17, NULL, 1, '网络机柜温度异常', '网络机柜温度异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (18, 1, 1, NULL, 18, NULL, 2, '网络机柜湿度过高', '网络机柜湿度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (19, 1, 2, NULL, 19, NULL, 1, '网络机柜温度过高', '网络机柜温度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (20, 1, 1, NULL, 20, NULL, 2, '服务器CPU温度异常', '服务器CPU温度异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (21, 1, 2, NULL, 21, NULL, 1, '服务器内存使用率过高', '服务器内存使用率过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (22, 1, 1, NULL, 22, NULL, 2, '商用空调故障', '商用空调故障', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (23, 1, 2, NULL, 23, NULL, 1, '商用空调温度异常', '商用空调温度异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (24, 1, 1, NULL, 24, NULL, 2, '摄像头离线', '摄像头离线', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (25, 1, 2, NULL, 25, NULL, 1, '摄像头信号弱', '摄像头信号弱', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (26, 1, 1, NULL, 26, NULL, 2, '门禁系统故障', '门禁系统故障', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (27, 1, 2, NULL, 27, NULL, 3, '门禁系统识别异常', '门禁系统识别异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (28, 1, 1, NULL, 28, NULL, 3, '硬盘故障', '硬盘故障', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (29, 1, 2, NULL, 29, NULL, 1, '硬盘温度过高', '硬盘温度过高', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (30, 1, 1, NULL, 30, NULL, 2, '路由器故障', '路由器故障', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (31, 1, 2, NULL, 31, NULL, 1, '路由器端口异常', '路由器端口异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (32, 1, 1, NULL, 32, NULL, 2, '交换机故障', '交换机故障', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (33, 1, 2, NULL, 33, NULL, 1, '交换机端口拥塞', '交换机端口拥塞', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (34, 1, 1, NULL, 34, NULL, 2, 'UPS电源电压低', 'UPS电源电压低', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (35, 1, 2, NULL, 35, NULL, 1, 'UPS电源电池老化', 'UPS电源电池老化', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (36, 1, 1, NULL, 36, NULL, 2, '门禁系统通信异常', '门禁系统通信异常', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (37, 1, 1, NULL, 37, NULL, 1, '水浸传感器检测到水', '水浸传感器检测到水', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (38, 2, 1, NULL, 38, NULL, 2, '烟感传感器检测到烟雾', '烟感传感器检测到烟雾', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (39, 2, 1, NULL, 39, NULL, 1, '红外传感器检测到异常移动', '红外传感器检测到异常移动', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (40, 2, 1, NULL, 40, NULL, 2, '温度传感器故障', '温度传感器故障', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);
INSERT INTO `sp_alarm` VALUES (41, 2, 1, NULL, 41, NULL, 1, '湿度传感器故障', '湿度传感器故障', '000000', NULL, '0', NULL, NULL, '2025-09-16 11:02:53', NULL, NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;


-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
                         `id` bigint NOT NULL AUTO_INCREMENT,
                         `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
                         `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密码',
                         `phone_number` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
                         `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
                         `sex` int NULL DEFAULT NULL COMMENT '性别',
                         `status` int NULL DEFAULT 1 COMMENT '状态 0停用 1启用',
                         PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', 'admin123', '13444444444', '123@1qq.com', 1, 1);
INSERT INTO `user` VALUES (4, 'admin1', 'admin123', '13333333333', '123@1qq.com', 1, 1);
INSERT INTO `user` VALUES (6, 'tcm', 'admin123', '18888888888', '2273098742@qq.com', 1, 0);

SET FOREIGN_KEY_CHECKS = 1;