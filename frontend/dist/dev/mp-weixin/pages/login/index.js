"use strict";
const common_vendor = require("../../common/vendor.js");
const utils_api = require("../../utils/api.js");
const _sfc_main = {
  data() {
    return {
      // 手机登录表单
      phoneForm: {
        phone: "",
        code: "",
        nickname: ""
      },
      // 状态管理
      isPhoneLogging: false,
      isWechatLogging: false,
      isSendingSMS: false,
      smsCountdown: 0,
      // 开发环境标识
      isDevelopment: true,
      debugInfo: ""
    };
  },
  computed: {
    // 是否可以发送短信
    canSendSMS() {
      return this.phoneForm.phone.length === 11 && /^1[3-9]\d{9}$/.test(this.phoneForm.phone);
    },
    // 是否可以手机登录
    canPhoneLogin() {
      return this.canSendSMS && this.phoneForm.code.length === 6;
    },
    // 短信按钮文本
    getSMSButtonText() {
      if (this.isSendingSMS)
        return "发送中...";
      if (this.smsCountdown > 0)
        return `${this.smsCountdown}s`;
      return "获取验证码";
    }
  },
  methods: {
    // 手机号输入处理
    onPhoneInput(e) {
      this.phoneForm.phone = e.detail.value.replace(/\D/g, "");
    },
    // 发送短信验证码
    async sendSMS() {
      if (!this.canSendSMS || this.isSendingSMS)
        return;
      this.isSendingSMS = true;
      this.debugInfo = "正在发送验证码...";
      try {
        const response = await utils_api.authAPI.sendSMS({
          phone: this.phoneForm.phone,
          purpose: "login"
        });
        common_vendor.index.showToast({
          title: "验证码发送成功",
          icon: "success"
        });
        if (response.code && this.isDevelopment) {
          this.debugInfo = `验证码: ${response.code}`;
          this.phoneForm.code = response.code;
        } else {
          this.debugInfo = "请查收短信验证码";
        }
        this.startCountdown();
      } catch (error) {
        console.error("发送验证码失败:", error);
        this.debugInfo = `发送失败: ${error.message}`;
        common_vendor.index.showToast({
          title: error.message || "验证码发送失败",
          icon: "none"
        });
      } finally {
        this.isSendingSMS = false;
      }
    },
    // 开始倒计时
    startCountdown() {
      this.smsCountdown = 60;
      const timer = setInterval(() => {
        this.smsCountdown--;
        if (this.smsCountdown <= 0) {
          clearInterval(timer);
        }
      }, 1e3);
    },
    // 手机号登录
    async handlePhoneLogin() {
      if (!this.canPhoneLogin || this.isPhoneLogging)
        return;
      this.isPhoneLogging = true;
      this.debugInfo = "正在验证登录...";
      try {
        const response = await utils_api.authAPI.phoneLogin({
          phone: this.phoneForm.phone,
          code: this.phoneForm.code,
          nickname: this.phoneForm.nickname
        });
        utils_api.setToken(response.token);
        utils_api.setUser(response.user);
        this.debugInfo = `登录成功! ${response.is_new_user ? "(新用户)" : "(老用户)"}`;
        common_vendor.index.showToast({
          title: response.is_new_user ? "注册成功" : "登录成功",
          icon: "success"
        });
        setTimeout(() => {
          common_vendor.index.switchTab({
            url: "/pages/index/index"
          });
        }, 1500);
      } catch (error) {
        console.error("手机登录失败:", error);
        this.debugInfo = `登录失败: ${error.message}`;
        common_vendor.index.showToast({
          title: error.message || "登录失败",
          icon: "none"
        });
      } finally {
        this.isPhoneLogging = false;
      }
    },
    // 微信登录
    async handleWechatLogin() {
      if (this.isWechatLogging)
        return;
      this.isWechatLogging = true;
      this.debugInfo = "正在微信登录...";
      try {
        if (this.isDevelopment) {
          const mockCode = `mock_code_${Date.now()}`;
          const response = await utils_api.authAPI.wechatLogin({
            code: mockCode,
            nickname: "微信用户",
            gender: "unknown"
          });
          utils_api.setToken(response.token);
          utils_api.setUser(response.user);
          this.debugInfo = `微信登录成功! ${response.is_new_user ? "(新用户)" : "(老用户)"}`;
          common_vendor.index.showToast({
            title: response.is_new_user ? "注册成功" : "登录成功",
            icon: "success"
          });
          setTimeout(() => {
            common_vendor.index.switchTab({
              url: "/pages/index/index"
            });
          }, 1500);
        } else {
          common_vendor.index.showToast({
            title: "微信登录功能开发中",
            icon: "none"
          });
        }
      } catch (error) {
        console.error("微信登录失败:", error);
        this.debugInfo = `微信登录失败: ${error.message}`;
        common_vendor.index.showToast({
          title: error.message || "微信登录失败",
          icon: "none"
        });
      } finally {
        this.isWechatLogging = false;
      }
    },
    // 填入测试手机号
    fillTestPhone() {
      this.phoneForm.phone = "13800138000";
      this.phoneForm.nickname = "测试用户";
    },
    // 模拟微信登录
    mockWechatLogin() {
      this.handleWechatLogin();
    },
    // 显示隐私政策
    showPrivacyPolicy() {
      common_vendor.index.showModal({
        title: "用户协议与隐私政策",
        content: "我们承诺保护您的隐私，所有情绪数据仅用于个人分析，不会与第三方分享。",
        showCancel: false
      });
    }
  }
};
function _sfc_render(_ctx, _cache, $props, $setup, $data, $options) {
  return common_vendor.e({
    a: common_vendor.o([($event) => $data.phoneForm.phone = $event.detail.value, (...args) => $options.onPhoneInput && $options.onPhoneInput(...args)]),
    b: $data.phoneForm.phone,
    c: $data.phoneForm.phone ? 1 : "",
    d: $data.phoneForm.code,
    e: common_vendor.o(($event) => $data.phoneForm.code = $event.detail.value),
    f: common_vendor.t($options.getSMSButtonText),
    g: !$options.canSendSMS || $data.smsCountdown > 0 ? 1 : "",
    h: $data.isSendingSMS ? 1 : "",
    i: common_vendor.o((...args) => $options.sendSMS && $options.sendSMS(...args)),
    j: !$options.canSendSMS || $data.smsCountdown > 0 || $data.isSendingSMS,
    k: $data.phoneForm.code ? 1 : "",
    l: $data.phoneForm.nickname,
    m: common_vendor.o(($event) => $data.phoneForm.nickname = $event.detail.value),
    n: $data.phoneForm.nickname ? 1 : "",
    o: common_vendor.t($data.isPhoneLogging ? "登录中..." : "手机号登录"),
    p: $data.isPhoneLogging ? 1 : "",
    q: common_vendor.o((...args) => $options.handlePhoneLogin && $options.handlePhoneLogin(...args)),
    r: !$options.canPhoneLogin || $data.isPhoneLogging,
    s: common_vendor.t($data.isWechatLogging ? "登录中..." : "微信登录"),
    t: $data.isWechatLogging ? 1 : "",
    v: common_vendor.o((...args) => $options.handleWechatLogin && $options.handleWechatLogin(...args)),
    w: $data.isWechatLogging,
    x: $data.isDevelopment
  }, $data.isDevelopment ? common_vendor.e({
    y: common_vendor.o((...args) => $options.fillTestPhone && $options.fillTestPhone(...args)),
    z: common_vendor.o((...args) => $options.mockWechatLogin && $options.mockWechatLogin(...args)),
    A: $data.debugInfo
  }, $data.debugInfo ? {
    B: common_vendor.t($data.debugInfo)
  } : {}) : {}, {
    C: common_vendor.o((...args) => $options.showPrivacyPolicy && $options.showPrivacyPolicy(...args)),
    D: common_vendor.o((...args) => $options.showPrivacyPolicy && $options.showPrivacyPolicy(...args))
  });
}
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["render", _sfc_render], ["__scopeId", "data-v-45258083"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/login/index.vue"]]);
wx.createPage(MiniProgramPage);
