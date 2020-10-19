<template>
<div class="app-container">
    <h3>Dockerfile管理</h3>
    <el-alert :closable="false" type="success" title="负责管理系统的所有Dockerfile脚本。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="$store.getters.images">
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
                <el-input v-model="form.name" maxlength="20" placeholder="image名称"/>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" maxlength="100" placeholder="image描述"/>
            </el-form-item>
            <el-form-item label="脚本" prop="script">
                <CodeEditor v-model="form.script" :code="form.script" height="400px" language="text/x-dockerfile"/>
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

const example = `#dockerfile脚本
#基础image
FROM ubuntu:16.04

RUN apt-get update \\
    && apt-get -y install wget \\
    && apt-get -y install ansible \\
    && apt-get -y install openssh-client \\
    && ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa -q \\
    && apt-get -y install --no-install-recommends wget gnupg ca-certificates \\
    && wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - \\
    && apt-get -y install --no-install-recommends software-properties-common \\
    && add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \\
    && apt-get update \\
    && apt-get -y install openresty

CMD ["/bin/bash"]
`

export default {
    name: 'Images',
    components:{
        CodeEditor
    },
    created() {
        this.resetForm()
        var store = this.$store.getters
        if (store.proj) {
            this.loadImages()
        }
    },
    data() {
        return {
            form: {},
            dialogStatus: '',
            listLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请填入Image名字', trigger: 'blur' },],
                desc: [{ required: true, message: '请填入Image描述', trigger: 'blur' },],
                script: [{ required: true, message: '请填入Image脚本', trigger: 'blur' },],
            },
        }
    },
    methods: {
        loadImages() {
            driver.load("images").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["IMAGE", res.data])
                })
            })
        },
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
                    driver.insert("images", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("AddData", ["IMAGE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    driver.update("images", this.form).then(res => {
                        utils.showNetRes(this, res, () => {
                            this.$store.dispatch("UpdateData", ["IMAGE", res.data, "id"])
                            this.dialogFormVisible = false
                        })
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此Image，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var imageids = []
                imageids.push(row.id)
                driver.remove("images", imageids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["IMAGE", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
