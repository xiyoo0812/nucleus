import request from '@/utils/webreq'

export function getMenus() {
    return request({
        url: '/api/menus',
        method: 'get'
    })
}
