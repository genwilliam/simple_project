<template>
  <n-flex>
    <n-float-button position="relative">
      <n-badge :value="9" :offset="[6, -8]">
        <n-icon>
          <AlarmOutlineIcon />
        </n-icon>
      </n-badge>
    </n-float-button>
  </n-flex>
</template>

<script setup lang="ts">
import { AlarmOutline as AlarmOutlineIcon } from '@vicons/ionicons5';
</script>
