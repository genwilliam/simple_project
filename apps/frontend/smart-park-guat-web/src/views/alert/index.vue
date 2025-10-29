<template>
  <Wrapper title="告警模块">
    <template #action>
      <el-button type="primary" @click="open = true">新增告警</el-button>
    </template>

    <el-table :data="tableData" style="width: 100%">
      <el-table-column prop="deviceId" label="设备" align="center" />
      <el-table-column prop="alarmType" label="告警类型" align="center" />
      <el-table-column prop="alarmLevel" label="告警等级" align="center" />
      <el-table-column prop="alarmTime" label="告警时间" align="center" />
      <el-table-column prop="status" label="状态" align="center">
        <template #default="scope">
          <el-tag type="success" v-if="scope.row.status === 1">正常</el-tag>
          <el-tag type="danger" v-else>告警</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center">
        <template #default="scope">
          <el-button type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="danger" link @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 弹窗 -->
    <el-dialog :title="title" v-model="open" width="600px" @close="cancel">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="设备" prop="deviceId">
          <el-input v-model="form.deviceId" placeholder="请输入设备ID" />
        </el-form-item>
        <el-form-item label="告警类型" prop="alarmType">
          <el-input v-model="form.alarmType" placeholder="请输入告警类型" />
        </el-form-item>
        <el-form-item label="告警等级" prop="alarmLevel">
          <el-input v-model="form.alarmLevel" placeholder="请输入告警等级" />
        </el-form-item>
        <el-form-item label="告警时间" prop="alarmTime">
          <el-input v-model="form.alarmTime" placeholder="请输入告警时间" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="0">告警</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </Wrapper>
</template>

<script setup>
import Wrapper from '@/components/wrapper/index.vue'
import { ref, onMounted } from 'vue'
import { deviceId, alarmType, alarmLevel, alarmTime } from '@/api/alert'
import { ElMessage, ElMessageBox } from 'element-plus'

const formRef = ref(null)
const tableData = ref([])
const title = ref('新增告警')
const open = ref(false)
const form = ref({})
const rules = {
  deviceId: [{ required: true, message: '请输入设备ID', trigger: 'blur' }],
  alarmType: [{ required: true, message: '请输入告警类型', trigger: 'blur' }],
  alarmLevel: [{ required: true, message: '请输入告警等级', trigger: 'blur' }],
}

/** 获取告警列表 */
const getData = async () => {
  const res = await deviceId()
  tableData.value = res.data
}

/** 提交表单 */
const submitForm = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    if (!form.value.id) {
      await alarmType(form.value)
      ElMessage.success('新增成功')
    } else {
      await alarmLevel(form.value)
      ElMessage.success('修改成功')
    }
    cancel()
    getData()
  })
}

/** 取消操作 */
const cancel = () => {
  open.value = false
  form.value = {}
  formRef.value?.resetFields()
}

/** 编辑 */
const handleEdit = (row) => {
  open.value = true
  title.value = '编辑告警'
  form.value = { ...row }
}

/** 删除 */
const handleDelete = (row) => {
  ElMessageBox.confirm(`确定删除设备 ${row.deviceId} 的告警吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(async () => {
      await alarmTime(row.id)
      ElMessage.success('删除成功')
      getData()
    })
    .catch(() => {
      ElMessage.info('已取消删除')
    })
}

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
