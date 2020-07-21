<template>
    <el-select v-model="form[prop]" placeholder="请选择代码库" clearable filterable @change="handleSelect">
        <el-option v-for="item in codes" :key="item.id" :label="item.name" :value="item.id"/>
    </el-select>
</template>

<script>
import { codeAll } from '../../api/code'

export default {
    name: 'CodeSelect',
    props: {
        form: {
            type: Object,
            default: () => {}
        },
        prop: {
            type: String,
            default: 'code'
        },
    },
    data() {
        return {
            codes: [],
        }
    },
    watch: {
        prop() {
            this.getCodes()
        }
    },
    mounted() {
        this.getCodes()
    },
    methods: {
        getCodes() {
            codeAll().then(res => {
                if (res.code !== 0) {
                    this.showFailed(res.msg)
                    return
                }
                this.codes = res.data.codes.reverse()
            })
        },
        handleSelect(id) {
            var code = this.codes.filter(e => { return e.id === id })[0]
            this.$emit('change', id, code)
        },
        showFailed(msg) {
            this.$notify({title: '失败', message: msg, type: 'fail', duration: 2000 })
        }
    }
}
</script>
