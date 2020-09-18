<template>
<div class="app-container">
    <imp-panel>
        <div slot="body">
            <el-table :data="this.$store.getters.users" border style="width: 100%" :v-loading="userLoading">
                <el-table-column prop="id" width="50"></el-table-column>
                <el-table-column label="头像" width="96">
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
    <el-dialog title="配置用户权限" :visible.sync="dialogConfigVisible" :close-on-click-modal="false" width="60%">
        <imp-panel>
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
import * as driver from '../../api/driver'

export default {
    components: {
        'imp-panel': panel
    },
    data(){
        return {
            currentRow: {},
            userLoading: false,
            dialogConfigVisible: false,
            pagination: {
                total: 0,
                pageNo: 1,
                pageSize: 10,
                parentId: 0
            },
        }
    },
    methods: {
        handleRoleConfig(row) {
            /*
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
            });*/
        },
        handleConfigSure(){
            /*
            var user_roles = {
                en_name : this.currentRow.en_name,
                roles : this.$refs.role.getCheckedKeys(),
            }
            driver.update(user_roles).then(res => {
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
            })*/
        },
        handleSizeChange(val) {
            this.pagination.pageSize = val;
            this.loadData();
        },
        handlePageChange(val) {
            this.pagination.pageNo = val;
            this.loadData();
        },
        handleDelete(row){
            if (this.$store.getters.name == row.name) {
                utils.showFailed(this, "不能删除自己")
                return
            }
            var userlist = []
            userlist.push(row.en_name)
            driver.remove("user", userlist).then(res => {
                if (res.code != 0) {
                    utils.showFailed(this, res.msg)
                    return
                }
                this.$store.dispatch("DelResource", ["USER", row.en_name, "en_name"])
            });
        },
        loadData() {
            var pageNo = this.pagination.pageNo;
            var pageSize = this.pagination.pageSize;
            driver.load("user", "", pageSize, pageNo).then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitResource", ["USER", res.data])
                    this.pagination.total = res.total;
                })
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
