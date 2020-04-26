import request from '@/utils/webreq'

export function login(username, password) {
    return request({
        url: '/login',
        method: 'post',
        params : {
            username,
            password,
        },
    })
}

export function logout() {
    return request({
        url: '/logout',
        method: 'post'
    })
}

export function getMenus() {
    return request({
        url: '/menus',
        method: 'get'
    })
}
