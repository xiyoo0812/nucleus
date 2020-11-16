<template>
<div class="app-container">
    <imp-panel>
        <h3>我的项目</h3>
        <h3 class="box-title" slot="header" style="width: 100%;">
            <el-button type="primary" icon="plus" @click="handleNew()">创建项目</el-button>
        </h3>
        <div slot="body">
            <el-table :data="$store.getters.owns" border style="width: 100%" :v-loading="listLoading">
                <el-table-column prop="name" label="项目名称" width="120"></el-table-column>
                <el-table-column prop="appid" label="APPID" width="100"></el-table-column>
                <el-table-column prop="path" label="项目路径" width="200"></el-table-column>
                <el-table-column prop="creator" label="项目创建者" width="120"></el-table-column>
                <el-table-column prop="desc" label="项目简介"></el-table-column>
                <el-table-column label="操作" width="250">
                    <template slot-scope="scope">
                        <el-button size="small" type="primary" @click="handleUpdate(scope.row)">编辑</el-button>
                        <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
    </imp-panel>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogVisible" :close-on-click-modal="false" width="60%">
        <el-card class="box-card">
            <el-form :model="form" :rules="rules" ref="form">
                <el-form-item prop="name" label="项目名称" label-width="100px">
                    <el-input v-model="form.name" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="appid" label="APPID" label-width="100px">
                    <el-input v-model="form.appid" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="path" label="项目路径" label-width="100px">
                    <el-input v-model="form.path" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="desc" label="项目简介" label-width="100px">
                    <el-input v-model="form.desc" rows="5" type='textarea' auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="" label-width="100px">
                    <el-button type="primary" @click="dialogStatus==='create'?createData():updateData()">确认</el-button>
                    <el-button @click="dialogVisible = false">取消</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </el-dialog>
</div>
</template>

<script>
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'
import panel from "../../components/Panel.vue"

export default {
    components: {
        'imp-panel': panel,
    },
    created(){
        bus.$emit('load_owns')
    },
    data(){
        return {
            form: {},
            dialogStatus: '',
            dialogVisible:false,
            textMap: { update: '编辑', create: '新建' },
            rules: {
                name: [{ required: true, message: '请输入项目名', trigger: 'blur' }],
                appid: [{ required: true, message: '请输入appid', trigger: 'blur' }],
                path: [{ required: true, message: '请输入项目路径', trigger: 'blur' }],
                desc: [{ required: true, message: '请输入项目简介', trigger: 'blur' }],
            },
        }
    },
    methods: {
        handleNew(){
            this.dialogStatus = 'create'
            this.dialogVisible = true;
            this.form = {
                appid: '',
                name: '',
                path: '',
                desc: '',
            };
        },
        handleUpdate(row){
            this.dialogStatus = 'update'
            this.dialogVisible = true;
            this.form = Object.assign({}, row) // copy obj
        },
        handleDelete(row){
            utils.confirm(this, "确定删除?", () => {
                var projlist = []
                projlist.push(row.id)
                driver.remove("projects", projlist).then(res => {
                    utils.showNetRes(this, res, () => {
                        utils.showSuccess(this, "删除成功");
                        this.$store.dispatch("DelData", ["PROJ", row.id, "id"])
                        this.$store.dispatch("DelData", ["OWNS", row.id, "id"])
                    })
                })
            })
        },
        updateData() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                driver.update("projects", this.form).then(res => {
                    utils.showNetRes(this, res, () => {
                        utils.showSuccess(this, "修改成功");
                        this.$store.dispatch("UpdateData", ["PROJ", this.form, "id"])
                        this.$store.dispatch("UpdateData", ["OWNS", this.form, "id"])
                    })
                })
            })
        },
        createData() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                this.form.id = utils.newGuid()
                driver.insert("projects", this.form).then(res => {
                    utils.showNetRes(this, res, () => {
                        utils.showSuccess(this, "创建成功");
                        this.$store.dispatch("AddData", ["PROJ", res.data])
                        this.$store.dispatch("AddData", ["OWNS", res.data])
                        if (this.$store.getters.proj == null) {
                            this.$store.dispatch("SetProj", res.data)
                        }
                    })
                })
            })
        },
    },
}
</script>
