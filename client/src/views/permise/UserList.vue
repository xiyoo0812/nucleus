<template>
<div class="app-container">
    <imp-panel>
        <h3 class="box-title" slot="header" style="width: 100%;">
            <el-row style="width: 100%;">
                <el-col :span="12">
                <el-button type="primary" icon="plus" @click="handleDeleteAll()">批量删除</el-button>
                </el-col>
                <el-col :span="12">
                <div class="el-input" style="width: 200px; float: right;">
                    <el-input placeholder="输入用户名称" prefix-icon="el-icon-search" v-model="searchKey" @keyup.enter="search($event)"></el-input>
                </el-col>
            </el-row>
        </h3>
        <div slot="body">
            <el-table :data="userList" border style="width: 100%" :v-loading="userLoading" @selection-change="handleUserSelect">
                <el-table-column prop="id" type="selection" width="50">
                </el-table-column>
                <el-table-column label="头像" width="76">
                    <template slot-scope="scope"><img :src='scope.row.avatar'></template>
                </el-table-column>
                <el-table-column prop="empCode" label="ID" width="100"> </el-table-column>
                <el-table-column prop="en_name" label="用户名"> </el-table-column>
                <el-table-column prop="name" label="名称" width="100"> </el-table-column>
                <el-table-column prop="email" label="邮箱"> </el-table-column>
                <el-table-column prop="dept" label="部门" width="350"> </el-table-column>
                <el-table-column label="操作" width="250">
                <template slot-scope="scope">
                    <el-button size="small" type="info" icon="setting" @click="handleRoleConfig(scope.row)">配置角色</el-button>
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
    <el-dialog title="配置用户角色" :visible.sync="dialogConfigVisible" :close-on-click-modal="false" width="60%">
        <imp-panel>
            <el-scrollbar tag="div" class='is-empty' wrap-class="el-select-dropdown__wrap" view-class="el-select-dropdown__list">
                <el-tree ref="role" :v-loading="roleLoading" show-checkbox check-on-click-node node-key="id"
                    :data="roleList" :props="defaultProps">
                </el-tree>
            </el-scrollbar>
        </imp-panel>
        <span slot="footer" class="dialog-footer">
            <el-button @click="dialogConfigVisible = false">取 消</el-button>
            <el-button type="primary" @click="handleConfigSure">确 定</el-button>
        </span>
    </el-dialog>
</div>
</template>

<script>
import panel from "../../components/Panel.vue"
import * as utils from '../../utils/index';
import * as user_api from '../../api/user';
import * as role_api from '../../api/role';

export default {
    components: {
        'imp-panel': panel
    },
    data(){
        return {
            currentRow: {},
            userSelect: [],
            roleSelect: [],
            userLoading: false,
            roleLoading: false,
            dialogConfigVisible: false,
            defaultProps: {
                children: 'children',
                label: 'name',
                id: "id",
            },
            roleList: [],
            searchKey: '',
            pagination: {
                total: 0,
                pageNo: 1,
                pageSize: 10,
                parentId: 0
            },
            userList: []
        }
    },
    methods: {
        search(target){
            this.loadData();
        },
        handleUserSelect(val){
            this.userSelect = val
        },
        handleRoleConfig(row) {
            this.currentRow = row;
            this.dialogConfigVisible = true;
            if (this.roleList.length <= 0) {
                role_api.getRoles().then(res => {
                    if (res.code != 0) {
                        utils.showFailed(this, res.msg)
                        return
                    }
                    this.roleList = res.data
                })
            }
            this.$nextTick(() => {
                this.$refs.role.setCheckedKeys(row.roles);
            });
        },
        handleConfigSure(){
            var user_roles = {
                en_name : this.currentRow.en_name,
                roles : this.$refs.role.getCheckedKeys(),
            }
            user_api.userUpdate(user_roles).then(res => {
                if (res.code != 0) {
                    utils.showFailed(this, res.msg)
                    return
                }
                utils.showSuccess(this, "配置角色成功")
                this.dialogConfigVisible = false;
                for (let user of this.userList) {
                    if (user.en_name == user_roles.en_name) {
                        user = res.data
                        break
                    }
                }
            })
        },
        handleSizeChange(val) {
            this.pagination.pageSize = val;
            this.loadData();
        },
        handlePageChange(val) {
            this.pagination.pageNo = val;
            this.loadData();
        },
        handleDeleteAll(){
            if (this.userSelect.length > 0) {
                    var userlist = []
                var me_name = this.$store.getters.name
                for(var user of this.userSelect) {
                    userlist.push(user.en_name)
                    if (me_name != user.name) {
                        utils.showFailed(this, "不能删除自己")
                        return
                    }
                }
                user_api.userDelete(userlist).then(res => {
                    if (res.code != 0) {
                        utils.showFailed(this, res.msg)
                        return
                    }
                    this.loadData()
                });
            }
        },
        handleDelete(row){
            if (this.$store.getters.name == row.name) {
                utils.showFailed(this, "不能删除自己")
                return
            }
            var userlist = []
            userlist.push(user.en_name)
            user_api.userDelete(userlist).then(res => {
                if (res.code != 0) {
                    utils.showFailed(this, res.msg)
                    return
                }
                for (let index in this.userList) {
                    if (this.userList[index].en_name == row.en_name) {
                        this.userList.splice(index, 1)
                        break
                    }
                }
            });
        },
        loadData() {
            var pageNo = this.pagination.pageNo;
            var pageSize = this.pagination.pageSize;
            user_api.getUsers(this.searchKey, pageSize, pageNo).then(res => {
                if (res.code == 0) {
                    this.userList = res.data;
                    this.pagination.total = res.total;
                }
            });
        }
    },
    created(){
        this.loadData();
    }
}
</script>
<style>
.el-pagination {
    float: right;
    margin-top: 15px;
}
</style>
