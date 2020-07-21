<template lang="html">
    <div class="feishu-wrap">
        <div class="ms-title">Nuclues | 聚变 登录中...</div>
    </div>
</template>
<script>

import * as auth from "../../utils/auth";
import * as utils from '../../utils/index';

export default {
   mounted() {
        this.$router.onReady(() => {
            var tokenData = auth.getToken()
            if (tokenData) {
                this.$router.push({ path: this.$route.query.redirect || '/' })
                return
            }
            var url = utils.getBaseUrl(window.location.href)
            window.location.href = "http://ex.idreamsky.com:40008/login?redirect_url=" + url + "/login"
        })
    },
}
</script>

<style scoped>
.feishu-wrap {
    position: relative;
    width: 100%;
    height: 100%;
    background-image: url(../../assets/img/login-bg.jpg);
    background-size: 100%;
}
.ms-title {
    width: 100%;
    line-height: 50px;
    text-align: center;
    font-size: 20px;
    color: #fff;
    border-bottom: 1px solid #ddd;
}
</style>
