package cn.guat.smartpark.common;

/**
 * 通用响应结果封装类
 * 用于封装服务端返回的统一格式响应数据，包括状态码、消息和实际数据
 *
 * @param <T> 响应数据的类型
 */
public class R<T> {

    //服务端返回的错误码
    private int code = 200;
    //服务端返回的错误信息
    private String msg = "success";
    //我们服务端返回的数据
    private T data;

    /**
     * 构造一个响应结果对象
     *
     * @param code 响应状态码
     * @param msg  响应消息
     * @param data 响应数据
     */
    private R(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    /**
     * 创建一个表示成功的响应结果
     *
     * @param <T> 数据的类型
     * @return 包含成功状态和数据的响应结果对象
     */
    public static <T> R success() {
        R r = new R(200, "success", null);
        return r;
    }

    /**
     * 创建一个表示成功的响应结果
     *
     * @param data 成功时返回的数据
     * @param <T>  数据的类型
     * @return 包含成功状态和数据的响应结果对象
     */
    public static <T> R success(T data) {
        R r = new R(200, "success", data);
        return r;
    }

    /**
     * 创建一个表示成功的响应结果，可自定义消息
     *
     * @param msg  成功消息
     * @param data 成功时返回的数据
     * @param <T>  数据的类型
     * @return 包含成功状态、消息和数据的响应结果对象
     */
    public static <T> R success(String msg, T data) {
        R r = new R(200, msg, data);
        return r;
    }


    /**
     * 创建一个表示成功的响应结果，可自定义消息
     * @param msg
     * @return
     * @param <T>
     */
    public static <T> R success(String msg) {
        R r = new R(200,msg, null);
        return r;
    }

    /**
     * 创建一个表示错误的响应结果
     *
     * @param code 错误状态码
     * @param msg  错误消息
     * @param <T>  数据的类型（错误时通常为null）
     * @return 包含错误状态和消息的响应结果对象
     */
    public static <T> R error(int code, String msg) {
        R r = new R(code, msg, null);
        return r;
    }

    /**
     * 创建一个表示错误的响应结果
     *
     * @param msg 错误消息
     * @param <T> 数据的类型（错误时通常为null）
     * @return 包含错误状态和消息的响应结果对象
     */
    public static <T> R error(String msg) {
        R r = new R(400, msg, null);
        return r;
    }

    public int getCode() {
        return code;
    }

    public String getMsg() {
        return msg;
    }

    public T getData() {
        return data;
    }


}
