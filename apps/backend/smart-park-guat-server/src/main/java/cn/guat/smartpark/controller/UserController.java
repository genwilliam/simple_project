package cn.guat.smartpark.controller;

import cn.guat.smartpark.common.R;
import cn.guat.smartpark.entity.User;
import cn.guat.smartpark.service.UserService;
import org.springframework.web.bind.annotation.*;


@CrossOrigin
@RestController
@RequestMapping("/user")
/**
 * 用户控制器类
 * 处理用户相关的HTTP请求，包括登录、列表查询、添加、编辑和删除操作
 */
public class UserController {

    private final UserService userService;

    /**
     * 构造函数注入UserService
     * @param userService 用户服务类实例
     */
    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 用户登录接口
     * @param user 包含用户名和密码的用户对象
     * @return 登录结果，成功返回"登录成功"，失败返回"登录失败"
     */
    @PostMapping("/login")
    public R login(@RequestBody User user) {
        if (userService.login(user)) {
            return R.success("登录成功");
        }
        return R.error("登录失败");
    }

    /**
     * 查询用户列表
     * @return 用户列表数据
     */
    @GetMapping("/list")
    public R list() {
        return R.success(userService.list());
    }

    /**
     * 添加用户
     * @param user 待添加的用户对象
     * @return 添加结果，成功返回"添加成功"，失败返回"添加失败"
     */
    @PostMapping("/add")
    public R add(@RequestBody User user) {
        if (!userService.add(user)) {
            return R.error("添加失败");
        }
        return R.success("添加成功");
    }

    /**
     * 编辑用户信息
     * @param user 包含更新信息的用户对象
     * @return 编辑结果，成功返回"修改成功"，失败返回"修改失败"
     */
    @PutMapping("/edit")
    public R edit(@RequestBody User user) {

        if (!userService.edit(user)) {
            return R.error("修改失败");
        }
        return R.success("修改成功");
    }

    /**
     * 删除用户
     * @param id 待删除用户的ID
     * @return 删除结果，成功返回"删除成功"，失败返回"删除失败"
     */
    @DeleteMapping("/del/{id}")
    public R delete(@PathVariable Long id) {
        Boolean b = userService.delete(id);
        if (!b) {
            return R.error("删除失败");
        }
        return R.success("删除成功");
    }

}
