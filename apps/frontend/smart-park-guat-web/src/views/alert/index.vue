<template>
  <Wrapper title="告警模块">
    <el-table :data="tableData" style="width: 100%">
      <el-table-column prop="deviceId" label="设备" align="center" />
      <el-table-column prop="alarmType" label="告警类型" align="center">
        <template #default="scope">
          <el-tag v-if="scope.row.alarmType === 'over_voltage'" type="danger">过压</el-tag>
          <el-tag v-else-if="scope.row.alarmType === 'over_current'" type="warning">过流</el-tag>
          <el-tag v-else-if="scope.row.alarmType === 'offline'" type="info">离线</el-tag>
          <el-tag v-else-if="scope.row.alarmType === 'over_temp'" type="success">过温</el-tag>
          <el-tag v-else type="default">未知</el-tag>
        </template>
      </el-table-column>

      <el-table-column prop="alarmLevel" label="告警等级" align="center">
        <template #default="scope">
          <el-tag v-if="scope.row.alarmLevel === '普通'" type="warning">普通</el-tag>
          <el-tag v-else-if="scope.row.alarmLevel === '严重'" type="danger">严重</el-tag>
          <el-tag v-else type="info">未知</el-tag>
        </template>
      </el-table-column>

      <el-table-column prop="alarmTime" label="告警时间" align="center" />

      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag v-if="scope.row.status === 0" type="danger">未处理</el-tag>
          <el-tag v-else-if="scope.row.status === 1" type="warning">处理中</el-tag>
          <el-tag v-else type="success">已处理</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="操作" align="center">
        <template #default="scope">
          <el-button type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- ✅ 编辑 弹窗 -->
    <el-dialog :title="title" v-model="open" width="600px" @close="cancel">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="设备ID" prop="deviceId">
          <el-input v-model="form.deviceId" disabled />
        </el-form-item>

        <el-form-item label="告警类型" prop="alarmType">
          <el-select v-model="form.alarmType" placeholder="选择类型">
            <el-option label="过压" value="over_voltage" />
            <el-option label="过流" value="over_current" />
            <el-option label="离线" value="offline" />
            <el-option label="过温" value="over_temp" />
          </el-select>
        </el-form-item>

        <el-form-item label="告警等级" prop="alarmLevel">
          <el-select v-model="form.alarmLevel">
            <el-option label="普通" value="普通" />
            <el-option label="严重" value="严重" />
          </el-select>
        </el-form-item>

        <el-form-item label="告警时间" prop="alarmTime">
          <el-date-picker v-model="form.alarmTime" type="datetime" placeholder="选择时间" />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status">
            <el-option label="未处理" :value="0" />
            <el-option label="处理中" :value="1" />
            <el-option label="已处理" :value="2" />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancel">取 消</el-button>
          <el-button type="primary" @click="submitForm">保 存</el-button>
        </div>
      </template>
    </el-dialog>
  </Wrapper>
</template>

<script setup>
import Wrapper from '@/components/wrapper/index.vue';
import { ref, onMounted } from 'vue';
import { getAlarmList, saveOrUpdateAlarm } from '@/api/alert';
import { ElMessage } from 'element-plus';

const formRef = ref(null);
const tableData = ref([]);
const title = ref('编辑告警');
const open = ref(false);

const form = ref({
  deviceId: '',
  alarmType: '',
  alarmLevel: '',
  alarmTime: '',
  status: 0,
});

const rules = {
  alarmType: [{ required: true, message: '请选择告警类型', trigger: 'change' }],
  alarmLevel: [{ required: true, message: '请选择告警等级', trigger: 'change' }],
  alarmTime: [{ required: true, message: '请选择告警时间', trigger: 'change' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
};

/** 获取告警列表 */
const getData = async () => {
  const res = await getAlarmList();
  if (res && res.code === 200) {
    tableData.value = res.data || [];
  }
};

/** 编辑 */
const handleEdit = (row) => {
  open.value = true;
  title.value = '编辑告警';
  form.value = { ...row };
};

/** 提交表单 */
const submitForm = () => {
  if (!formRef.value) return;
  formRef.value.validate((valid) => {
    if (valid) {
      saveOrUpdateAlarm(form.value).then((res) => {
        if (res.code === 200) {
          ElMessage.success('修改成功');
          cancel();
          getData();
        }
      });
    }
  });
};

/** 取消操作 */
const cancel = () => {
  open.value = false;
  formRef.value?.resetFields();
};

onMounted(() => {
  getData();
});
</script>

<style scoped>
.dialog-footer {
  display: flex;
  justify-content: flex-end;
}
</style>
