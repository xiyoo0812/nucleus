<template>
<div class="app-container">
    <el-card>
        <el-alert :closable="false" type="success" title="负责管理项目申请人员。"/>
        <el-table :data="$store.getters.applys" border style="width: 100%" :v-loading="listLoading">
            <el-table-column prop="id" width="50"></el-table-column>
            <el-table-column label="头像" width="96">
                <template slot-scope="scope"><img :src='scope.row.avatar'></template>
            </el-table-column>
            <el-table-column prop="empCode" label="ID" width="100"> </el-table-column>
            <el-table-column prop="en_name" label="用户名"> </el-table-column>
            <el-table-column prop="name" label="名称" width="100"> </el-table-column>
            <el-table-column prop="email" label="邮箱"> </el-table-column>
            <el-table-column prop="dept" label="部门" width="350"> </el-table-column>
            <el-table-column label="操作" width="300">
                <template slot-scope="scope">
                    <el-button size="small" type="info" @click="handleApplys(scope.row, true)">同意</el-button>
                    <el-button size="small" type="danger" @click="handleApplys(scope.row, false)">拒绝</el-button>
                </template>
            </el-table-column>
        </el-table>
    </el-card>
</div>
</template>

<script>
import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'

export default {
    data(){
        return {
        }
    },
    methods: {
        handleApplys(row, status) {
            var apply_info = { en_name : row.en_name, sure : status }
            driver.update("applys", apply_info).then(res => {
                 utils.showNetRes(this, res, () => {
                    this.$store.dispatch("DelData", ["APPLY", row.en_name, "en_name"])
                })
            })
        },
        loadApplys() {
            driver.load("applys").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["APPLY", res.data])
                })
            })
        },
    },
    created(){
        var store = this.$store.getters
        if (store.proj && store.applys.length == 0) {
            this.loadApplys()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadApplys()
            }
        })
    }
}
</script>
