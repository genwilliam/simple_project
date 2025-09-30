<template>
  <el-container class="main-container">
    <el-header>
      <Top name="智慧机房集群管控系统" />
      <Menu />
    </el-header>
    <el-main>
      <RouterView />
    </el-main>
  </el-container>
</template>
<script setup lang="ts">
import Top from './components/top/index.vue'
import Menu from './components/menu/index.vue'
</script>

<style scoped lang="scss">
.main-container {
  width: 100%;
  height: 100%;
  background: url('@/assets/layouts/layout-bg.png') no-repeat center;
  background-size: 100% 100%;
}
.el-header,
.el-main {
  margin: 0;
  padding: 0;
}
.el-header {
  height: auto;
}
.el-main {
  padding: 0 15px 15px;
  position: relative;
}
</style>
