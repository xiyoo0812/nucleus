<template>
<div class="app-container">
    <imp-panel>
        <h3>项目列表</h3>
        <div slot="body">
            <el-table :data="$store.getters.projs" border style="width: 100%" :v-loading="listLoading">
                <el-table-column prop="name" label="项目名称" width="120"></el-table-column>
                <el-table-column prop="appid" label="APPID" width="100"></el-table-column>
                <el-table-column prop="path" label="项目路径" width="200"></el-table-column>
                <el-table-column prop="creator" label="项目创建者" width="120"></el-table-column>
                <el-table-column prop="desc" label="项目简介"></el-table-column>
                <el-table-column label="操作" width="250">
                    <template slot-scope="scope">
                        <el-button size="small" type="primary" @click="handleJoin(scope.row)">申请加入</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </div>
    </imp-panel>
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
        bus.$emit('load_projects')
    },
    data(){
        return {}
    },
    methods: {
        handleJoin(row){
        },
    },
}
</script>
