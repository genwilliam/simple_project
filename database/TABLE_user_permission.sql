# 设置会话参数
SET NAMES  utf8mb4;/*字符集统一*/
SET FOREIGN_KEY_CHECKS = 0;/*临时禁用外键约束检查*/
SET AUTOCOMMIT = 0;/*自动提交事务关闭*/

# 创建用户权限编码表
DROP TABLE IF EXISTS permission;
CREATE TABLE IF NOT EXISTS permission(
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY  COMMENT '自增主键',
    permission_code VARCHAR(32) NOT NULL  UNIQUE COMMENT '权限编码',
    permission_name VARCHAR(64) NOT NULL COMMENT '权限名称'
)/*设置引擎，字符集，表的名称*/
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT '权限字典表';

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

# 插入初始数据
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



# 恢复设置
SET FOREIGN_KEY_CHECKS = 1;
SET AUTOCOMMIT = 1;

