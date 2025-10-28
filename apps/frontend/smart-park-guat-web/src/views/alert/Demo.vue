<template>
  <div class="alert-wrapper">
    <n-alert type="error" :title="title">
      <n-marquee>
        <div style="margin-right: 64px">{{ content }}</div>
      </n-marquee>
    </n-alert>
  </div>
</template>

<script lang="ts" setup>
import { ref } from 'vue'

const title = ref('damn')
const content = ref('damn')
</script>

<style scoped>
.alert-wrapper {
  position: fixed;
  top: 70px;
  right: 20px;
  z-index: 9999;
  width: 350px;
}
</style>
