const qs = require('qs');
import request from '@/utils/webreq'

export function getResources() {
    return request({
        url: '/api/resource',
        method: 'get',
    })
}

export function resourceAdd(resource) {
    return request({
        url: '/api/resource',
        method: 'put',
        params: {
            resource
        }
    })
}

export function resourceUpdate(resource) {
    return request({
        url: '/api/resource',
        method: 'post',
        data: {
            resource
        }
    })
}

export function resourceDelete(resources) {
    return request({
        url: '/api/resource',
        method: 'delete',
        params: {
            resources
        },
        paramsSerializer: function(params) {
            return qs.stringify(params, {arrayFormat: 'repeat'})
        }
    })
}
