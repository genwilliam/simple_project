package cn.guat;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;


/**
 * Smartpark应用程序主类
 * 这是Spring Boot应用程序的入口点，负责启动整个应用
 */

@EnableScheduling
@SpringBootApplication
public class SmartparkApplication {

    /**
     * 应用程序主函数
     * 启动Spring Boot应用程序上下文并运行Web服务器
     *
     * @param args 命令行参数数组，用于传递启动参数
     */
    public static void main(String[] args) {
        SpringApplication.run(SmartparkApplication.class, args);
        System.out.println("启动成功");
    }

}
