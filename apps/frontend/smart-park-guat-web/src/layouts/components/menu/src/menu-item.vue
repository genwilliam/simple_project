<template>
  <div class="dropdown" @mouseenter="onMouseEnter" @mouseleave="onMouseLeave">
    <router-link :to="items.path" custom v-slot="{ isActive, navigate }">
      <MenuButton class="item" :active="isActive" @click="navigate">{{ items.title }}</MenuButton>
    </router-link>
  </div>
</template>

<script setup>
import MenuButton from './menu-button.vue';

import { ref } from 'vue';

const props = defineProps({
  items: Object,
});

const isOpen = ref(false);
const onMouseEnter = () => {
  isOpen.value = true; // 可选，点击后关闭菜单
};
const onMouseLeave = () => {
  isOpen.value = false; // 可选，点击后关闭菜单
};
</script>

<style lang="scss" scoped>
.dropdown {
  position: relative;
}
</style>
