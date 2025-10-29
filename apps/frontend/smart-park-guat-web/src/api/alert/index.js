import http from '@/utils/request'

// 获取告警列表
export const deviceId = () => http.get('http://127.0.0.1:3000/api/alarm')

// 添加告警
export const alarmType = (data) => http.post('http://127.0.0.1:3000/api/alarm', data)

// 修改告警
export const alarmLevel = (data) => http.put('http://127.0.0.1:3000/api/alarm', data)

// 删除告警
export const alarmTime = (id) => http.delete(`http://127.0.0.1:3000/api/alarm/${id}`)

// 更新告警状态
export const updateAlarmStatus = (id, data) =>
  http.put(`http://127.0.0.1:3000/api/alarm/${id}/status`, data)
