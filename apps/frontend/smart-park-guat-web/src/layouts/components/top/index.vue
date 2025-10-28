<template>
  <div class="pageTop wow fadeInDown">
    <sequence :fileLength="74" :IntervalTime="50" />
    <div class="title">
      <span :title="name">{{ name }}</span>
    </div>
    <div class="left">
      <img src="@/assets/logo.png" alt="" />
    </div>
    <div class="right">
      <span>{{ currentDate }}</span>
      <span>{{ currentTime }}</span>
      <div class="alert">
        <Demo></Demo>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import dayjs from 'dayjs'
import localeData from 'dayjs/plugin/localeData'
import updateLocale from 'dayjs/plugin/updateLocale'
import 'dayjs/locale/zh-cn'
import sequence from './sequence/index.vue'
import Demo from '@/views/alert/charge-err.vue'
dayjs.locale('zh-cn')

const props = defineProps<{
  name: { type: String; default: string }['default']
}>()

const currentTime = ref(dayjs().format('HH:mm:ss'))
const currentDate = ref(dayjs().format('YYYY/MM/DD dddd'))
const timer = ref<string | number | NodeJS.Timeout | undefined>(undefined)

function updateTime() {
  currentTime.value = dayjs().format('HH:mm:ss')
  currentDate.value = dayjs().format('YYYY/MM/DD dddd')
}

onMounted(() => {
  updateTime()
  timer.value = setInterval(updateTime, 1000)
})

onBeforeUnmount(() => {
  clearInterval(timer.value)
})

dayjs.extend(localeData)
dayjs.extend(updateLocale)

dayjs.updateLocale('zh-cn', {
  weekdays: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
})
</script>

<style lang="scss" scoped>
.pageTop {
  display: flex;
  position: relative;
  z-index: 101;
  flex-flow: row nowrap;
  flex-shrink: 0;
  align-items: flex-start;
  width: 100%;
  height: 100px;
  color: #fff;
  place-content: flex-start space-between;

  .title {
    position: absolute;
    top: 10px;
    left: 50%;
    transform: translateX(-50%);

    span {
      display: inline-block;
      background: linear-gradient(180deg, #f2fcff 0%, #69cbf5 100%);
      background-clip: text;
      color: transparent;
      font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;
      font-size: 36px;
      font-style: normal;
      font-weight: 400;
      font-weight: bold;
      letter-spacing: 3px;
      text-shadow: 0 0 5px rgb(255 255 255 / 30%);
      text-transform: none;
      white-space: nowrap;
      -webkit-text-fill-color: transparent;

      &::before {
        content: attr(title);
        position: absolute;
        z-index: -1;
        top: 0;
        left: 0;
        color: transparent;
        text-shadow: 0 4px 6px rgb(0 0 0 / 51%);
      }
    }
  }

  .left,
  .right {
    display: flex;
    padding: 25px 15px 0;
  }

  .left {
    img {
      height: 47px;
    }
  }

  .right {
    display: flex;
    gap: 15px;
    font-size: 16px;
    font-weight: bold;
  }
}
</style>
