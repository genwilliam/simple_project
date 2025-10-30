<template>
  <Wrapper title="告警模块">
    <template #action>
      <el-button type="primary" @click="openDialog">新增告警</el-button>
    </template>

    <el-table :data="tableData" style="width: 100%">
      <el-table-column prop="deviceId" label="设备" align="center" />
      <el-table-column prop="alarmType" label="告警类型" align="center">
        <template #default="scope">
          <el-tag v-if="scope.row.alarmType === 'over_voltage'" type="danger">过压</el-tag>
          <el-tag v-else-if="scope.row.alarmType === 'over_current'" type="warning">过流</el-tag>
          <el-tag v-else-if="scope.row.alarmType === 'offline'" type="info">离线</el-tag>
          <el-tag v-else-if="scope.row.alarmType === 'over_temp'" type="success">过温</el-tag>
          <el-tag v-else type="default">未知</el-tag>·
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
          <!-- row: 当前行的数据对象, -->
          <el-tag v-if="scope.row.status === 0" type="danger">未处理</el-tag>
          <el-tag v-else-if="scope.row.status === 1" type="warning">处理中</el-tag>
          <el-tag v-else type="success">已处理</el-tag>
        </template>
      </el-table-column>

      <el-table-column label="操作" align="center">
        <template #default="scope">
          <el-button type="danger" link @click="handleEdit(scope.row)">编辑</el-button>
          <!-- <el-button type="primary" link @click="handleDelete(scope.row)">删除</el-button> -->
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增 弹窗 -->
    <el-dialog :title="title" v-model="open" width="600px" @close="cancel">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        不准新增 shit
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </Wrapper>
</template>

<script setup>
import Wrapper from '@/components/wrapper/index.vue'
import { ref, onMounted } from 'vue'
import { getAlarmList, saveOrUpdateAlarm } from '@/api/alert'
import { ElMessage, ElMessageBox } from 'element-plus'

const formRef = ref(null)
const tableData = ref([])
const title = ref('新增告警')
const open = ref(false)
const isEdit = ref(false) // 是否编辑

const form = ref({
  deviceId: '',
  alarmType: '',
  alarmLevel: '普通',
  alarmTime: '',
  status: 0,
})

const rules = {
  deviceId: [{ required: true, message: '请输入设备ID', trigger: 'blur' }],
  alarmType: [{ required: true, message: '请输入告警类型', trigger: 'blur' }],
  alarmLevel: [{ required: true, message: '请输入告警等级', trigger: 'blur' }],
  alarmTime: [{ required: true, message: '请选择告警时间', trigger: 'change' }],
}

/** 获取告警列表 */
const getData = async () => {
  const res = await getAlarmList()
  if (res && res.code === 200) {
    tableData.value = res.data || []
  }
}

/** 打开新增弹窗 */
const openDialog = () => {
  title.value = '新增告警'
  open.value = true
  isEdit.value = false
  form.value = { deviceId: '', alarmType: '', alarmLevel: '普通', alarmTime: '', status: 0 }
}

/** 提交表单 */
const submitForm = () => {
  if (!formRef.value) return
  formRef.value.validate((valid) => {
    if (valid) {
      saveOrUpdateAlarm(form.value).then((res) => {
        if (res.code === 200) {
          ElMessage.success(isEdit.value ? '修改成功' : '新增成功')
          cancel()
          getData()
        }
      })
    }
  })
}

/** 取消操作 */
const cancel = () => {
  open.value = false
  formRef.value?.resetFields()
}

/** 编辑 */
const handleEdit = (row) => {
  open.value = true
  title.value = '编辑告警'
  isEdit.value = true
  form.value = { ...row }
}

/** 删除 */
// const handleDelete = (row) => {
//   ElMessageBox.confirm(`确定删除设备 ${row.deviceId} 的告警吗？`, '提示', {
//     confirmButtonText: '确定',
//     cancelButtonText: '取消',
//     type: 'warning',
//   })
//     .then(async () => {
//       console.log('Deleting alarm for deviceId:', row.deviceId) // DEV-1001
//       const res = await deleteAlarm(row.deviceId)
//       if (res.code === 200) {
//         ElMessage.success('删除成功')
//         getData()
//       }
//     })
//     .catch(() => {
//       ElMessage.info('已取消删除')
//     })
// }

onMounted(() => {
  getData()
})
</script>

<style scoped>
.dialog-footer {
  display: flex;
  justify-content: flex-end;
}
</style>
