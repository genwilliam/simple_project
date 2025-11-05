<template>
  <div class="alert-wrapper" v-if="isVisible">
    <n-alert type="error" :title="title" closable @close="handleClose">
      <template #default>
        <n-marquee :loop="true" :speed="50" :delay="0">
          <template #default>
            <div class="marquee-content">{{ content }}</div>
          </template>
        </n-marquee>
      </template>
    </n-alert>
  </div>
  <div v-if="isVisible === false">
    <floatAlarm />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { getAlarmList } from '@/api/alert';
import floatAlarm from './show-alarm.vue';
interface Alarm {
  deviceId: string;
  alarmType: string;
  alarmLevel: number;
  alarmTime: string;
}

const title = ref('ID加载中...');
const content = ref('设备告警信息加载中...');
const isVisible = ref(true);
let timer = null;

let currentIndex = 0;
let alarms: Alarm[] = [];

// 映射
const alarmTypeMap = {
  over_current: '过流',
  over_temp: '过温',
  over_voltage: '过压',
  offline: '离线',
};

const alarmLevelMap = {
  0: '普通',
  1: '严重',
  2: '紧急',
};

const updateAlarmDisplay = (index) => {
  if (!alarms.length) {
    isVisible.value = false;
    if (timer !== null) {
      clearInterval(timer);
      timer = null;
    }
    title.value = '';
    content.value = '';
    return;
  }

  const alarm = alarms[index];

  // 使用映射表获取标签
  const typeLabel = alarmTypeMap[alarm.alarmType] || alarm.alarmType;
  const levelLabel = alarmLevelMap[alarm.alarmLevel] || alarm.alarmLevel;

  title.value = `设备ID: ${alarm.deviceId}`;
  content.value = `告警类型: ${typeLabel} ｜ 等级: ${levelLabel} ｜ 时间: ${alarm.alarmTime}`;
};

function handleClose() {
  isVisible.value = !isVisible.value;
}

onMounted(async () => {
  try {
    const res = await getAlarmList();
    if (res && res.code === 200 && res.data.length > 0) {
      alarms = res.data;
      updateAlarmDisplay(0);

      timer = window.setInterval(() => {
        currentIndex = (currentIndex + 1) % alarms.length;
        updateAlarmDisplay(currentIndex);
      }, 10000);
    } else {
      console.warn('告警列表为空', res.data);
      isVisible.value = false;
    }
  } catch (error) {
    console.error('获取告警列表出错', error);
    isVisible.value = false;
    title.value = '获取告警列表出错';
    content.value = '';
  }
});

onUnmounted(() => {
  if (timer !== null) clearInterval(timer);
});
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
