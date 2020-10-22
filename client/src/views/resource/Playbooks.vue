<template>
<div class="app-container">
    <h3>Playbook管理</h3>
    <el-alert :closable="false" type="success" title="负责管理系统的所有Ansible脚本。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="$store.getters.playbooks">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="描述">
            <template slot-scope="scope"><span >{{ scope.row.desc }}</span></template>
        </el-table-column>
        <el-table-column label="创建者">
            <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
        </el-table-column>
        <el-table-column label="操作" align="center">
            <template slot-scope="scope">
                <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" width="65%">
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="80px">
            <el-form-item label="名称" prop="name">
                <el-input v-model="form.name" maxlength="20" placeholder="playbook名称"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" maxlength="100" placeholder="playbook描述"/>
            </el-form-item>
            <el-form-item label="脚本" prop="script">
                <CodeEditor v-model="form.script" :code="form.script" height="400px" language="text/x-yaml"/>
            </el-form-item>
            <el-form-item>
                <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
                <el-button @click="dialogFormVisible = false">取消</el-button>
            </el-form-item>
        </el-form>
    </el-dialog>
</div>
</template>

<script>
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import CodeEditor from '../../components/widget/CodeEditor.vue'

const example = `#ansible-playbook脚本
- hosts : $HOST
  remote_user : root
  tasks :
    - name : dir
      command : cd /root/ansible/quanta
      ignore_errors : True
      register : result
    - name : clone
      shell : cd /root/ansible && git clone http://oauth2:BZ1whjxTNc18uTe7f5Wp@10.100.0.19/gaven.yang/quanta.git/
      when : result.stderr
`

export default {
    name: 'Playbooks',
    components:{
        CodeEditor
    },
    created() {
        this.resetForm()
        bus.$emit('load_playbooks')
    },
    data() {
        return {
            form: {},
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入Playbook名字', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入Playbook描述', trigger: 'blur' },],
                script: [{ required: true, message: '请填入Playbook脚本', trigger: 'blur' },],
            },
        }
    },
    methods: {
        resetForm() {
            this.form = {
                id: '',
                name: '',
                desc: '',
                script: example,
            }
        },
        handleCreate() {
            this.resetForm()
            this.dialogStatus = 'create'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        handleUpdate(row) {
            this.form = Object.assign({}, row) // copy obj
            this.dialogStatus = 'update'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    this.form.id = utils.newGuid()
                    driver.insert("playbooks", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["PLAYBOOK", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    driver.update("playbooks", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["PLAYBOOK", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此Playbook，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var playbookids = []
                playbookids.push(row.id)
                driver.remove("playbooks", playbookids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["PLAYBOOK", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
