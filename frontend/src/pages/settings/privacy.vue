<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header">
      <text class="page-title">隐私设置</text>
      <text class="page-subtitle">保护您的个人数据安全</text>
    </view>

    <!-- 数据保护级别 -->
    <view class="protection-level-card">
      <view class="level-header">
        <text class="level-title">当前保护级别</text>
        <view class="level-badge" :class="protectionLevel.toLowerCase()">
          <text class="badge-text">{{ protectionLevel }}</text>
        </view>
      </view>
      <text class="level-desc">{{ getLevelDescription() }}</text>
      
      <view class="level-options">
        <view 
          class="level-option"
          v-for="level in protectionLevels"
          :key="level.name"
          :class="{ selected: protectionLevel === level.name }"
          @click="selectProtectionLevel(level.name)"
        >
          <view class="option-icon">{{ level.icon }}</view>
          <view class="option-info">
            <text class="option-name">{{ level.name }}</text>
            <text class="option-desc">{{ level.description }}</text>
          </view>
          <view class="option-indicator">
            <text class="indicator" v-if="protectionLevel === level.name">✓</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 数据加密设置 -->
    <view class="settings-section">
      <text class="section-title">数据加密</text>
      
      <view class="setting-card">
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">本地数据加密</text>
            <text class="setting-desc">使用AES-256加密存储本地数据</text>
          </view>
          <switch 
            :checked="privacySettings.localEncryption" 
            @change="toggleLocalEncryption"
            color="var(--primary-color)"
          />
        </view>
        
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">传输加密</text>
            <text class="setting-desc">所有网络传输使用HTTPS加密</text>
          </view>
          <view class="setting-status enabled">
            <text class="status-text">已启用</text>
          </view>
        </view>
        
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">端到端加密</text>
            <text class="setting-desc">云端备份数据端到端加密</text>
          </view>
          <switch 
            :checked="privacySettings.e2eEncryption" 
            @change="toggleE2EEncryption"
            color="var(--primary-color)"
          />
        </view>
      </view>
    </view>

    <!-- 匿名化设置 -->
    <view class="settings-section">
      <text class="section-title">匿名化保护</text>
      
      <view class="setting-card">
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">匿名分析模式</text>
            <text class="setting-desc">AI分析时移除个人标识信息</text>
          </view>
          <switch 
            :checked="privacySettings.anonymousAnalysis" 
            @change="toggleAnonymousAnalysis"
            color="var(--primary-color)"
          />
        </view>
        
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">数据脱敏</text>
            <text class="setting-desc">自动识别并脱敏敏感信息</text>
          </view>
          <switch 
            :checked="privacySettings.dataMasking" 
            @change="toggleDataMasking"
            color="var(--primary-color)"
          />
        </view>
        
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">位置信息保护</text>
            <text class="setting-desc">不记录具体位置，仅保留城市级别</text>
          </view>
          <switch 
            :checked="privacySettings.locationProtection" 
            @change="toggleLocationProtection"
            color="var(--primary-color)"
          />
        </view>
      </view>
    </view>

    <!-- 数据访问控制 -->
    <view class="settings-section">
      <text class="section-title">访问控制</text>
      
      <view class="setting-card">
        <view class="setting-item" @click="setAppLock">
          <view class="setting-info">
            <text class="setting-title">应用锁定</text>
            <text class="setting-desc">{{ appLockStatus }}</text>
          </view>
          <text class="setting-arrow">></text>
        </view>
        
        <view class="setting-item" @click="setBiometricAuth">
          <view class="setting-info">
            <text class="setting-title">生物识别验证</text>
            <text class="setting-desc">使用指纹或面部识别解锁</text>
          </view>
          <switch 
            :checked="privacySettings.biometricAuth" 
            @change="toggleBiometricAuth"
            color="var(--primary-color)"
          />
        </view>
        
        <view class="setting-item" @click="setAutoLockTime">
          <view class="setting-info">
            <text class="setting-title">自动锁定时间</text>
            <text class="setting-desc">{{ autoLockTimeText }}</text>
          </view>
          <text class="setting-arrow">></text>
        </view>
      </view>
    </view>

    <!-- 数据共享设置 -->
    <view class="settings-section">
      <text class="section-title">数据共享</text>
      
      <view class="setting-card">
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">匿名使用统计</text>
            <text class="setting-desc">帮助改善应用体验，不包含个人信息</text>
          </view>
          <switch 
            :checked="privacySettings.anonymousStats" 
            @change="toggleAnonymousStats"
            color="var(--primary-color)"
          />
        </view>
        
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">崩溃报告</text>
            <text class="setting-desc">自动发送崩溃日志以修复问题</text>
          </view>
          <switch 
            :checked="privacySettings.crashReports" 
            @change="toggleCrashReports"
            color="var(--primary-color)"
          />
        </view>
        
        <view class="setting-item">
          <view class="setting-info">
            <text class="setting-title">第三方分析</text>
            <text class="setting-desc">允许第三方分析服务收集匿名数据</text>
          </view>
          <switch 
            :checked="privacySettings.thirdPartyAnalytics" 
            @change="toggleThirdPartyAnalytics"
            color="var(--primary-color)"
          />
        </view>
      </view>
    </view>

    <!-- 数据管理 -->
    <view class="settings-section">
      <text class="section-title">数据管理</text>
      
      <view class="setting-card">
        <view class="setting-item" @click="viewDataUsage">
          <view class="setting-info">
            <text class="setting-title">数据使用情况</text>
            <text class="setting-desc">查看应用数据使用详情</text>
          </view>
          <text class="setting-arrow">></text>
        </view>
        
        <view class="setting-item" @click="exportPersonalData">
          <view class="setting-info">
            <text class="setting-title">导出个人数据</text>
            <text class="setting-desc">下载您的所有个人数据</text>
          </view>
          <text class="setting-arrow">></text>
        </view>
        
        <view class="setting-item danger" @click="deleteAllData">
          <view class="setting-info">
            <text class="setting-title danger-text">删除所有数据</text>
            <text class="setting-desc">永久删除所有个人数据，不可恢复</text>
          </view>
          <text class="setting-arrow danger-text">></text>
        </view>
      </view>
    </view>

    <!-- 隐私政策 -->
    <view class="policy-section">
      <view class="policy-links">
        <text class="policy-link" @click="viewPrivacyPolicy">隐私政策</text>
        <text class="policy-separator">|</text>
        <text class="policy-link" @click="viewTermsOfService">服务条款</text>
        <text class="policy-separator">|</text>
        <text class="policy-link" @click="viewDataPolicy">数据处理政策</text>
      </view>
      <text class="policy-update">最后更新：2024年6月22日</text>
    </view>

    <!-- 保存按钮 -->
    <view class="save-section">
      <button class="save-button" @click="saveSettings">
        保存设置
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'

// 类型定义
interface PrivacySettings {
  localEncryption: boolean
  e2eEncryption: boolean
  anonymousAnalysis: boolean
  dataMasking: boolean
  locationProtection: boolean
  biometricAuth: boolean
  anonymousStats: boolean
  crashReports: boolean
  thirdPartyAnalytics: boolean
}

interface ProtectionLevel {
  name: string
  icon: string
  description: string
}

// 响应式数据
const protectionLevel = ref('标准')
const autoLockTime = ref(5) // 分钟

const privacySettings = reactive<PrivacySettings>({
  localEncryption: true,
  e2eEncryption: false,
  anonymousAnalysis: true,
  dataMasking: true,
  locationProtection: true,
  biometricAuth: false,
  anonymousStats: true,
  crashReports: true,
  thirdPartyAnalytics: false
})

const protectionLevels: ProtectionLevel[] = [
  {
    name: '基础',
    icon: '🛡️',
    description: '基本的隐私保护，适合一般用户'
  },
  {
    name: '标准',
    icon: '🔒',
    description: '平衡隐私保护与功能体验'
  },
  {
    name: '高级',
    icon: '🔐',
    description: '最高级别的隐私保护，可能影响部分功能'
  }
]

// 计算属性
const appLockStatus = computed(() => {
  if (privacySettings.biometricAuth) {
    return '已启用生物识别'
  }
  return '未启用'
})

const autoLockTimeText = computed(() => {
  if (autoLockTime.value === 0) {
    return '立即锁定'
  } else if (autoLockTime.value === 60) {
    return '1小时后'
  } else {
    return `${autoLockTime.value}分钟后`
  }
})

// 方法
const getLevelDescription = () => {
  const level = protectionLevels.find(l => l.name === protectionLevel.value)
  return level ? level.description : ''
}

const selectProtectionLevel = (level: string) => {
  protectionLevel.value = level
  
  // 根据保护级别自动调整设置
  if (level === '基础') {
    privacySettings.localEncryption = false
    privacySettings.e2eEncryption = false
    privacySettings.anonymousAnalysis = false
    privacySettings.dataMasking = false
  } else if (level === '标准') {
    privacySettings.localEncryption = true
    privacySettings.e2eEncryption = false
    privacySettings.anonymousAnalysis = true
    privacySettings.dataMasking = true
  } else if (level === '高级') {
    privacySettings.localEncryption = true
    privacySettings.e2eEncryption = true
    privacySettings.anonymousAnalysis = true
    privacySettings.dataMasking = true
    privacySettings.locationProtection = true
  }
  
  uni.showToast({
    title: `已切换到${level}保护`,
    icon: 'success'
  })
}

const toggleLocalEncryption = (e: any) => {
  privacySettings.localEncryption = e.detail.value
  const message = privacySettings.localEncryption ? '已启用本地加密' : '已关闭本地加密'
  uni.showToast({
    title: message,
    icon: 'success'
  })
}

const toggleE2EEncryption = (e: any) => {
  privacySettings.e2eEncryption = e.detail.value
  if (privacySettings.e2eEncryption) {
    uni.showModal({
      title: '端到端加密',
      content: '启用后，即使是我们也无法访问您的数据。请妥善保管您的密码，忘记后无法恢复。',
      success: (res) => {
        if (!res.confirm) {
          privacySettings.e2eEncryption = false
        }
      }
    })
  }
}

const toggleAnonymousAnalysis = (e: any) => {
  privacySettings.anonymousAnalysis = e.detail.value
}

const toggleDataMasking = (e: any) => {
  privacySettings.dataMasking = e.detail.value
}

const toggleLocationProtection = (e: any) => {
  privacySettings.locationProtection = e.detail.value
}

const toggleBiometricAuth = (e: any) => {
  privacySettings.biometricAuth = e.detail.value
  if (privacySettings.biometricAuth) {
    // 模拟生物识别验证
    uni.showModal({
      title: '生物识别验证',
      content: '请使用指纹或面部识别进行验证',
      success: (res) => {
        if (res.confirm) {
          uni.showToast({
            title: '验证成功',
            icon: 'success'
          })
        } else {
          privacySettings.biometricAuth = false
        }
      }
    })
  }
}

const toggleAnonymousStats = (e: any) => {
  privacySettings.anonymousStats = e.detail.value
}

const toggleCrashReports = (e: any) => {
  privacySettings.crashReports = e.detail.value
}

const toggleThirdPartyAnalytics = (e: any) => {
  privacySettings.thirdPartyAnalytics = e.detail.value
}

const setAppLock = () => {
  uni.showActionSheet({
    itemList: ['设置密码锁', '设置图案锁', '关闭应用锁'],
    success: (res) => {
      const options = ['密码锁', '图案锁', '关闭']
      uni.showToast({
        title: `已设置${options[res.tapIndex]}`,
        icon: 'success'
      })
    }
  })
}

const setBiometricAuth = () => {
  uni.showModal({
    title: '生物识别设置',
    content: '是否启用指纹或面部识别？',
    success: (res) => {
      if (res.confirm) {
        privacySettings.biometricAuth = true
      }
    }
  })
}

const setAutoLockTime = () => {
  uni.showActionSheet({
    itemList: ['立即锁定', '1分钟后', '5分钟后', '15分钟后', '30分钟后', '1小时后'],
    success: (res) => {
      const times = [0, 1, 5, 15, 30, 60]
      autoLockTime.value = times[res.tapIndex]
      uni.showToast({
        title: '设置成功',
        icon: 'success'
      })
    }
  })
}

const viewDataUsage = () => {
  uni.showModal({
    title: '数据使用情况',
    content: '本地数据：2.3MB\n云端备份：1.8MB\n缓存数据：0.5MB',
    showCancel: false
  })
}

const exportPersonalData = () => {
  uni.showLoading({
    title: '导出中...'
  })
  
  setTimeout(() => {
    uni.hideLoading()
    uni.showToast({
      title: '导出完成',
      icon: 'success'
    })
  }, 2000)
}

const deleteAllData = () => {
  uni.showModal({
    title: '危险操作',
    content: '此操作将永久删除所有数据，无法恢复。请输入"DELETE"确认删除。',
    editable: true,
    success: (res) => {
      if (res.confirm && res.content === 'DELETE') {
        uni.showLoading({
          title: '删除中...'
        })
        
        setTimeout(() => {
          uni.hideLoading()
          uni.showToast({
            title: '数据已删除',
            icon: 'success'
          })
        }, 2000)
      } else if (res.confirm) {
        uni.showToast({
          title: '输入错误，删除取消',
          icon: 'none'
        })
      }
    }
  })
}

const viewPrivacyPolicy = () => {
  uni.navigateTo({
    url: '/pages/legal/privacy-policy'
  })
}

const viewTermsOfService = () => {
  uni.navigateTo({
    url: '/pages/legal/terms-of-service'
  })
}

const viewDataPolicy = () => {
  uni.navigateTo({
    url: '/pages/legal/data-policy'
  })
}

const saveSettings = () => {
  uni.showLoading({
    title: '保存中...'
  })
  
  setTimeout(() => {
    uni.hideLoading()
    uni.showToast({
      title: '设置已保存',
      icon: 'success'
    })
    
    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  }, 1000)
}
</script>

<style scoped>
/* 页面特定变量 */
:root {
  --primary-color: #4A90E2;
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.3);
  --text-primary: #2c3e50;
  --text-secondary: #7f8c8d;
  --success-color: #27ae60;
  --warning-color: #f39c12;
  --danger-color: #e74c3c;
}

.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 0 30rpx 120rpx;
}

/* 页面头部 */
.page-header {
  padding: 40rpx 0 30rpx;
  text-align: center;
}

.page-title {
  display: block;
  font-size: 42rpx;
  font-weight: 800;
  background: linear-gradient(45deg, var(--primary-color), #667eea);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 16rpx;
}

.page-subtitle {
  display: block;
  font-size: 28rpx;
  color: var(--text-secondary);
  opacity: 0.8;
}

/* 保护级别卡片 */
.protection-level-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 40rpx;
  margin-bottom: 40rpx;
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.1);
}

.level-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}

.level-title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-primary);
}

.level-badge {
  padding: 8rpx 20rpx;
  border-radius: 20rpx;
  font-size: 24rpx;
  font-weight: 600;
}

.level-badge.基础 {
  background: rgba(241, 196, 15, 0.2);
  color: #f1c40f;
}

.level-badge.标准 {
  background: rgba(52, 152, 219, 0.2);
  color: #3498db;
}

.level-badge.高级 {
  background: rgba(231, 76, 60, 0.2);
  color: #e74c3c;
}

.badge-text {
  font-size: 24rpx;
}

.level-desc {
  display: block;
  font-size: 26rpx;
  color: var(--text-secondary);
  line-height: 1.4;
  margin-bottom: 32rpx;
}

.level-options {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.level-option {
  display: flex;
  align-items: center;
  padding: 24rpx;
  background: rgba(255, 255, 255, 0.3);
  border: 2rpx solid transparent;
  border-radius: 16rpx;
  transition: all 0.3s ease;
}

.level-option.selected {
  background: rgba(74, 144, 226, 0.1);
  border-color: var(--primary-color);
}

.option-icon {
  font-size: 32rpx;
  margin-right: 20rpx;
}

.option-info {
  flex: 1;
}

.option-name {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.option-desc {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

.option-indicator {
  width: 40rpx;
  text-align: center;
}

.indicator {
  color: var(--success-color);
  font-size: 28rpx;
  font-weight: bold;
}

/* 设置区域 */
.settings-section {
  margin-bottom: 40rpx;
}

.section-title {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 24rpx;
  padding-left: 16rpx;
}

.setting-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  overflow: hidden;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32rpx;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-item.danger {
  background: rgba(231, 76, 60, 0.05);
}

.setting-info {
  flex: 1;
}

.setting-title {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.setting-title.danger-text {
  color: var(--danger-color);
}

.setting-desc {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

.setting-status {
  padding: 8rpx 16rpx;
  border-radius: 12rpx;
  font-size: 22rpx;
}

.setting-status.enabled {
  background: rgba(39, 174, 96, 0.2);
  color: var(--success-color);
}

.status-text {
  font-weight: 600;
}

.setting-arrow {
  font-size: 24rpx;
  color: var(--text-secondary);
}

.setting-arrow.danger-text {
  color: var(--danger-color);
}

/* 隐私政策区域 */
.policy-section {
  margin-top: 40rpx;
  padding: 32rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  text-align: center;
}

.policy-links {
  margin-bottom: 16rpx;
}

.policy-link {
  font-size: 26rpx;
  color: var(--primary-color);
  text-decoration: underline;
}

.policy-separator {
  margin: 0 16rpx;
  font-size: 26rpx;
  color: var(--text-secondary);
}

.policy-update {
  font-size: 22rpx;
  color: var(--text-secondary);
}

/* 保存按钮 */
.save-section {
  margin-top: 40rpx;
}

.save-button {
  width: 100%;
  height: 88rpx;
  background: linear-gradient(45deg, var(--primary-color), #667eea);
  color: white;
  border: none;
  border-radius: 25rpx;
  font-size: 30rpx;
  font-weight: 600;
  box-shadow: 0 8rpx 32rpx rgba(74, 144, 226, 0.3);
  transition: all 0.3s ease;
}

.save-button:active {
  transform: scale(0.98);
}
</style> 