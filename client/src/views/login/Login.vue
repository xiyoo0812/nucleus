<template lang="html">
    <div class="login-wrap">
        <div class="ms-login">
            <div class="ms-title">Nuclues | 聚变</div>
            <el-form :model="form" :rules="rules" ref="login" label-width="0px" class="ms-content">
                <el-form-item prop="username">
                    <el-input v-model="form.username" placeholder="username">
                        <el-button slot="prepend" icon="el-icon-lx-people"></el-button>
                    </el-input>
                </el-form-item>
                <el-form-item prop="password">
                    <el-input type="password" placeholder="password" v-model="form.password" @keyup.enter.native="login()">
                        <el-button slot="prepend" icon="el-icon-lx-lock"></el-button>
                    </el-input>
                </el-form-item>
                <div class="login-btn">
                    <el-button type="primary" @click="login()">登录</el-button>
                </div>
                <el-row>
                    <el-col :span="12">
                        <div class="login-btn">
                            <el-button @click="feishu()" type="text">飞书登录</el-button>
                        </div>
                    </el-col>
                    <el-col :span="12">
                        <div class="login-btn">
                            <router-link :to="{ path: '/reset' }">
                                <el-button type="text"> 忘记密码?</el-button>
                            </router-link>
                        </div>
                    </el-col>
                </el-row>
            </el-form>
        </div>
    </div>
</template>

<script>
import * as auth from "../../utils/auth";
import * as utils from '../../utils/index';
import * as login_api from '../../api/login';

export default {
    name: 'login',
    data: function() {
        return {
            form: {
                username: 'admin',
                password: '123123',
                is_remember: false,
            },
            interval: null,
            rules: {
                username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
                password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
            },
        };
    },

    watch: {
        $route: {
            handler: function(route) {
                if (route.query.ticket) {
                    login_api.feishu(route.query.ticket).then(res => {
                        if (res.code == 0){
                            utils.showSuccess(this, '登录成功')
                            this.$store.dispatch("Login", res.user)
                            this.$router.push({ path: this.$route.query.redirect || '/' })
                        } else if (res.code == -1){
                            utils.showFailed(this, "飞书登录验证失败")
                        }
                    });
                }
            },
            immediate: true
        }
    },
    mounted() {
        var tokenData = auth.getToken()
        if (tokenData) {
            this.$router.push({ path: this.$route.query.redirect || '/' })
            return
        }
    },
    methods: {
        login() {
            this.$refs.login.validate(valid => {
                if (valid) {
                    login_api.login(this.form.username, this.form.password).then(res => {
                        if (res.code == 0){
                            utils.showSuccess(this, '登录成功')
                            this.$store.dispatch("Login", this.form)
                            this.$router.push({ path: this.$route.query.redirect || '/' })
                        } else if (res.code == -1){
                            utils.showFailed(this, "数据库错误，登录失败，请联系管理员")
                        } else if (res.code == -2){
                            utils.showFailed(this, "账号不存在")
                        } else if (res.code == -3){
                            utils.showFailed(this, "密码错误")
                        }
                    });
                } else {
                    utils.showFailed(this, '请输入账号和密码')
                    return false
                }
            })
        },
        feishu() {
            var url = utils.getBaseUrl(window.location.href)
            window.location.href = "http://ex.idreamsky.com:40008/login?redirect_url=" + url + "/login"
        }
    },
}
</script>

<style scoped>
.login-wrap {
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
.ms-login {
    position: absolute;
    left: 50%;
    top: 50%;
    width: 350px;
    margin: -190px 0 0 -175px;
    border-radius: 5px;
    background: rgba(255, 255, 255, 0.3);
    overflow: hidden;
}
.ms-content {
    padding: 30px 30px;
}
.login-btn {
    text-align: center;
}
.login-btn button {
    width: 100%;
    height: 36px;
    margin-bottom: 10px;
}
.login-tips {
    font-size: 12px;
    line-height: 30px;
    color: #fff;
}
</style>
