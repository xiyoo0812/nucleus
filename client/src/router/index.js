import Vue from 'vue'
import Router from 'vue-router';
import * as auth from "../utils/auth";

Vue.use(Router);

const router = new Router({
    mode: 'history',
    routes : [
        {
            path: '/',
            redirect: '/dashboard'
        },
        {
            path: '/',
            component: () => import(/* webpackChunkName: "home" */ '../components/common/Home.vue'),
            meta: { title: '自述文件' },
            children: [
                {
                    path: '/dashboard',
                    component: () => import(/* webpackChunkName: "dashboard" */ '../views/Dashboard.vue'),
                    meta: { title: '我的主页' }
                },
                {
                    path: '/auths',
                    component: () => import(/* webpackChunkName: "auths" */ '../views/project/Auths.vue'),
                    meta: { title: '项目权限' }
                },
                {
                    path: '/members',
                    component: () => import(/* webpackChunkName: "members" */ '../views/project/Members.vue'),
                    meta: { title: '成员列表' }
                },
                {
                    path: '/applys',
                    component: () => import(/* webpackChunkName: "applys" */ '../views/project/Applys.vue'),
                    meta: { title: '申请列表' }
                },
                {
                    path: '/projects',
                    component: () => import(/* webpackChunkName: "projects" */ '../views/project/Projects.vue'),
                    meta: { title: '所有项目' }
                },
                {
                    path: '/owns',
                    component: () => import(/* webpackChunkName: "owns" */ '../views/project/MeProjects.vue'),
                    meta: { title: '我的项目' }
                },
                {
                    path: '/databases',
                    component: () => import(/* webpackChunkName: "databases" */ '../views/resource/Databases.vue'),
                    meta: { title: '数据库' }
                },
                {
                    path: '/environs',
                    component: () => import(/* webpackChunkName: "environs" */ '../views/resource/Environs.vue'),
                    meta: { title: '运行环境' }
                },
                {
                    path: '/templates',
                    component: () => import(/* webpackChunkName: "templates" */ '../views/resource/Templates.vue'),
                    meta: { title: '配置模板' }
                },
                {
                    path: '/routers',
                    component: () => import(/* webpackChunkName: "routers" */ '../views/resource/Routers.vue'),
                    meta: { title: '路由列表' }
                },
                {
                    path: '/codes',
                    component: () => import(/* webpackChunkName: "codes" */ '../views/resource/Codes.vue'),
                    meta: { title: '代码库' }
                },
                {
                    path: '/hosts',
                    component: () => import(/* webpackChunkName: "hosts" */ '../views/resource/Hosts.vue'),
                    meta: { title: '主机配置' }
                },
                {
                    path: '/nodes',
                    component: () => import(/* webpackChunkName: "nodes" */ '../views/resource/Nodes.vue'),
                    meta: { title: '节点配置' }
                },
                {
                    path: '/authkeys',
                    component: () => import(/* webpackChunkName: "authkeys" */ '../views/resource/AuthKeys.vue'),
                    meta: { title: '密钥配置' }
                },
                {
                    path: '/images',
                    component: () => import(/* webpackChunkName: "images" */ '../views/resource/Images.vue'),
                    meta: { title: 'Docker镜像' }
                },
                {
                    path: '/playbooks',
                    component: () => import(/* webpackChunkName: "playbooks" */ '../views/resource/Playbooks.vue'),
                    meta: { title: 'Playbook' }
                },
                {
                    path: '/plugins',
                    component: () => import(/* webpackChunkName: "plugins" */ '../views/devops/Plugins.vue'),
                    meta: { title: '插件管理' }
                },
                {
                    path: '/products',
                    component: () => import(/* webpackChunkName: "products" */ '../views/devops/Products.vue'),
                    meta: { title: '制品管理' }
                },
                {
                    path: '/pipelines',
                    component: () => import(/* webpackChunkName: "pipelines" */ '../views/devops/Pipelines.vue'),
                    meta: { title: '流水线' }
                },
                {
                    path: '/task',
                    component: () => import(/* webpackChunkName: "task" */ '../views/devops/Task.vue'),
                    meta: { title: '任务' }
                },
                {
                    path: '/404',
                    component: () => import(/* webpackChunkName: "404" */ '../views/404.vue'),
                    meta: { title: '404' }
                },
                {
                    path: '/403',
                    component: () => import(/* webpackChunkName: "403" */ '../views/403.vue'),
                    meta: { title: '403' }
                },
            ]
        },
        {
            path: '/login',
            component: () => import(/* webpackChunkName: "login" */ '../views/login/Login.vue'),
            meta: { requireAuth: false}
        },
        {
            path: '/feishu',
            component: () => import(/* webpackChunkName: "feishu" */ '../views/login/Feishu.vue'),
            meta: { requireAuth: false}
        },
        {
            path: '*',
            redirect: '/404'
        },
    ]
})

router.beforeEach((route, redirect, next) => {
    if (route.meta.requireAuth == false) {
        next();
        return
    }
    var userToken = auth.getLocUser()
    if (route.path !== '/login') {
        if (!userToken){
            next({
                path: "/login",
                query: {redirect: route.path }
            })
            return
        }
    }
    
    next();
})

export default router
