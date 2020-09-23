import Vue from 'vue'
import Router from 'vue-router';
import {getToken} from "../utils/auth";

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
                    path: '/projlist',
                    component: () => import(/* webpackChunkName: "404" */ '../views/project/ProjList.vue'),
                    meta: { title: '项目管理' }
                },
                {
                    path: '/userlist',
                    component: () => import(/* webpackChunkName: "404" */ '../views/project/UserList.vue'),
                    meta: { title: '用户管理' }
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
    var tokenData = getToken()
    if (route.path !== '/login') {
        if (!tokenData){
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
