import Vue from 'vue'
import Router from 'vue-router';
import {getToken} from "../utils/auth";

Vue.use(Router);

const router = new Router({
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
                    meta: { title: '系统首页' }
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
            component: () => import(/* webpackChunkName: "login" */ '../views/Login.vue')
        },
        {
            path: '*',
            redirect: '/404'
        },
    ]
})

router.beforeEach((route, redirect, next) => {
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
    if (route.path == '/login') {
        if (tokenData){
            next('/')
            return
        }
    }
    next();
})

export default router
