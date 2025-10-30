import http from '@/utils/request'

// 获取告警列表
export const getAlarmList = () => http.get('/api/charging/alert/list')

// 新增或修改告警
export const saveOrUpdateAlarm = (data) => http.post('/api/charging/alert/update', data)

// 删除告警
export const deleteAlarm = (id) => http.delete(`/api/charging/alert/delete/${id}`)

// 获取单条告警详情
export const getAlarmById = (id) => http.get(`/api/charging/alert/get/${id}`)
