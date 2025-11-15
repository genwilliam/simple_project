package cn.guat.smartpark.handler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@ControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @ExceptionHandler(Exception.class)
    public void handleAllException(Exception e) {
        // 1. 从异常消息中获取“功能标识”（如“告警检测功能出错”）
        String businessScene = e.getMessage() != null ? e.getMessage() : "未知功能出错";
        // 2. 自动解析具体错误原因
        String errorReason = getDetailedErrorReason(e);
        // 3. 结构化日志输出
        String logMsg = String.format(
                "[业务告警] 时间: %s | %s | 具体原因: %s",
                LocalDateTime.now().format(formatter),
                businessScene,
                errorReason
        );
        // 4. 打印日志+完整堆栈（便于定位代码）
        log.error(logMsg, e);
    }

    /**
     * 核心方法：自动解析异常的具体原因
     */
    private String getDetailedErrorReason(Exception e) {
        // 先获取异常类型（如NullPointerException、RuntimeException）
        String exceptionType = e.getClass().getSimpleName();
        // 获取异常触发的代码位置（类名+方法名+行号）
        StackTraceElement triggerPoint = getExceptionTriggerPoint(e);
        String triggerInfo = triggerPoint != null ?
                triggerPoint.getClassName() + "." + triggerPoint.getMethodName() + "（第" + triggerPoint.getLineNumber() + "行）" :
                "未知位置";

        // 根据异常类型和触发位置，补充具体原因
        switch (exceptionType) {
            case "NullPointerException":
                return "空指针异常：" + getNullFieldHint(triggerPoint) + "，触发位置：" + triggerInfo;
            case "RuntimeException":
                // 针对业务逻辑触发的RuntimeException，结合触发位置推断原因
                return getBusinessLogicReason(triggerPoint) + "，触发位置：" + triggerInfo;
            case "SQLException":
                return "数据库操作异常：" + e.getMessage() + "，触发位置：" + triggerInfo;
            case "IllegalArgumentException":
                return "参数非法：" + e.getMessage() + "，触发位置：" + triggerInfo;
            default:
                return exceptionType + "：" + e.getMessage() + "，触发位置：" + triggerInfo;
        }
    }

    /**
     * 获取异常触发的具体代码位置（第一个业务层代码行）
     */
    private StackTraceElement getExceptionTriggerPoint(Exception e) {
        StackTraceElement[] stackTrace = e.getStackTrace();
        if (stackTrace == null || stackTrace.length == 0) {
            return null;
        }
        // 过滤出业务层代码（包名包含service/mapper/controller）
        for (StackTraceElement stackElement : stackTrace) {
            if (stackElement.getClassName().contains("cn.guat.smartpark.service")
                    || stackElement.getClassName().contains("cn.guat.smartpark.mapper")
                    || stackElement.getClassName().contains("cn.guat.smartpark.controller")) {
                return stackElement;
            }
        }
        return stackTrace[0]; // 未匹配到业务层，返回第一个堆栈元素
    }

    /**
     * 推断空指针异常的字段（针对告警检测、登录等场景）
     */
    private String getNullFieldHint(StackTraceElement triggerPoint) {
        if (triggerPoint == null) {
            return "未知字段为空";
        }
        String methodName = triggerPoint.getMethodName();
        // 根据方法名推断可能为空的字段
        if (methodName.contains("checkAndHandlerAlert")) {
            return "可能是设备电压（voltage）、电流（current）等核心字段为空";
        } else if (methodName.contains("login")) {
            return "可能是用户名（userName）、密码（password）为空，或查询结果（dbUser）为空";
        } else if (methodName.contains("collectSingleDevice")) {
            return "可能是设备数据（DeviceData）采集结果为空";
        } else {
            return "未知字段为空";
        }
    }

    /**
     * 推断业务逻辑异常的具体原因（针对业务层RuntimeException）
     */
    private String getBusinessLogicReason(StackTraceElement triggerPoint) {
        if (triggerPoint == null) {
            return "业务逻辑校验失败";
        }
        String methodName = triggerPoint.getMethodName();
        int lineNumber = triggerPoint.getLineNumber();

        // 根据“方法名+行号”精准推断原因（结合你的业务代码结构）
        if (methodName.equals("checkAndHandlerAlert")) {
            if (lineNumber == 45) {
                return "设备电压数据为空，无法进行过压检测";
            } else if (lineNumber == 50) {
                return "设备电压超过阈值（过压）";
            } else if (lineNumber == 55) {
                return "设备电流超过阈值（过流）";
            } else {
                return "设备告警阈值校验失败";
            }
        } else if (methodName.equals("login")) {
            if (lineNumber == 25) {
                return "用户名不存在";
            } else if (lineNumber == 30) {
                return "密码错误";
            } else {
                return "用户登录校验失败";
            }
        } else if (methodName.equals("batchInsert")) {
            return "批量插入数据时字段数与值数不匹配，或数据格式错误";
        } else {
            return "业务逻辑校验失败";
        }
    }
}