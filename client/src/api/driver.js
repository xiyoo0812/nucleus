const qs = require('qs');
import request from '@/utils/webreq'

export function find(url, key, psize, pnum) {
    return request({
        url: '/api/' + url,
        method: 'get',
        params: {
            key,
            psize,
            pnum,
        }
    })
}

export function load(url, psize, pnum) {
    var key = ''
    return request({
        url: '/api/' + url,
        method: 'get',
        params: {
            key,
            psize,
            pnum,
        }
    })
}

export function insert(url, args) {
    return request({
        url: '/api/' + url,
        method: 'put',
        params: {
            args
        }
    })
}

export function update(url, args) {
    return request({
        url: '/api/' + url,
        method: 'post',
        data: {
            args
        }
    })
}

export function remove(url, args) {
    return request({
        url: '/api/' + url,
        method: 'delete',
        params: {
            args
        },
        paramsSerializer : function(params) {
            return qs.stringify(params, {arrayFormat: 'repeat'})
        }
    })
}
