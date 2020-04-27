<template>
    <div class="sidebar">
        <el-menu class="sidebar-el-menu" :default-active="onRoutes" :collapse="collapse" background-color="#324157"
            text-color="#bfcbd9" active-text-color="#20a0ff" unique-opened router>
            <template v-for="menu in menus">
                <template v-if="menu.subs">
                    <el-submenu :index="menu.index" :key="menu.index">
                        <template slot="title">
                            <i :class="menu.icon"></i><span slot="title">{{ menu.title }}</span>
                        </template>
                        <template v-for="subMenu in menu.subs">
                            <el-submenu v-if="subMenu.subs" :index="subMenu.index" :key="subMenu.index">
                                <template slot="title">{{ subMenu.title }}</template>
                                <el-menu-item v-for="(threeMenu,i) in subMenu.subs" :key="i" :index="threeMenu.index">
                                    {{ threeMenu.title }}
                                </el-menu-item>
                            </el-submenu>
                            <el-menu-item v-else :index="subMenu.index" :key="subMenu.index">
                                {{ subMenu.title }}
                            </el-menu-item>
                        </template>
                    </el-submenu>
                </template>
                <template v-else>
                    <el-menu-item :index="menu.index" :key="menu.index">
                        <i :class="menu.icon"></i><span slot="title">{{ menu.title }}</span>
                    </el-menu-item>
                </template>
            </template>
        </el-menu>
    </div>
</template>

<script>
    import bus from './bus'
    import { getMenus } from '../../api/menus'
    export default {
        data() {
            return {
                collapse: false,
                menus: [],
            }
        },
        computed:{
            onRoutes() {
                return this.$route.path.replace('/','')
            },
        },
        created(){
            this.getData()
            // 通过 Event Bus 进行组件间通信，来折叠侧边栏
            bus.$on('collapse', msg => {
                this.collapse = msg
            })
        },
        methods: {
            getData() {
                getMenus().then(res => {
                    this.menus = res.menus
                });
            },
        }
    }
</script>

<style scoped>
    .sidebar{
        display: block;
        position: absolute;
        left: 0;
        top: 70px;
        bottom:0;
        overflow-y: scroll;
    }
    .sidebar::-webkit-scrollbar{
        width: 0;
    }
    .sidebar-el-menu:not(.el-menu--collapse){
        width: 250px;
    }
    .sidebar > ul {
        height:100%;
    }
</style>
