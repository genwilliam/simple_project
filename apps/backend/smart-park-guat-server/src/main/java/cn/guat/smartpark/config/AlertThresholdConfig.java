package cn.guat.smartpark.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
@ConfigurationProperties(prefix = "alert.threshold")
@Data
public class AlertThresholdConfig {
    private BigDecimal maxVoltage = new BigDecimal(300); //过压阈值
    private BigDecimal maxCurrent = new BigDecimal(50);//过流阈值
    private BigDecimal maxTemperature = new BigDecimal(60); //过温阈值
    private int offLineMinutes = 5;

}
