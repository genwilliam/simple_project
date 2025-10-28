package cn.guat.smartpark.common;

import lombok.Data;
import java.util.Random;

/**
 * TCP设备客户端工具类
 * 用于模拟与充电桩设备的TCP通信，获取设备实时运行数据
 */
public class TcpDeviceClient {

    /** 随机数生成器，用于模拟设备数据的随机性 */
    private static final Random RAND = new Random();

    /**
     * 模拟查询指定设备的实时状态和数据
     * @param deviceId 设备编号（如CP0001、CP0002等）
     * @return 设备实时数据对象（DeviceData），若设备离线则返回null
     */
    public static DeviceData queryDevice(String deviceId) {
        // 模拟设备离线场景：设备编号以"5"结尾的设备视为离线
        if (deviceId.endsWith("5")) return null;

        // 模拟生成电压数据（220V ~ 230V之间随机）
        double voltage = 220 + RAND.nextDouble() * 10;
        // 模拟生成电流数据（5A ~ 15A之间随机）
        double current = 5 + RAND.nextDouble() * 10;
        // 计算功率（功率 = 电压 * 电流 / 1000，单位：kW）
        double power = voltage * current / 1000;
        // 模拟生成温度数据（25℃ ~ 35℃之间随机）
        double temp = 25 + RAND.nextDouble() * 10;
        // 设备状态：电流大于5A视为充电中（1），否则为空闲（0）
        int status = current > 5 ? 1 : 0;

        // 封装设备数据并返回
        DeviceData data = new DeviceData();
        data.setDeviceId(deviceId);
        data.setVoltage(voltage);
        data.setCurrent(current);
        data.setPower(power);
        data.setTemperature(temp);
        data.setStatus(status);
        return data;
    }

    /**
     * 设备实时数据实体类
     * 用于封装从设备查询到的各项监测数据
     */
    @Data
    public static class DeviceData {
        private String deviceId;       // 设备编号
        private double voltage;        // 电压值（单位：V）
        private double current;        // 电流值（单位：A）
        private double power;          // 功率值（单位：kW）
        private double temperature;    // 设备温度（单位：℃）
        private int status;            // 设备状态（0：空闲，1：充电中）
    }
}
