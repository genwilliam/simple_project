<template>
  <div class="wrapper-container">
    <div class="title">{{ title }}</div>
    <div class="action-container">
      <slot name="action"></slot>
    </div>
    <slot></slot>
  </div>
</template>
<script setup lang="ts">
const props = defineProps({
  title: {
    type: String,
    default: '',
  },
});
</script>

<style scoped lang="scss">
.wrapper-container {
  position: absolute;
  left: 15px;
  top: 0;
  right: 15px;
  bottom: 15px;
  border-radius: 4px;
  border: 1px solid rgba(0, 123, 255, 0.4);
  color: #fff;
  padding: 50px 10px 10px;
  .title {
    position: absolute;
    top: 0;
    left: 0;
    line-height: 38px;
    height: 40px;
    width: auto;
    display: flex;
    flex-shrink: 0;
    background: url('@/assets/layouts/title-bg.png') no-repeat;
    background-size: 100% 100%;
    padding: 0 36px;
    font-weight: bold;
    font-size: 16px;
    border-radius: 5px;
  }
  .action-container {
    position: absolute;
    top: 10px;
    right: 10px;
  }
}
</style>
