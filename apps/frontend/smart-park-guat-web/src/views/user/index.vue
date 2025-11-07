<template>
  <Wrapper title="用户管理">
    <template #action>
      <el-button type="primary" @click="open = true">新增</el-button>
    </template>
    <el-table :data="tableData" style="width: 100%">
      <el-table-column prop="userName" label="用户名称" align="center" />
      <el-table-column prop="phoneNumber" label="手机号码" align="center" />
      <el-table-column prop="email" label="邮箱" align="center" />
      <el-table-column prop="sex" label="性别" align="center">
        <template #default="scope">
          <el-tag type="primary" v-if="scope.row.sex === 1">男</el-tag>
          <el-tag type="danger" v-if="scope.row.sex === 0">女</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag type="primary" v-if="scope.row.status === 1">正常</el-tag>
          <el-tag type="danger" v-if="scope.row.status === 0">停用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center">
        <template #default="scope">
          <el-button type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="danger" link @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加或修改用户配置对话框 -->
    <el-dialog :title="title" v-model="open" width="600px" @close="cancel">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="用户名称" prop="userName">
              <el-input
                :disabled="form.id != undefined"
                v-model="form.userName"
                placeholder="请输入用户名称"
                maxlength="30"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="用户密码" prop="password">
              <el-input
                v-model="form.password"
                placeholder="请输入用户密码"
                type="password"
                maxlength="20"
                show-password
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="手机号码" prop="phoneNumber">
              <el-input v-model="form.phoneNumber" placeholder="请输入手机号码" maxlength="11" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="form.email" placeholder="请输入邮箱" maxlength="50" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="用户性别" prop="sex">
              <el-select v-model="form.sex" placeholder="请选择性别">
                <el-option label="男" :value="1"></el-option>
                <el-option label="女" :value="0"></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio :label="1">正常</el-radio>
                <el-radio :label="0">禁用</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </Wrapper>
</template>
<script setup>
import Wrapper from '@/components/wrapper/index.vue';
import { ref, reactive, onMounted } from 'vue';
import { getUserList, addUser, updateUser, deleteUser } from '@/api/user';
import { ElMessage, ElMessageBox } from 'element-plus';
const formRef = ref(null);
const tableData = ref([]);
const title = ref('修改用户'); //弹窗标题
const open = ref(false); //弹窗显示隐藏
const form = ref({}); //表单数据
const rules = reactive({
  //表单校验规则
  userName: [
    { required: true, message: '请输入用户名称', trigger: 'blur' },
    { min: 2, max: 30, message: '用户名称长度在2到30个字符之间', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入用户密码', trigger: 'blur' },
    { min: 5, max: 20, message: '用户密码长度在5到20个字符之间', trigger: 'blur' },
  ],
  phoneNumber: [
    { required: true, message: '请输入手机号码', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号码格式不正确', trigger: 'blur' },
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: ['blur', 'change'] },
  ],
  sex: [{ required: true, message: '请选择性别', trigger: 'change' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
});
/**
 * 获取用户列表
 */
const getData = () => {
  getUserList().then((res) => {
    tableData.value = res.data;
  });
};
/**
 * 提交表单
 */
const submitForm = () => {
  if (!formRef.value) return;
  formRef.value.validate((valid) => {
    if (valid) {
      if (form.value.id == undefined) {
        addUser(form.value).then((res) => {
          ElMessage.success(res.data);
          cancel();
          getData();
        });
      } else {
        updateUser(form.value).then((res) => {
          ElMessage.success(res.data);
          cancel();
          getData();
        });
      }
    }
  });
};
/**
 * 取消
 */
const cancel = () => {
  open.value = false;
  form.value = {};
  formRef.value.resetFields();
};
/**
 * 编辑
 * @param row 编辑行数据
 */
const handleEdit = (row) => {
  open.value = true;
  form.value = JSON.parse(JSON.stringify(row));
};
/**
 * 删除
 * @param row 删除行数据
 */
const handleDelete = (row) => {
  ElMessageBox.confirm(`您确定删除用户名称为“${row.userName}”的用户吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(async () => {
      const res = await deleteUser(row.id); //删除用户
      ElMessage.success(res.data);
      getData();
    })
    .catch(() => {});
};
onMounted(() => {
  getData();
});
</script>

<style scoped>
.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
}
</style>
