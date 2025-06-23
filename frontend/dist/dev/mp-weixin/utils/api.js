"use strict";
const common_vendor = require("../common/vendor.js");
const API_BASE_URL = "http://127.0.0.1:8000/api/v1";
const request = async (url, options = {}) => {
  const token = getToken();
  const defaultOptions = {
    headers: {
      "Content-Type": "application/json",
      ...token && { "Authorization": `Token ${token}` }
    }
  };
  const finalOptions = {
    ...defaultOptions,
    ...options,
    headers: {
      ...defaultOptions.headers,
      ...options.headers
    }
  };
  try {
    const response = await fetch(`${API_BASE_URL}${url}`, finalOptions);
    if (!response.ok) {
      if (response.status === 401) {
        removeToken();
        removeUser();
        common_vendor.index.reLaunch({
          url: "/pages/login/login"
        });
        throw new Error("登录已过期，请重新登录");
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error("API请求失败:", error);
    throw error;
  }
};
const getToken = () => {
  return common_vendor.index.getStorageSync("token") || null;
};
const setToken = (token) => {
  common_vendor.index.setStorageSync("token", token);
};
const removeToken = () => {
  common_vendor.index.removeStorageSync("token");
};
const getUser = () => {
  const userStr = common_vendor.index.getStorageSync("user");
  return userStr ? JSON.parse(userStr) : null;
};
const setUser = (user) => {
  common_vendor.index.setStorageSync("user", JSON.stringify(user));
};
const removeUser = () => {
  common_vendor.index.removeStorageSync("user");
};
const authAPI = {
  // 传统密码登录 (兼容)
  login: (data) => request("/auth/login/", {
    method: "POST",
    body: JSON.stringify(data)
  }),
  // 传统密码注册 (兼容)
  register: (data) => request("/auth/register/", {
    method: "POST",
    body: JSON.stringify(data)
  }),
  // 发送短信验证码
  sendSMS: (data) => request("/auth/sms/send/", {
    method: "POST",
    body: JSON.stringify(data)
  }),
  // 手机验证码登录
  phoneLogin: (data) => request("/auth/phone/login/", {
    method: "POST",
    body: JSON.stringify(data)
  }),
  // 手机号注册
  phoneRegister: (data) => request("/auth/phone/register/", {
    method: "POST",
    body: JSON.stringify(data)
  }),
  // 微信登录
  wechatLogin: (data) => request("/auth/wechat/login/", {
    method: "POST",
    body: JSON.stringify(data)
  }),
  // 获取用户信息
  getUserInfo: () => request("/auth/profile/", {
    method: "GET"
  }),
  // 更新用户信息
  updateUserInfo: (data) => request("/auth/profile/", {
    method: "PUT",
    body: JSON.stringify(data)
  }),
  // 更新个人资料（别名）
  updateProfile: (data) => request("/auth/profile/", {
    method: "PATCH",
    body: JSON.stringify(data)
  }),
  // 用户登出
  logout: () => request("/auth/logout/", {
    method: "POST"
  })
};
const emotionAPI = {
  // 创建情绪记录
  createRecord: (data) => request("/emotions/records/", {
    method: "POST",
    body: JSON.stringify(data)
  }),
  // 获取情绪记录列表
  getRecords: (params) => {
    const queryString = params ? new URLSearchParams(params).toString() : "";
    return request(`/emotions/records/${queryString ? "?" + queryString : ""}`, {
      method: "GET"
    });
  },
  // 获取今日记录
  getTodayRecords: () => request("/emotions/records/today/", {
    method: "GET"
  }),
  // 获取最近记录
  getRecentRecords: () => request("/emotions/records/recent/", {
    method: "GET"
  }),
  // 获取情绪记录详情
  getRecord: (id) => request(`/emotions/records/${id}/`, {
    method: "GET"
  }),
  // 更新情绪记录
  updateRecord: (id, data) => request(`/emotions/records/${id}/`, {
    method: "PUT",
    body: JSON.stringify(data)
  }),
  // 删除情绪记录
  deleteRecord: (id) => request(`/emotions/records/${id}/`, {
    method: "DELETE"
  })
};
const aiAPI = {
  // 获取AI分析
  getAnalysis: (recordId) => request(`/ai/analysis/${recordId}/`, {
    method: "GET"
  }),
  // 获取AI分析历史
  getAnalysisHistory: (params) => {
    const queryString = params ? new URLSearchParams(params).toString() : "";
    return request(`/ai/analysis/history/${queryString ? "?" + queryString : ""}`, {
      method: "GET"
    });
  },
  // 实时AI分析
  realtimeAnalysis: (data) => request("/ai/analysis/realtime/", {
    method: "POST",
    body: JSON.stringify(data)
  })
};
exports.aiAPI = aiAPI;
exports.authAPI = authAPI;
exports.emotionAPI = emotionAPI;
exports.getToken = getToken;
exports.getUser = getUser;
exports.setToken = setToken;
exports.setUser = setUser;
