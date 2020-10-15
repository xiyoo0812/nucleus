<template>
<div class="app-container">
    <h3>制品管理</h3>
    <el-alert :closable="false" type="success" title="管理项目生成的制品。"/>
    <el-table stripe v-loading="listLoading" style="width: 100%" :data="this.$store.getters.products">
        <el-table-column label="名称">
            <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
        </el-table-column>
        <el-table-column label="代码库">
            <template slot-scope="scope"><span >{{ scope.row.code }}</span></template>
        </el-table-column>
        <el-table-column label="分支">
            <template slot-scope="scope"><span >{{ scope.row.branch }}</span></template>
        </el-table-column>
        <el-table-column label="提交日志">
            <template slot-scope="scope"><span >{{ scope.row.logs }}</span></template>
        </el-table-column>
        <el-table-column label="操作者">
            <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
        </el-table-column>
        <el-table-column label="生成时间">
            <template slot-scope="scope"><span >{{ formatTime(scope.row.time) }}</span></template>
        </el-table-column>
        <el-table-column label="操作" align="center">
            <template slot-scope="scope">
                <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
        </el-table-column>
    </el-table>
</div>
</template>

<script>

import * as utils from '../../utils/index'
import * as driver from '../../api/driver'
import bus from '../../components/common/bus'

export default {
    name: 'Products',
    data() {
        return {
            listLoading: false,
        }
    },
    created() {
        var store = this.$store.getters
        if (store.proj) {
            this.loadProducts()
        }
        bus.$on('project', msg => {
            if (store.proj) {
                this.loadProducts()
            }
        })
    },
    methods: {
        formatTime(val) {
            return utils.formatTime(val)
        },
        loadProducts() {
            driver.load("products").then(res => {
                utils.showNetRes(this, res, () => {
                    this.$store.dispatch("InitData", ["PRODUCT", res.data])
                })
            })
        },
        handleDelete(row) {
            this.$confirm('确定要删除此制品，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var packageids = []
                packageids.push(row.id)
                driver.remove("products", packageids).then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["PRODUCT", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
