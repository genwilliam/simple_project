import http from '@/utils/request';

//登录
export const login = (data) => http.post('/user/login', data);
