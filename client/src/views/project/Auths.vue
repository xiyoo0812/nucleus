<template>
<div class="app-container">
    <imp-panel>
        <h3>项目管理</h3>
        <h3 class="box-title" slot="header" style="width: 100%;">
            <el-button type="primary" icon="plus" @click="handleNew()">创建项目</el-button>
        </h3>
        <div slot="body">
            <el-table :data="$store.getters.projs" border style="width: 100%" :v-loading="listLoading">
                <el-table-column prop="id" width="50"></el-table-column>
                <el-table-column prop="name" label="名称"></el-table-column>
                <el-table-column prop="admin" label="管理员"></el-table-column>
                <el-table-column prop="desc" label="简介"></el-table-column>
                <el-table-column label="操作" width="300">
                    <template slot-scope="scope">
                        <el-button size="small" type="info" icon="setting" @click="handleModify(scope.row)">修改信息</el-button>
                        <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>
            <el-pagination @size-change="handleSizeChange" @current-change="handlePageChange"
                layout="total, sizes, prev, pager, next, jumper"
                :page-size="pagination.pageSize"
                :current-page="pagination.pageNo"
                :page-sizes="[5, 10, 20]"
                :total="pagination.total">
            </el-pagination>
        </div>
    </imp-panel>
    <el-dialog :title="textMap[dialogStatus]" :visible.sync="dialogVisible" :close-on-click-modal="false" width="60%">
        <el-card class="box-card">
            <el-form :model="form" :rules="rules" ref="form">
                <el-form-item prop="name" label="名称" label-width="100px">
                    <el-input v-model="form.name" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item prop="desc" label="简介" label-width="100px">
                    <el-input v-model="form.desc" auto-complete="off"></el-input>
                </el-form-item>
                <el-form-item label="" label-width="100px">
                    <el-button type="primary" @click="dialogStatus==='create' ? handleCreate() : handleUpdate()">确认</el-button>
                    <el-button @click="dialogVisible = false">取消</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </el-dialog>
</div>
</template>
<script>
import panel from "../../components/Panel.vue"
import * as utils from '../../utils/index';
import * as driver from '../../api/driver'
export default {
    components: {
        'imp-panel': panel,
    },
    data(){
        return {
            dialogVisible:false,
            dialogStatus: "create",
            textMap: { update: '编辑', create: '新建' },
            form: {
                id: null,
                name: '',
                admin: '',
                desc: '',
            },
            pagination: {
                total: 0,
                pageNo: 1,
                pageSize: 10,
                parentId: 0
            },
            rules: {
                name: [{ required: true, message: '请输入项目名', trigger: 'blur' }],
                desc: [{ required: true, message: '请输入项目简介', trigger: 'blur' }],
            },
        }
    },
    methods: {
        handleNew(){
            this.dialogStatus = "create";
            this.dialogVisible = true;
            this.form = {
                id: null,
                name: '',
                admin: '',
                desc: '',
            };
        },
        handleDelete(row){
            utils.confirm(this, "确定删除?", () => {
                var projlist = []
                projlist.push(row.id)
                driver.remove("project", projlist).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "删除成功");
                    this.$store.dispatch("DelData", ["PROJ", row.id, "id"])
                });
            });
        },
        handleUpdate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                driver.update("project", this.form).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "修改成功");
                    this.$store.dispatch("UpdateData", ["PROJ", this.form, "id"])
                })
            })
        },
        handleCreate() {
            this.dialogVisible = false
            this.$refs.form.validate(valid => {
                this.form.id = utils.newGuid()
                driver.insert("project", this.form).then(res => {
                    if (res.code != 0){
                        utils.showFailed(this, res.msg);
                        return;
                    }
                    utils.showSuccess(this, "创建成功");
                    this.$store.dispatch("AddData", ["PROJ", res.data])
                })
            })
        },
        handleModify(row){
            this.form = row
            this.dialogVisible = true;
            this.dialogStatus = "update";
        },
        handleSizeChange(val) {
            this.pagination.pageSize = val;
            this.loadProj();
        },
        handlePageChange(val) {
            this.pagination.pageNo = val;
            this.loadProj();
        },
        loadProj() {
            var pageNo = this.pagination.pageNo;
            var pageSize = this.pagination.pageSize;
            driver.load("project", this.searchKey, pageSize, pageNo).then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["PROJ", res.data])
                    this.pagination.total = res.total;
                })
            });
        },
    },
    created(){
        if (this.$store.getters.projs.length == 0) {
            this.loadProj();
        }
    }
}
</script>
