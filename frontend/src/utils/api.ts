// API配置
const API_BASE_URL = 'http://127.0.0.1:8000/api/v1'

// 请求拦截器
const request = async (url: string, options: any = {}) => {
  const token = getToken()
  
  const defaultOptions = {
    headers: {
      'Content-Type': 'application/json',
      ...(token && { 'Authorization': `Token ${token}` })
    }
  }
  
  const finalOptions = {
    ...defaultOptions,
    ...options,
    headers: {
      ...defaultOptions.headers,
      ...options.headers
    }
  }
  
  try {
    const response = await fetch(`${API_BASE_URL}${url}`, finalOptions)
    
    if (!response.ok) {
      if (response.status === 401) {
        // Token过期，清除本地存储
        removeToken()
        removeUser()
        uni.reLaunch({
          url: '/pages/login/login'
        })
        throw new Error('登录已过期，请重新登录')
      }
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    return await response.json()
  } catch (error) {
    console.error('API请求失败:', error)
    throw error
  }
}

// Token管理
export const getToken = (): string | null => {
  return uni.getStorageSync('token') || null
}

export const setToken = (token: string) => {
  uni.setStorageSync('token', token)
}

export const removeToken = () => {
  uni.removeStorageSync('token')
}

// 用户信息管理
export const getUser = (): any | null => {
  const userStr = uni.getStorageSync('user')
  return userStr ? JSON.parse(userStr) : null
}

export const setUser = (user: any) => {
  uni.setStorageSync('user', JSON.stringify(user))
}

export const removeUser = () => {
  uni.removeStorageSync('user')
}

// 认证API
export const authAPI = {
  // 传统密码登录 (兼容)
  login: (data: any) => request('/auth/login/', {
    method: 'POST',
    body: JSON.stringify(data)
  }),
  
  // 传统密码注册 (兼容)
  register: (data: any) => request('/auth/register/', {
    method: 'POST',
    body: JSON.stringify(data)
  }),
  
  // 发送短信验证码
  sendSMS: (data: { phone: string; purpose: string }) => request('/auth/sms/send/', {
    method: 'POST',
    body: JSON.stringify(data)
  }),
  
  // 手机验证码登录
  phoneLogin: (data: { phone: string; code: string; nickname?: string }) => request('/auth/phone/login/', {
    method: 'POST',
    body: JSON.stringify(data)
  }),
  
  // 手机号注册
  phoneRegister: (data: { phone: string; code: string; nickname?: string }) => request('/auth/phone/register/', {
    method: 'POST',
    body: JSON.stringify(data)
  }),
  
  // 微信登录
  wechatLogin: (data: { code: string; nickname?: string; avatar_url?: string; gender?: string }) => request('/auth/wechat/login/', {
    method: 'POST',
    body: JSON.stringify(data)
  }),
  
  // 获取用户信息
  getUserInfo: () => request('/auth/profile/', {
    method: 'GET'
  }),
  
  // 更新用户信息
  updateUserInfo: (data: any) => request('/auth/profile/', {
    method: 'PUT',
    body: JSON.stringify(data)
  }),
  
  // 更新个人资料（别名）
  updateProfile: (data: any) => request('/auth/profile/', {
    method: 'PATCH',
    body: JSON.stringify(data)
  }),
  
  // 用户登出
  logout: () => request('/auth/logout/', {
    method: 'POST'
  })
}

// 情绪记录API
export const emotionAPI = {
  // 创建情绪记录
  createRecord: (data: any) => request('/emotions/records/', {
    method: 'POST',
    body: JSON.stringify(data)
  }),
  
  // 获取情绪记录列表
  getRecords: (params?: any) => {
    const queryString = params ? new URLSearchParams(params).toString() : ''
    return request(`/emotions/records/${queryString ? '?' + queryString : ''}`, {
      method: 'GET'
    })
  },
  
  // 获取今日记录
  getTodayRecords: () => request('/emotions/records/today/', {
    method: 'GET'
  }),
  
  // 获取最近记录
  getRecentRecords: () => request('/emotions/records/recent/', {
    method: 'GET'
  }),
  
  // 获取情绪记录详情
  getRecord: (id: number) => request(`/emotions/records/${id}/`, {
    method: 'GET'
  }),
  
  // 更新情绪记录
  updateRecord: (id: number, data: any) => request(`/emotions/records/${id}/`, {
    method: 'PUT',
    body: JSON.stringify(data)
  }),
  
  // 删除情绪记录
  deleteRecord: (id: number) => request(`/emotions/records/${id}/`, {
    method: 'DELETE'
  })
}

// 统计分析API
export const statsAPI = {
  // 获取情绪统计
  getEmotionStats: (params?: any) => {
    const queryString = params ? new URLSearchParams(params).toString() : ''
    return request(`/emotions/statistics/emotion-distribution/${queryString ? '?' + queryString : ''}`, {
      method: 'GET'
    })
  },
  
  // 获取场景统计
  getScenarioStats: (params?: any) => {
    const queryString = params ? new URLSearchParams(params).toString() : ''
    return request(`/emotions/statistics/scenario-distribution/${queryString ? '?' + queryString : ''}`, {
      method: 'GET'
    })
  },
  
  // 获取趋势分析
  getTrendAnalysis: (params?: any) => {
    const queryString = params ? new URLSearchParams(params).toString() : ''
    return request(`/emotions/statistics/trend-analysis/${queryString ? '?' + queryString : ''}`, {
      method: 'GET'
    })
  }
}

// AI分析API
export const aiAPI = {
  // 获取AI分析
  getAnalysis: (recordId: number) => request(`/ai/analysis/${recordId}/`, {
    method: 'GET'
  }),
  
  // 获取AI分析历史
  getAnalysisHistory: (params?: any) => {
    const queryString = params ? new URLSearchParams(params).toString() : ''
    return request(`/ai/analysis/history/${queryString ? '?' + queryString : ''}`, {
      method: 'GET'
    })
  },
  
  // 实时AI分析
  realtimeAnalysis: (data: any) => request('/ai/analysis/realtime/', {
    method: 'POST',
    body: JSON.stringify(data)
  })
}

// 统计数据API
export const statisticsAPI = {
  // 获取统计概览
  getOverview: (timeRange: string = 'week') => {
    return request(`/emotions/statistics/overview/?time_range=${timeRange}`, {
      method: 'GET'
    })
  },
  
  // 获取情绪趋势
  getTrend: (timeRange: string = 'week') => {
    return request(`/emotions/statistics/trend/?time_range=${timeRange}`, {
      method: 'GET'
    })
  },
  
  // 获取情绪分布
  getDistribution: (timeRange: string = 'week') => {
    return request(`/emotions/statistics/distribution/?time_range=${timeRange}`, {
      method: 'GET'
    })
  },
  
  // 获取场景统计
  getSceneStats: (timeRange: string = 'week') => {
    return request(`/emotions/statistics/scenes/?time_range=${timeRange}`, {
      method: 'GET'
    })
  },
  
  // 获取时间模式
  getTimePattern: (timeRange: string = 'week') => {
    return request(`/emotions/statistics/time-pattern/?time_range=${timeRange}`, {
      method: 'GET'
    })
  }
}

// 导出默认配置
export default {
  emotionAPI,
  authAPI,
  aiAPI,
  statisticsAPI,
  getToken,
  setToken,
  removeToken,
  getUser,
  setUser,
  removeUser
} 