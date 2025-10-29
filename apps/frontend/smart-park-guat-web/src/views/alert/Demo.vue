<template>
  <div class="alert-wrapper" v-if="isVisible">
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
import { ref, onMounted, onUnmounted } from 'vue'
import { deviceId } from '@/api/alert'

const title = ref('加载中...')
const content = ref('设备告警信息加载中...')
const isVisible = ref(true)
let timer = null

// 当前告警索引
let currentIndex = 0

onMounted(async () => {
  try {
    const res = await deviceId()
    const alarms = res.data

    if (alarms && alarms.length > 0) {
      // 初始化第一个告警
      title.value = `设备ID: ${alarms[0].deviceId}`
      content.value = `告警类型: ${alarms[0].alarmType} 等级: ${alarms[0].alarmLevel} 时间: ${alarms[0].alarmTime}`

      // 轮播
      timer = window.setInterval(() => {
        currentIndex = (currentIndex + 1) % alarms.length
        const alarm = alarms[currentIndex]
        title.value = `设备ID: ${alarm.deviceId}`
        content.value = `告警类型: ${alarm.alarmType} 等级: ${alarm.alarmLevel} 时间: ${alarm.alarmTime}`
      }, 10000)
    } else {
      console.warn('返回数据为空', alarms)
      isVisible.value = false
    }
  } catch (error) {
    console.error('获取 deviceId 出错', error)
    isVisible.value = false
    title.value = '获取 deviceId 出错'
  }
})

onUnmounted(() => {
  // 组件卸载时清除定时器
  if (timer) clearInterval(timer)
})
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
