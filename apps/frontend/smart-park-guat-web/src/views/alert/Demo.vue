<template>
  <div class="alert-wrapper" v-if="isVisible">
    <n-alert type="error" :title="title">
      <template #default>
        <n-marquee :loop="true" :speed="50" :delay="0">
          <template #default>
            <div class="marquee-content">{{ content }}</div>
          </template>
        </n-marquee>
      </template>
    </n-alert>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { getAlarmList } from '@/api/alert'

interface Alarm {
  deviceId: string
  alarmType: string
  alarmLevel: number
  alarmTime: string
}

const title = ref('ID加载中...')
const content = ref('设备告警信息加载中...')
const isVisible = ref(true)
let timer: number | null = null

let currentIndex = 0
let alarms: Alarm[] = []

const updateAlarmDisplay = (index: number) => {
  if (!alarms.length) {
    isVisible.value = false
    if (timer !== null) {
      clearInterval(timer)
      timer = null
    }
    title.value = ''
    content.value = ''
    return
  }

  const alarm = alarms[index]
  title.value = `设备ID: ${alarm.deviceId}`
  content.value = `告警类型: ${alarm.alarmType} 等级: ${alarm.alarmLevel} 时间: ${alarm.alarmTime}`
}

onMounted(async () => {
  try {
    const res = await getAlarmList()
    if (res && res.code === 200 && res.data.length > 0) {
      alarms = res.data
      updateAlarmDisplay(0)

      timer = window.setInterval(() => {
        currentIndex = (currentIndex + 1) % alarms.length
        updateAlarmDisplay(currentIndex)
      }, 10000)
    } else {
      console.warn('告警列表为空', res.data)
      isVisible.value = false
    }
  } catch (error) {
    console.error('获取告警列表出错', error)
    isVisible.value = false
    title.value = '获取告警列表出错'
    content.value = ''
  }
})

onUnmounted(() => {
  if (timer !== null) clearInterval(timer)
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
