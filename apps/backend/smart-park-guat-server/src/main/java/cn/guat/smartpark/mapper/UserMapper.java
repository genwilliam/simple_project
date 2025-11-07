package cn.guat.smartpark.mapper;

import cn.guat.smartpark.entity.User;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface UserMapper {

    @Select("SELECT count(1) FROM `charging_user` WHERE user_name=#{userName} AND password=#{password}")
    public Boolean checkLogin(User user);

    @Select("SELECT count(1) FROM `charging_user` WHERE user_name=#{userName} limit 1")
    public Boolean checkAdd(User user);

    @Select("SELECT * FROM `charging_user`")
    public List<User> list();

    @Insert("INSERT INTO `charging_user`(user_name,password,phone,email,sex,status) VALUES(#{userName},#{password},#{phone},#{email},#{sex},#{status})")
    public Boolean add(User user);

    @Update("UPDATE `charging_user` SET password=#{password},phone=#{phone},email=#{email},sex=#{sex},status=#{status} WHERE id=#{id}")
    public Boolean edit(User user);

    @Delete("DELETE FROM `charging_user` WHERE id=#{id}")
    public Boolean delete(Long id);
}
