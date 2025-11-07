import { createRouter, createWebHistory } from 'vue-router';
import Layout from '@/layouts/index.vue';
const router = createRouter({
  history: createWebHistory(import.meta.env.VITE_APP_BASE_URL),
  routes: [
    {
      path: '/',
      name: 'layout',
      component: Layout,
      redirect: '/login',
      children: [
        {
          path: '/user',
          name: 'user',
          component: () => import('@/views/user/index.vue'),
          meta: {
            title: '用户管理',
          },
        },
        {
          path: '/alert',
          name: 'alert',
          component: () => import('@/views/alert/index.vue'),
          meta: {
            title: '告警模块',
          },
        },
      ],
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/login/index.vue'),
      meta: {
        title: '登录',
      },
    },
  ],
});

export default router;
