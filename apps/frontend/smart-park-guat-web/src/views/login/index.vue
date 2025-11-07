<template>
  <div class="login-container">
    <el-form ref="loginRef" :model="loginForm" :rules="loginRules" class="login-form">
      <h3 class="title">智慧机房集群管控系统</h3>
      <el-form-item prop="userName">
        <el-input
          v-model="loginForm.userName"
          type="text"
          size="large"
          auto-complete="off"
          placeholder="用户名"
        >
          <template #prefix>
            <el-icon><User /></el-icon>
          </template>
        </el-input>
      </el-form-item>
      <el-form-item prop="password">
        <el-input
          v-model="loginForm.password"
          type="password"
          size="large"
          auto-complete="off"
          placeholder="密码"
        >
          <template #prefix>
            <el-icon><Lock /></el-icon>
          </template>
        </el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="large" @click="submitForm" style="width: 100%"
          >登 录</el-button
        >
      </el-form-item>
    </el-form>
  </div>
</template>
<script setup>
import { ref } from 'vue';
import { login } from '@/api/login';
import { useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
const router = useRouter();
const loginRef = ref(null);
//表单数据
const loginForm = ref({
  userName: 'admin',
  password: 'admin123',
});
//表单验证
const loginRules = {
  userName: [
    {
      required: true,
      trigger: 'blur',
      message: '请输入用户名',
    },
  ],
  password: [
    {
      required: true,
      trigger: 'blur',
      message: '请输入密码',
    },
  ],
};

//登录
const submitForm = async () => {
  if (!loginRef.value) return;
  await loginRef.value.validate((valid) => {
    if (valid) {
      login(loginForm.value).then((res) => {
        if (res.code === 200) {
          //路由跳转到用户管理页面
          ElMessage.success('登录成功');
          router.push({ name: 'user' });
        }
      });
    }
  });
};
</script>

<style scoped lang="scss">
.login-container {
  width: 100%;
  height: 100%;
  background: url('@/assets/layouts/login-bg.png') no-repeat;
  background-size: 100% 100%;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 50px;

  .login-form {
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.67);
    width: 500px;
    padding: 25px 25px 5px 25px;
    .title {
      margin: 0px auto 25px auto;
      text-align: center;
      color: rgb(67, 148, 244);
      font-weight: bold;
      font-size: 3vh;
    }

    .el-input {
      height: 40px;

      input {
        height: 40px;
      }
    }

    .input-icon {
      height: 39px;
      width: 14px;
      margin-left: 0px;
    }
  }
}
</style>
