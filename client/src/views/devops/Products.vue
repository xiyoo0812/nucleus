<template>
<div class="app-container">
    <el-card>
        <el-alert :closable="false" type="success" title="管理项目生成的制品。"/>
        <el-button-group style="margin-top:10px; margin-bottom:10px;">
            <Selecter v-model="code" :option="code" clear="true" opid="name" placeholder="请选择代码库" :options="$store.getters.codes"/>
        </el-button-group>
        <el-table stripe v-loading="listLoading" style="width: 100%" :data="filterProducts">
            <el-table-column label="名称">
                <template slot-scope="scope"><span >{{ scope.row.name }}</span></template>
            </el-table-column>
            <el-table-column label="代码库">
                <template slot-scope="scope"><span >{{ scope.row.code }}</span></template>
            </el-table-column>
            <el-table-column label="分支">
                <template slot-scope="scope"><span >{{ scope.row.branch }}</span></template>
            </el-table-column>
            <el-table-column label="操作者">
                <template slot-scope="scope"><span >{{ scope.row.creator }}</span></template>
            </el-table-column>
            <el-table-column label="生成时间">
                <template slot-scope="scope"><span >{{ formatTime(scope.row.time) }}</span></template>
            </el-table-column>
            <el-table-column label="最后提交" width="350">
                <template slot-scope="scope">
                    <div class="name-wrapper"><p v-for="item in scope.row.log.split(' ')" :key="item">{{ item }}</p></div>
                </template>
            </el-table-column>
            <el-table-column label="操作">
                <template slot-scope="scope">
                    <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
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
import Selecter from '../../components/widget/Selecter.vue'

export default {
    name: 'Products',
    components:{
        Selecter,
    },
    data() {
        return {
            code : "",
            listLoading: false,
        }
    },
    created() {
        var store = this.$store.getters
        if (store.proj) {
            bus.$emit('load_codes')
            bus.$emit('load_products')
        }
        bus.$on('product', msg => {
            if (store.proj) {
                bus.$emit('load_products', true)
            }
        })
        bus.$on('project', msg => {
            if (store.proj) {
                this.code = ""
                bus.$emit('load_products', true)
            }
        })
    },
    computed: {
        filterProducts() {
            return this.$store.getters.products.filter(product => {
                return (this.code == "" || product.code == this.code)
            })
        }
    },
    methods: {
        formatTime(val) {
            return utils.formatTime(val)
        },
        handleDelete(row) {
            this.$confirm('确定要删除此制品，是否继续?', '提示', {
                confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
            }).then(() => {
                var productids = []
                productids.push(row.id)
                this.listLoading = true
                driver.remove("products", productids).then(res => {
                    this.listLoading = false
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("DelData", ["PRODUCT", row.id, "id"])
                    })
                })
            }).catch(() => {})
        },
    }
}
</script>
