<template>
    <div class="wrapper">
        <v-head></v-head>
        <v-sidebar></v-sidebar>
        <div class="content-box" :class="{'content-collapse':collapse}">
            <v-tags></v-tags>
            <div class="content">
                <transition name="move" mode="out-in">
                    <keep-alive :include="tagsList">
                        <router-view></router-view>
                    </keep-alive>
                </transition>
                <el-backtop target=".content"></el-backtop>
            </div>
        </div>
    </div>
</template>

<script>
    import bus from './bus'
    import vTags from './Tags.vue'
    import vHead from './Header.vue'
    import vSidebar from './Sidebar.vue'
    import * as utils from '../../utils/index'
    import * as driver from '../../api/driver'
    export default {
        data(){
            return {
                tagsList: [],
                dataLoad: {},
                collapse: false,
            }
        },
        components:{
            vHead, vSidebar, vTags
        },
        created(){
            bus.$on('collapse', msg => {
                this.collapse = msg;
            })
            // 只有在标签页列表里的页面才使用keep-alive，即关闭标签之后就不保存到内存中了。
            bus.$on('tags', msg => {
                let arr = [];
                for(let i = 0, len = msg.length; i < len; i ++){
                    msg[i].name && arr.push(msg[i].name);
                }
                this.tagsList = arr;
            }),
            bus.$on('load_owns', fload => {
                if (fload || this.dataLoad["load_owns"] == null){
                    this.dataLoad["load_owns"] = true
                    this.loadOwns()
                }
            })
            bus.$on('load_projects', fload => {
                if (fload || this.dataLoad["load_projects"] == null){
                    this.dataLoad["load_projects"] = true
                    this.loadProj()
                }
            })
            bus.$on('load_codes', fload => {
                if (fload || this.dataLoad["load_codes"] == null){
                    this.dataLoad["load_codes"] = true
                    this.loadCodes()
                }
            })
            bus.$on('load_hosts', fload => {
                if (fload || this.dataLoad["load_hosts"] == null){
                    this.dataLoad["load_hosts"] = true
                    this.loadHosts()
                }
            })
            bus.$on('load_authkeys', fload => {
                if (fload || this.dataLoad["load_authkeys"] == null){
                    this.dataLoad["load_authkeys"] = true
                    this.loadAuthkeys()
                }
            })
            bus.$on('load_playbooks', fload => {
                if (fload || this.dataLoad["load_playbooks"] == null){
                    this.dataLoad["load_playbooks"] = true
                    this.loadPlaybooks()
                }
            })
            bus.$on('load_plugins', fload => {
                if (fload || this.dataLoad["load_plugins"] == null){
                    this.dataLoad["load_plugins"] = true
                    this.loadPlugins()
                }
            })
            bus.$on('load_pipelines', fload => {
                if (fload || this.dataLoad["load_pipelines"] == null){
                    this.dataLoad["load_pipelines"] = true
                    this.loadPipelines()
                }
            })
            bus.$on('load_products', fload => {
                if (fload || this.dataLoad["load_products"] == null){
                    this.dataLoad["load_products"] = true
                    this.loadProducts()
                }
            })
            bus.$on('load_databases', fload => {
                if (fload || this.dataLoad["load_databases"] == null){
                    this.dataLoad["load_databases"] = true
                    this.loadDatabases()
                }
            })
            bus.$on('load_images', fload => {
                if (fload || this.dataLoad["load_images"] == null){
                    this.dataLoad["load_images"] = true
                    this.loadImages()
                }
            })
            bus.$on('load_logs', fload => {
                if (fload || this.dataLoad["load_logs"] == null){
                    this.dataLoad["load_logs"] = true
                    this.loadLogs()
                }
            })
        },
        methods: {
            loadOwns() {
                driver.load("owns").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["OWNS", res.data])
                        if (res.proj) {
                            this.$store.dispatch("SetProj", res.proj)
                            bus.$emit('project');
                        }
                        bus.$emit('owns');
                    })
                });
            },
            loadProj() {
                driver.load("projects").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["PROJ", res.data])
                    })
                });
            },
            loadDatabases() {
                driver.load("databases").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["DATABASE", res.data])
                    })
                })
            },
            loadHosts() {
                driver.load("hosts").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["HOST", res.data])
                    })
                })
            },
            loadCodes() {
                driver.load("codes").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["CODE", res.data])
                    })
                })
            },
            loadAuthkeys() {
                driver.load("authkeys").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["AUTHKEY", res.data])
                    })
                })
            },
            loadPlaybooks() {
                driver.load("playbooks").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["PLAYBOOK", res.data])
                    })
                })
            },
            loadPlugins() {
                driver.load("plugins").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["PLUGIN", res.data])
                    })
                })
            },
            loadPipelines() {
                driver.load("pipelines").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["PIPELINE", res.data])
                    })
                })
            },
            loadProducts() {
                driver.load("products").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["PRODUCT", res.data])
                    })
                })
            },
            loadImages() {
                driver.load("images").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["IMAGE", res.data])
                    })
                })
            },
            loadLogs() {
                driver.load("logs").then(res => {
                    utils.showNetRes(this, res, () => {
                        this.$store.dispatch("InitData", ["LOG", res.data])
                    })
                });
            },
        },
    }
</script>
