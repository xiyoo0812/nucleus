const qs = require('qs');
import request from '@/utils/webreq'

export function getRoles() {
    return request({
        url: '/api/role',
        method: 'get',
    })
}

export function roleAdd(role) {
    return request({
        url: '/api/role',
        method: 'put',
        params: {
            role
        }
    })
}

export function roleUpdate(role) {
    return request({
        url: '/api/role',
        method: 'post',
        data: {
            role
        }
    })
}

export function roleDelete(roles) {
    return request({
        url: '/api/role',
        method: 'delete',
        params: {
            roles
        },
        paramsSerializer: function(params) {
            return qs.stringify(params, {arrayFormat: 'repeat'})
        }
    })
}
