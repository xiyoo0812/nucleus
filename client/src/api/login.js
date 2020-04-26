import request from '@/utils/webreq'

export function login(username, password) {
    return request({
        url: '/login/login',
        method: 'post',
        params : {
            username,
            password,
        },
    })
}

export function logout() {
    return request({
        url: '/login/logout',
        method: 'post'
    })
}

export function register() {
    return request({
        url: '/login/register',
        method: 'post'
    })
}

export function reset() {
    return request({
        url: '/login/reset',
        method: 'post'
    })
}

export function getMenus() {
    return request({
        url: '/menus',
        method: 'get'
    })
}
