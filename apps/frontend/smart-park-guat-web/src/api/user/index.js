import http from '@/utils/request'

// 获取用户列表
export const getUserList = (params) => http.get('/user/list', params)

//新增用户
export const addUser = (data) => http.post('/user/add', data)

// 修改用户
export const updateUser = (data) => http.put('/user/edit', data)

// 删除用户
export const deleteUser = (id) => http.delete(`/user/del/${id}`)
