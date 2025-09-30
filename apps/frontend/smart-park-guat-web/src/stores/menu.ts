import { defineStore } from 'pinia'

export const useMenuStore = defineStore('menuStore', () => {
  const menuList = [{ title: '用户管理', path: '/user' }] //菜单数据
  return { menuList }
})
