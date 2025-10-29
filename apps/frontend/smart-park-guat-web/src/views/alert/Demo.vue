<template>
  <div class="alert-wrapper">
    <n-alert type="error" :title="title">
      <template #default>
        <n-marquee>
          <template #default>
            <div style="margin-right: 64px">{{ content }}</div>
          </template>
        </n-marquee>
      </template>
    </n-alert>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const title = ref('错误告警')
const content = ref('检测到设备离线，请检查连接状态。')
</script>

<style scoped>
.alert-wrapper {
  position: fixed;
  top: 70px;
  right: 20px;
  z-index: 9999;
  width: 350px;
}

.marquee-content {
  margin-right: 64px;
  white-space: nowrap;
}
</style>
