<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header">
      <text class="page-title">意见反馈</text>
      <text class="page-subtitle">您的建议是我们前进的动力</text>
    </view>

    <!-- 反馈类型选择 -->
    <view class="feedback-type-section">
      <text class="section-title">反馈类型</text>
      
      <view class="type-options">
        <view 
          class="type-option"
          v-for="type in feedbackTypes"
          :key="type.key"
          :class="{ selected: selectedType === type.key }"
          @click="selectType(type.key)"
        >
          <text class="type-icon">{{ type.icon }}</text>
          <view class="type-info">
            <text class="type-name">{{ type.name }}</text>
            <text class="type-desc">{{ type.description }}</text>
          </view>
          <view class="type-indicator">
            <text class="indicator" v-if="selectedType === type.key">✓</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 问题描述 -->
    <view class="description-section">
      <text class="section-title">问题描述</text>
      
      <view class="description-card">
        <textarea 
          v-model="feedbackForm.description"
          placeholder="请详细描述您遇到的问题或建议..."
          class="description-input"
          maxlength="500"
          auto-height
        />
        <text class="char-count">{{ feedbackForm.description.length }}/500</text>
        
        <!-- 快速模板 -->
        <view class="quick-templates" v-if="quickTemplates.length > 0">
          <text class="template-title">快速模板</text>
          <view class="template-list">
            <text 
              class="template-item"
              v-for="template in quickTemplates"
              :key="template"
              @click="useTemplate(template)"
            >
              {{ template }}
            </text>
          </view>
        </view>
      </view>
    </view>

    <!-- 重现步骤 -->
    <view class="steps-section" v-if="selectedType === 'bug'">
      <text class="section-title">重现步骤</text>
      
      <view class="steps-card">
        <view 
          class="step-item"
          v-for="(step, index) in feedbackForm.steps"
          :key="index"
        >
          <view class="step-number">{{ index + 1 }}</view>
          <input 
            v-model="feedbackForm.steps[index]"
            placeholder="描述操作步骤..."
            class="step-input"
          />
          <view class="step-delete" @click="removeStep(index)">×</view>
        </view>
        
        <button class="add-step-btn" @click="addStep">
          <text class="add-icon">+</text>
          <text class="add-text">添加步骤</text>
        </button>
      </view>
    </view>

    <!-- 优先级选择 -->
    <view class="priority-section">
      <text class="section-title">优先级</text>
      
      <view class="priority-options">
        <view 
          class="priority-option"
          v-for="priority in priorities"
          :key="priority.key"
          :class="{ 
            selected: selectedPriority === priority.key,
            [priority.key]: true
          }"
          @click="selectPriority(priority.key)"
        >
          <text class="priority-icon">{{ priority.icon }}</text>
          <text class="priority-name">{{ priority.name }}</text>
        </view>
      </view>
    </view>

    <!-- 附件上传 -->
    <view class="attachment-section">
      <text class="section-title">附件 (可选)</text>
      
      <view class="attachment-card">
        <view class="attachment-grid">
          <view 
            class="attachment-item"
            v-for="(attachment, index) in feedbackForm.attachments"
            :key="index"
          >
            <image 
              v-if="attachment.type === 'image'"
              :src="attachment.url" 
              class="attachment-preview"
              mode="aspectFill"
            />
            <view v-else class="attachment-file">
              <text class="file-icon">📄</text>
              <text class="file-name">{{ attachment.name }}</text>
            </view>
            <view class="attachment-delete" @click="removeAttachment(index)">×</view>
          </view>
          
          <view class="add-attachment" @click="addAttachment">
            <text class="add-icon">+</text>
            <text class="add-text">添加附件</text>
          </view>
        </view>
        
        <text class="attachment-tip">支持图片、日志文件，最大5MB</text>
      </view>
    </view>

    <!-- 联系方式 -->
    <view class="contact-section">
      <text class="section-title">联系方式 (可选)</text>
      
      <view class="contact-card">
        <view class="contact-item">
          <text class="contact-label">邮箱</text>
          <input 
            v-model="feedbackForm.email"
            placeholder="您的邮箱地址"
            class="contact-input"
            type="email"
          />
        </view>
        
        <view class="contact-item">
          <text class="contact-label">手机</text>
          <input 
            v-model="feedbackForm.phone"
            placeholder="您的手机号码"
            class="contact-input"
            type="number"
          />
        </view>
        
        <view class="contact-note">
          <text class="note-text">留下联系方式，我们会及时回复您的反馈</text>
        </view>
      </view>
    </view>

    <!-- 系统信息 -->
    <view class="system-info-section">
      <view class="info-header" @click="toggleSystemInfo">
        <text class="section-title">系统信息</text>
        <text class="toggle-icon" :class="{ expanded: showSystemInfo }">▼</text>
      </view>
      
      <view class="system-info-card" v-if="showSystemInfo">
        <view class="info-item">
          <text class="info-label">应用版本</text>
          <text class="info-value">{{ systemInfo.appVersion }}</text>
        </view>
        
        <view class="info-item">
          <text class="info-label">系统版本</text>
          <text class="info-value">{{ systemInfo.systemVersion }}</text>
        </view>
        
        <view class="info-item">
          <text class="info-label">设备型号</text>
          <text class="info-value">{{ systemInfo.deviceModel }}</text>
        </view>
        
        <view class="info-item">
          <text class="info-label">用户ID</text>
          <text class="info-value">{{ systemInfo.userId }}</text>
        </view>
      </view>
    </view>

    <!-- 历史反馈 -->
    <view class="history-section">
      <view class="history-header">
        <text class="section-title">历史反馈</text>
        <text class="view-all" @click="viewAllHistory">查看全部</text>
      </view>
      
      <view class="history-list">
        <view 
          class="history-item"
          v-for="item in recentFeedbacks"
          :key="item.id"
          @click="viewFeedbackDetail(item)"
        >
          <view class="history-icon">{{ getTypeIcon(item.type) }}</view>
          <view class="history-info">
            <text class="history-title">{{ item.title }}</text>
            <text class="history-time">{{ formatTime(item.createdAt) }}</text>
          </view>
          <view class="history-status" :class="item.status">
            <text class="status-text">{{ getStatusText(item.status) }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 提交按钮 -->
    <view class="submit-section">
      <button 
        class="submit-button"
        :class="{ disabled: !canSubmit }"
        @click="submitFeedback"
        :disabled="!canSubmit"
      >
        提交反馈
      </button>
      
      <view class="submit-tips">
        <text class="tips-text">提交前请确保信息准确完整</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'

// 类型定义
interface FeedbackForm {
  description: string
  steps: string[]
  attachments: Array<{
    name: string
    url: string
    type: 'image' | 'file'
  }>
  email: string
  phone: string
}

interface FeedbackType {
  key: string
  name: string
  description: string
  icon: string
}

interface Priority {
  key: string
  name: string
  icon: string
}

interface HistoryItem {
  id: number
  type: string
  title: string
  status: 'pending' | 'processing' | 'resolved' | 'closed'
  createdAt: string
}

// 响应式数据
const selectedType = ref('bug')
const selectedPriority = ref('medium')
const showSystemInfo = ref(false)

const feedbackForm = reactive<FeedbackForm>({
  description: '',
  steps: [''],
  attachments: [],
  email: '',
  phone: ''
})

const feedbackTypes: FeedbackType[] = [
  {
    key: 'bug',
    name: '问题反馈',
    description: '应用出现错误或异常',
    icon: '🐛'
  },
  {
    key: 'feature',
    name: '功能建议',
    description: '希望添加新功能',
    icon: '💡'
  },
  {
    key: 'improvement',
    name: '改进建议',
    description: '现有功能的改进意见',
    icon: '⚡'
  },
  {
    key: 'ui',
    name: '界面问题',
    description: '界面显示或交互问题',
    icon: '🎨'
  },
  {
    key: 'performance',
    name: '性能问题',
    description: '应用运行缓慢或卡顿',
    icon: '🚀'
  },
  {
    key: 'other',
    name: '其他',
    description: '其他类型的反馈',
    icon: '📝'
  }
]

const priorities: Priority[] = [
  { key: 'low', name: '低', icon: '🟢' },
  { key: 'medium', name: '中', icon: '🟡' },
  { key: 'high', name: '高', icon: '🟠' },
  { key: 'urgent', name: '紧急', icon: '🔴' }
]

const systemInfo = ref({
  appVersion: 'v1.0.0',
  systemVersion: 'iOS 17.5',
  deviceModel: 'iPhone 15 Pro',
  userId: 'user_123456'
})

const recentFeedbacks = ref<HistoryItem[]>([
  {
    id: 1,
    type: 'bug',
    title: '登录页面无法正常显示',
    status: 'resolved',
    createdAt: '2024-06-20T10:30:00Z'
  },
  {
    id: 2,
    type: 'feature',
    title: '希望添加夜间模式',
    status: 'processing',
    createdAt: '2024-06-18T14:20:00Z'
  },
  {
    id: 3,
    type: 'improvement',
    title: '情绪记录页面加载优化',
    status: 'pending',
    createdAt: '2024-06-15T09:15:00Z'
  }
])

// 计算属性
const quickTemplates = computed(() => {
  const templates: Record<string, string[]> = {
    bug: [
      '应用崩溃',
      '功能无法使用',
      '数据显示错误',
      '页面加载失败'
    ],
    feature: [
      '希望添加...',
      '建议增加...',
      '期望支持...'
    ],
    improvement: [
      '建议优化...',
      '希望改进...',
      '可以更好...'
    ],
    ui: [
      '界面显示异常',
      '按钮无法点击',
      '文字显示不全',
      '颜色搭配问题'
    ],
    performance: [
      '启动速度慢',
      '页面卡顿',
      '内存占用高',
      '电池消耗快'
    ]
  }
  
  return templates[selectedType.value] || []
})

const canSubmit = computed(() => {
  return feedbackForm.description.trim().length >= 10
})

// 方法
const selectType = (type: string) => {
  selectedType.value = type
}

const selectPriority = (priority: string) => {
  selectedPriority.value = priority
}

const useTemplate = (template: string) => {
  feedbackForm.description = template
}

const addStep = () => {
  feedbackForm.steps.push('')
}

const removeStep = (index: number) => {
  if (feedbackForm.steps.length > 1) {
    feedbackForm.steps.splice(index, 1)
  }
}

const addAttachment = () => {
  uni.chooseImage({
    count: 3,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      res.tempFilePaths.forEach(path => {
        feedbackForm.attachments.push({
          name: `image_${Date.now()}.jpg`,
          url: path,
          type: 'image'
        })
      })
    }
  })
}

const removeAttachment = (index: number) => {
  feedbackForm.attachments.splice(index, 1)
}

const toggleSystemInfo = () => {
  showSystemInfo.value = !showSystemInfo.value
}

const getTypeIcon = (type: string) => {
  const typeObj = feedbackTypes.find(t => t.key === type)
  return typeObj ? typeObj.icon : '📝'
}

const getStatusText = (status: string) => {
  const statusMap = {
    pending: '待处理',
    processing: '处理中',
    resolved: '已解决',
    closed: '已关闭'
  }
  return statusMap[status as keyof typeof statusMap] || '未知'
}

const formatTime = (timeStr: string) => {
  const date = new Date(timeStr)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  
  if (days === 0) {
    return '今天'
  } else if (days === 1) {
    return '昨天'
  } else if (days < 7) {
    return `${days}天前`
  } else {
    return date.toLocaleDateString('zh-CN')
  }
}

const viewFeedbackDetail = (item: HistoryItem) => {
  uni.showModal({
    title: item.title,
    content: `状态：${getStatusText(item.status)}\n提交时间：${formatTime(item.createdAt)}`,
    showCancel: false
  })
}

const viewAllHistory = () => {
  uni.navigateTo({
    url: '/pages/help/feedback-history'
  })
}

const submitFeedback = () => {
  if (!canSubmit.value) {
    uni.showToast({
      title: '请完善反馈内容',
      icon: 'none'
    })
    return
  }
  
  uni.showLoading({
    title: '提交中...'
  })
  
  // 模拟提交过程
  setTimeout(() => {
    uni.hideLoading()
    
    uni.showModal({
      title: '提交成功',
      content: '感谢您的反馈！我们会尽快处理您的问题。',
      showCancel: false,
      success: () => {
        // 重置表单
        feedbackForm.description = ''
        feedbackForm.steps = ['']
        feedbackForm.attachments = []
        feedbackForm.email = ''
        feedbackForm.phone = ''
        selectedType.value = 'bug'
        selectedPriority.value = 'medium'
        
        // 返回上一页
        setTimeout(() => {
          uni.navigateBack()
        }, 1000)
      }
    })
  }, 2000)
}

// 生命周期
onMounted(() => {
  // 获取系统信息
  uni.getSystemInfo({
    success: (res) => {
      systemInfo.value = {
        appVersion: 'v1.0.0',
        systemVersion: `${res.platform} ${res.system}`,
        deviceModel: res.model,
        userId: 'user_123456'
      }
    }
  })
})
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

/* 通用区域样式 */
.feedback-type-section,
.description-section,
.steps-section,
.priority-section,
.attachment-section,
.contact-section,
.system-info-section,
.history-section {
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

/* 反馈类型选择 */
.type-options {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.type-option {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 32rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  transition: all 0.3s ease;
}

.type-option.selected {
  background: rgba(74, 144, 226, 0.1);
  border-color: var(--primary-color);
}

.type-icon {
  font-size: 32rpx;
}

.type-info {
  flex: 1;
}

.type-name {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8rpx;
}

.type-desc {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

.type-indicator {
  width: 40rpx;
  text-align: center;
}

.indicator {
  color: var(--success-color);
  font-size: 28rpx;
  font-weight: bold;
}

/* 问题描述 */
.description-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 32rpx;
}

.description-input {
  width: 100%;
  min-height: 200rpx;
  background: transparent;
  border: none;
  font-size: 28rpx;
  color: var(--text-primary);
  line-height: 1.5;
  resize: none;
  margin-bottom: 16rpx;
}

.char-count {
  display: block;
  text-align: right;
  font-size: 22rpx;
  color: var(--text-secondary);
  margin-bottom: 24rpx;
}

.quick-templates {
  border-top: 1rpx solid rgba(255, 255, 255, 0.2);
  padding-top: 24rpx;
}

.template-title {
  display: block;
  font-size: 24rpx;
  color: var(--text-secondary);
  margin-bottom: 16rpx;
}

.template-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.template-item {
  padding: 8rpx 16rpx;
  background: rgba(74, 144, 226, 0.1);
  border: 1rpx solid rgba(74, 144, 226, 0.2);
  border-radius: 16rpx;
  font-size: 22rpx;
  color: var(--primary-color);
  transition: all 0.3s ease;
}

.template-item:active {
  background: rgba(74, 144, 226, 0.2);
}

/* 重现步骤 */
.steps-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 32rpx;
}

.step-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.step-number {
  width: 48rpx;
  height: 48rpx;
  background: var(--primary-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22rpx;
  font-weight: 600;
  flex-shrink: 0;
}

.step-input {
  flex: 1;
  height: 48rpx;
  padding: 0 16rpx;
  background: rgba(255, 255, 255, 0.3);
  border: 1rpx solid var(--glass-border);
  border-radius: 12rpx;
  font-size: 26rpx;
  color: var(--text-primary);
}

.step-delete {
  width: 48rpx;
  height: 48rpx;
  background: var(--danger-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  font-weight: 600;
  flex-shrink: 0;
}

.add-step-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  width: 100%;
  height: 64rpx;
  background: rgba(74, 144, 226, 0.1);
  border: 2rpx dashed rgba(74, 144, 226, 0.3);
  border-radius: 16rpx;
  color: var(--primary-color);
  font-size: 26rpx;
  font-weight: 600;
}

.add-icon {
  font-size: 28rpx;
}

/* 优先级选择 */
.priority-options {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16rpx;
}

.priority-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  padding: 24rpx 16rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  transition: all 0.3s ease;
}

.priority-option.selected {
  background: rgba(74, 144, 226, 0.1);
  border-color: var(--primary-color);
  transform: translateY(-4rpx);
}

.priority-option.urgent.selected {
  border-color: var(--danger-color);
}

.priority-option.high.selected {
  border-color: var(--warning-color);
}

.priority-icon {
  font-size: 32rpx;
}

.priority-name {
  font-size: 24rpx;
  color: var(--text-primary);
  font-weight: 600;
}

/* 附件上传 */
.attachment-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 32rpx;
}

.attachment-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16rpx;
  margin-bottom: 16rpx;
}

.attachment-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: 16rpx;
  overflow: hidden;
}

.attachment-preview {
  width: 100%;
  height: 100%;
}

.attachment-file {
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.3);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
}

.file-icon {
  font-size: 32rpx;
}

.file-name {
  font-size: 20rpx;
  color: var(--text-primary);
  text-align: center;
  word-break: break-all;
}

.attachment-delete {
  position: absolute;
  top: 8rpx;
  right: 8rpx;
  width: 32rpx;
  height: 32rpx;
  background: var(--danger-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18rpx;
  font-weight: 600;
}

.add-attachment {
  aspect-ratio: 1;
  background: rgba(74, 144, 226, 0.1);
  border: 2rpx dashed rgba(74, 144, 226, 0.3);
  border-radius: 16rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  color: var(--primary-color);
}

.add-text {
  font-size: 22rpx;
}

.attachment-tip {
  display: block;
  font-size: 22rpx;
  color: var(--text-secondary);
  text-align: center;
}

/* 联系方式 */
.contact-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 32rpx;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  margin-bottom: 24rpx;
}

.contact-label {
  width: 80rpx;
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 600;
}

.contact-input {
  flex: 1;
  height: 64rpx;
  padding: 0 20rpx;
  background: rgba(255, 255, 255, 0.3);
  border: 1rpx solid var(--glass-border);
  border-radius: 16rpx;
  font-size: 26rpx;
  color: var(--text-primary);
}

.contact-note {
  padding: 20rpx;
  background: rgba(74, 144, 226, 0.1);
  border-radius: 16rpx;
  border: 2rpx solid rgba(74, 144, 226, 0.2);
}

.note-text {
  font-size: 22rpx;
  color: var(--text-secondary);
  line-height: 1.4;
}

/* 系统信息 */
.info-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  margin-bottom: 16rpx;
}

.toggle-icon {
  font-size: 24rpx;
  color: var(--text-secondary);
  transition: transform 0.3s ease;
}

.toggle-icon.expanded {
  transform: rotate(180deg);
}

.system-info-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  padding: 32rpx;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 0;
  border-bottom: 1rpx solid rgba(255, 255, 255, 0.2);
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 26rpx;
  color: var(--text-secondary);
}

.info-value {
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 600;
}

/* 历史反馈 */
.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.view-all {
  font-size: 24rpx;
  color: var(--primary-color);
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.history-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx 32rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
}

.history-icon {
  font-size: 28rpx;
}

.history-info {
  flex: 1;
}

.history-title {
  display: block;
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 600;
  margin-bottom: 8rpx;
}

.history-time {
  display: block;
  font-size: 22rpx;
  color: var(--text-secondary);
}

.history-status {
  padding: 6rpx 16rpx;
  border-radius: 12rpx;
  font-size: 20rpx;
  font-weight: 600;
}

.history-status.pending {
  background: rgba(243, 156, 18, 0.2);
  color: var(--warning-color);
}

.history-status.processing {
  background: rgba(52, 152, 219, 0.2);
  color: var(--primary-color);
}

.history-status.resolved {
  background: rgba(39, 174, 96, 0.2);
  color: var(--success-color);
}

.history-status.closed {
  background: rgba(149, 165, 166, 0.2);
  color: #95a5a6;
}

.status-text {
  font-size: 20rpx;
}

/* 提交按钮 */
.submit-section {
  margin-top: 40rpx;
  text-align: center;
}

.submit-button {
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
  margin-bottom: 16rpx;
}

.submit-button.disabled {
  background: rgba(149, 165, 166, 0.5);
  box-shadow: none;
}

.submit-button:active:not(.disabled) {
  transform: scale(0.98);
}

.submit-tips {
  padding: 16rpx;
}

.tips-text {
  font-size: 22rpx;
  color: var(--text-secondary);
}
</style> 