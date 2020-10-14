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
                    path: '/databases',
                    component: () => import(/* webpackChunkName: "databases" */ '../views/resource/Databases.vue'),
                    meta: { title: '数据库' }
                },
                {
                    path: '/codes',
                    component: () => import(/* webpackChunkName: "codes" */ '../views/resource/Codes.vue'),
                    meta: { title: '代码库' }
                },
                {
                    path: '/hosts',
                    component: () => import(/* webpackChunkName: "hosts" */ '../views/resource/Hosts.vue'),
                    meta: { title: '主机' }
                },
                {
                    path: '/authkeys',
                    component: () => import(/* webpackChunkName: "authkeys" */ '../views/resource/AuthKeys.vue'),
                    meta: { title: '凭据' }
                },
                {
                    path: '/plugins',
                    component: () => import(/* webpackChunkName: "plugins" */ '../views/resource/Plugins.vue'),
                    meta: { title: '插件' }
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
