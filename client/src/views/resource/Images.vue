<template>
<div class="app-container">
    <h3>镜像管理</h3>
    <el-alert :closable="false" type="success" title="负责管Docker镜像生成和容器运行。"/>
    <div class="twt-tool-box">
        <el-button-group>
            <el-button class="filter-item" type="primary" @click="handleCreate">添加</el-button>
            <el-button v-waves :loading="downloadLoading" class="filter-item" @click="handleDownload">导出</el-button>
        </el-button-group>
    </div>
    <el-table stripe v-loading="listLoading" style="width: 100%" :key="tableKey" :data="images">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="描述">
            <template slot-scope="scope"><span >{{ scope.row.desc }}</span></template>
        </el-table-column>
        <el-table-column label="Dockerfile">
            <template slot-scope="scope">
                <div slot="reference" class="name-wrapper">
                    <p v-for="item in scope.row.file.split('\n').filter(item=>item.indexOf('#') < 0)" :key="item">{{ item }}</p>
                </div>
            </template>
        </el-table-column>
        <el-table-column label="操作" align="center">
            <template slot-scope="scope">
                <el-button size="mini" @click="handleUpdate(scope.row)">编辑</el-button>
                <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
    <div class="pagination-container">
        <el-pagination v-show="total>0" :total="total" layout="total"/>
    </div>
    <el-dialog width="70%" :title="textMap[dialogStatus]" :visible.sync="dialogFormVisible" :close-on-click-modal="false" >
        <el-form ref="dataForm" :rules="rules" :model="form" label-position="left" label-width="120px">
            <el-form-item label="名称" prop="type">
                <el-select v-model="form.name" placeholder="类型" clearable filterable>
                    <el-option v-for="item in type_list" :key="item" :label="item" :value="item"/>
                </el-select>
            </el-form-item>
            <el-form-item label="描述" prop="desc">
                <el-input v-model="form.desc" placeholder="desc"/>
            </el-form-item>
            <el-form-item label="Dockerfile" prop="file">
                <ScriptShow ref="ScriptShow" :form="form" prop="file" @change="handleExample"/>
            </el-form-item>
            <el-form-item>
                <el-button @click="dialogFormVisible = false">取消</el-button>
                <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
            </el-form-item>
        </el-form>
    </el-dialog>
</div>
</template>

<script>
import ScriptShow from '@/components/widget/ScriptShow'
import {imageAll, imageNew, imageDelete, imageUpdate } from '../../api/image'
export default {
    name: 'Image',
    components: {
        ScriptShow
    },
    data() {
        return {
            tableKey: 0,
            form: {},
            images: [],
            dialogStatus: '',
            listLoading: false,
            downloadLoading: false,
            dialogFormVisible: false,
            textMap: { update: '编辑', create: '新建' },
            type_list: [ "hive", "ds", "hive-admin"],
            rules: {
                name: [{ required: true, message: '请填入镜像规则名', trigger: 'blur' }],
                desc: [{ required: true, message: '请填入镜像规则描述', trigger: 'blur' }],
                file: [{ required: true, message: '请填入镜像生成规则', trigger: 'blur' }],
            },
        }
    },
    mounted() {
        this.resetForm()
        this.getImages()
    },
    methods: {
        getImages() {
            imageAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                this.images = res.data.images.reverse()
            })
        },
        resetForm() {
            this.form = {
                name: 'hive',
                file: '',
                desc: '',
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
        createData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    imageNew(this.form).then(res => {
                        if (res.code !== 0) {
                            this.showFailed(res.msg)
                            return
                        }
                        this.getImages()
                        this.showSuccess('操作成功')
                        this.dialogFormVisible = false
                    })
                }
            })
        },
        handleUpdate(row) {
            this.resetForm()
            this.form = Object.assign({}, row) // copy obj
            this.dialogStatus = 'update'
            this.dialogFormVisible = true
            this.$nextTick(() => {
                this.$refs['dataForm'].clearValidate()
            })
        },
        updateData() {
            this.$refs['dataForm'].validate((valid) => {
                if (valid) {
                    imageUpdate(this.form).then(res => {
                        if (res.code !== 0) {
                            this.showFailed(res.msg)
                            return
                        }
                        this.getImages()
                        this.showSuccess('操作成功')
                        this.dialogFormVisible = false
                    })
                }
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此镜像，是否继续?', '提示', { 
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.form = Object.assign({}, row)
                imageDelete(this.form).then(res => {
                    if (res.code !== 0) {
                        this.showFailed(res.msg)
                        return
                    }
                    this.getImages()
                    this.showSuccess('操作成功')
                })
            }).catch(() => {})
        },
        handleExample() {
            //示例代码写到script_show组件
            this.$nextTick(() => {
                if(this.form.name == "hive") {
                    this.$refs.ScriptShow.showExample(4)
                } else if(this.form.name == "ds") {
                    this.$refs.ScriptShow.showExample(5)
                } else {
                    this.$refs.ScriptShow.showExample(6)
                }
            })
        },
        showSuccess(msg) {
            this.$notify({title: '成功', message: msg, type: 'success', duration: 2000 })
        },
        showFailed(msg) {
            this.$notify({title: '失败', message: msg, type: 'fail', duration: 2000 })
        }
    }
}
</script>
