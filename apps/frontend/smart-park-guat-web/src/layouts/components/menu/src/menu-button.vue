<template>
  <button class="mo_btn_wrap" :class="[active ? 'active' : '']">
    <div class="content">
      <slot></slot>
    </div>
  </button>
</template>
<script setup>
const props = defineProps({
  active: {
    type: Boolean,
    default: false,
  },
});
</script>

<style scoped lang="scss">
.mo_btn_wrap {
  --color-primary: 4, 130, 255;
  padding: 0.5vw 0.3vw;
  display: inline-block;
  outline: none;
  border: 0;
  background-color: transparent;
  line-height: 1;
  text-decoration: none;
  border-radius: 3px;
  background: url('@/assets/layouts/menu-btn-bg.png') no-repeat center center;
  background-size: 100% 100%;
  transition: all 0.2s;
  cursor: pointer;
  .content {
    white-space: nowrap;
    font-weight: bold;
    font-size: 1.2vw;
    padding: 0 15px;
    color: rgba($color: #33f4ff, $alpha: 0.3);
    text-shadow:
      1px 1px 0 #bbb,
      1px 1px 0 #999,
      -1px -1px 0 #888,
      1px -1px 0 #777,
      -1px 1px 0 #666;
    text-shadow: 0px 3px 5px #0a3779;
    background: linear-gradient(#fff, #fff, #8ef1ff);
    -webkit-text-fill-color: rgba($color: #5bf5f5, $alpha: 0.3);
    background-clip: text;
    -webkit-background-clip: text;
  }
  &.active {
    background-image: url('@/assets/layouts/menu-btn-bg-active.png');
  }
}
</style>
