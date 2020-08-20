const qs = require('qs');
import request from '@/utils/webreq'

export function getUsers(key, pageSize, pageNo) {
    return request({
        url: '/api/user',
        method: 'get',
        params: {
            key,
            pageSize,
            pageNo,
        }
    })
}

export function userUpdate(user) {
    return request({
        url: '/api/user',
        method: 'post',
        data: {
            user
        }
    })
}

export function userDelete(users) {
    return request({
        url: '/api/user',
        method: 'delete',
        params:{
            users,
        },
        paramsSerializer: function(params) {
            return qs.stringify(params, {arrayFormat: 'repeat'})
        }
    })
}
