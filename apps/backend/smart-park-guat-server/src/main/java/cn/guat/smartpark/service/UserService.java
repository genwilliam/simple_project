package cn.guat.smartpark.service;


import cn.guat.smartpark.entity.User;
import cn.guat.smartpark.mapper.UserMapper;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * 用户服务类
 * 提供用户相关业务逻辑处理
 */

@Service
public class UserService {

    @Resource
    private UserMapper userMapper;

    /**
     * 用户登录验证
     * @param user 包含用户名和密码的用户对象
     * @return 验证结果，true表示登录成功，false表示登录失败
     */
    public Boolean login(User user) {
        return userMapper.checkLogin(user);
    }

    /**
     * 获取用户列表
     * @return 用户列表
     */
    public List<User> list() {
        return userMapper.list();
    }

    /**
     * 添加用户
     * @param user 待添加的用户对象
     * @return 添加结果，true表示添加成功，false表示添加失败
     */
    public Boolean add(User user) {
        //检查是否已存在该用户名
        Boolean b = userMapper.checkAdd(user);
        //检查通过
        if (!b) {
            return userMapper.add(user);
        }
        return false;
    }

    /**
     * 编辑用户信息
     * @param user 包含更新信息的用户对象
     * @return 编辑结果，true表示编辑成功，false表示编辑失败
     */
    public Boolean edit(User user) {
        return userMapper.edit(user);
    }

    /**
     * 删除用户
     * @param id 待删除用户的ID
     * @return 删除结果，true表示删除成功，false表示删除失败
     */
    public Boolean delete(Long id) {
        return userMapper.delete(id);
    }
}
