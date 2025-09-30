package cn.guat.smartpark.mapper;

import cn.guat.smartpark.entity.User;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface UserMapper {

    @Select("SELECT count(1) FROM `user` WHERE user_name=#{userName} AND password=#{password}")
    public Boolean checkLogin(User user);

    @Select("SELECT count(1) FROM `user` WHERE user_name=#{userName} limit 1")
    public Boolean checkAdd(User user);

    @Select("SELECT * FROM `user`")
    public List<User> list();

    @Insert("INSERT INTO `user`(user_name,password,phone_number,email,sex,status) VALUES(#{userName},#{password},#{phoneNumber},#{email},#{sex},#{status})")
    public Boolean add(User user);

    @Update("UPDATE `user` SET password=#{password},phone_number=#{phoneNumber},email=#{email},sex=#{sex},status=#{status} WHERE id=#{id}")
    public Boolean edit(User user);

    @Delete("DELETE FROM `user` WHERE id=#{id}")
    public Boolean delete(Long id);
}
