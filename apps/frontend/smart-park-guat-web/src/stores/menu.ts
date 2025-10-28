import { defineStore } from 'pinia'

export const useMenuStore = defineStore('menuStore', () => {
  const menuList = [
    { title: '用户管理', path: '/user' },
    { title: '告警模块', path: '/alert' },
  ] //菜单数据
  return { menuList }
})
