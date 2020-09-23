<template>
    <el-select v-model="attr" :placeholder="holder" :clearable="clear" :filterable="filter" @change="handleSelect">
        <el-option v-for="item in objs" :key="item[key]" :label="item[label]" :value="item[key]"/>
    </el-select>
</template>

<script>
export default {
    name: 'Selecter',
    props: {
        attr: null,
        objs: {
            type: Array,
            default: () => {}
        },
        key: {
            type: String,
            default: "id"
        },
        label: {
            type: String,
            default: "name"
        },
        holder: {
            type: String,
            default: "请选择"
        },
        clear: {
            type: Boolean,
            default: false
        },
        filter: {
            type: Boolean,
            default: true
        },
    },
    methods: {
        handleSelect(key) {
            var obj = this.objs.filter(e => { return e[this.key] === key })[0]
            this.$emit('change', key, obj)
        },
    }
}
</script>
