package cn.guat.smartpark.common;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * TCP设备客户端工具类
 * 用于模拟与充电桩设备的TCP通信，获取设备实时数据（含0-3四种状态）
 */
public class TcpDeviceClient {

    /** 随机数生成器 */
    private static final Random RAND = new Random();
    /** 设备总数（15台：CP0001 ~ CP0015） */
    private static final int DEVICE_COUNT = 15;
    /** 空闲状态固定电压（V） */
    private static final double IDLE_VOLTAGE = 220.0;
    /** 空闲状态固定电流（A，无充电时为0） */
    private static final double IDLE_CURRENT = 0.0;


    /**
     * 获取所有15台设备编号
     */
    public static List<String> getAllDeviceIds() {
        List<String> deviceIds = new ArrayList<>(DEVICE_COUNT);
        for (int i = 1; i <= DEVICE_COUNT; i++) {
            deviceIds.add(String.format("CP%04d", i));
        }
        return deviceIds;
    }

    /**
     * 模拟查询设备数据，随机生成0-3四种状态：
     * 0-空闲 | 1-充电中 | 2-故障 | 3-离线
     * @param deviceId 设备编号
     * @return 设备数据（离线时返回null）
     */
    public static DeviceData queryDevice(String deviceId) {
        // 验证设备编号合法性
        if (!isValidDeviceId(deviceId)) {
            throw new IllegalArgumentException("无效的设备编号：" + deviceId);
        }

        // 随机生成状态类型（0-3，四种状态概率均等）
        int state = RAND.nextInt(4);

        // 状态3：离线（返回null，由服务层映射为状态3）
        if (state == 3) {
            return null;
        }

        // 状态0：空闲（固定正常数据）
        if (state == 0) {
            DeviceData data = new DeviceData();
            data.setDeviceId(deviceId);
            data.setVoltage(IDLE_VOLTAGE); // 固定220V
            data.setCurrent(IDLE_CURRENT); // 0A（无充电）
            data.setPower(0.0); // 功率=0kW
            data.setTemperature(25.0); // 常温
            data.setStatus(0); // 状态0：空闲
            return data;
        }

        // 状态1：充电中
        if (state == 1) {
            DeviceData data = new DeviceData();
            data.setDeviceId(deviceId);
            data.setVoltage(220 + RAND.nextDouble() * 10); // 220-230V（正常）
            data.setCurrent(5 + RAND.nextDouble() * 10);   // 5-15A（充电电流）
            data.setPower(data.getVoltage() * data.getCurrent() / 1000); // 正常功率
            data.setTemperature(28 + RAND.nextDouble() * 7); // 28-35℃（充电温升）
            data.setStatus(1); // 状态1：充电中
            return data;
        }

        // 状态2：故障（异常数据）
        DeviceData faultData = new DeviceData();
        faultData.setDeviceId(deviceId);
        // 电压异常（低于200V或高于250V）
        faultData.setVoltage(RAND.nextBoolean() ? 180 + RAND.nextDouble() * 20 : 250 + RAND.nextDouble() * 20);
        faultData.setCurrent(0.0); // 故障时无充电电流
        faultData.setPower(0.0); // 无功率输出
        faultData.setTemperature(40 + RAND.nextDouble() * 10); // 40-50℃（过热）
        faultData.setStatus(2); // 状态2：故障
        return faultData;
    }

    /**
     * 验证设备编号是否在CP0001 ~ CP0015范围内
     */
    private static boolean isValidDeviceId(String deviceId) {
        if (deviceId == null || !deviceId.startsWith("CP")) {
            return false;
        }
        try {
            int num = Integer.parseInt(deviceId.substring(2));
            return num >= 1 && num <= DEVICE_COUNT;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * 设备实时数据实体类
     */
    @Data
    public static class DeviceData {
        private String deviceId;       // 设备编号
        private double voltage;        // 电压（V）
        private double current;        // 电流（A）
        private double power;          // 功率（kW）
        private double temperature;    // 温度（℃）
        private int status;            // 状态（0：空闲，1：充电中，2：故障）
    }
}