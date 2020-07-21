import request from '@/utils/webreq'

export function login(username, password) {
    return request({
        url: '/api/login',
        method: 'get',
        params : {
            username,
            password,
        },
    })
}

export function logout() {
    return request({
        url: '/api/login',
        method: 'delete'
    })
}

export function register(username, password) {
    return request({
        url: '/api/login',
        method: 'put',
        params : {
            username,
            password,
        },
    })
}

export function reset() {
    return request({
        url: '/api/reset',
        method: 'post'
    })
}

export function feishu(ticket) {
    return request({
        url: '/api/feishu',
        method: 'get',
        params : {
            ticket,
        },
    })
}