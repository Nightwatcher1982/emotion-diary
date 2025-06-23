<template>
  <view class="container">
    <view class="debug-panel">
      <text class="debug-title">🔧 AI分析页面调试</text>
      
      <view class="debug-section">
        <text class="section-title">基本状态</text>
        <text class="debug-item">加载状态: {{ isLoading ? '加载中' : '已完成' }}</text>
        <text class="debug-item">Token: {{ hasToken ? '已登录' : '未登录' }}</text>
        <text class="debug-item">分析数据: {{ hasData ? '有数据' : '无数据' }}</text>
        <text class="debug-item">错误: {{ errorMsg || '无错误' }}</text>
      </view>
      
      <view class="debug-section">
        <text class="section-title">操作按钮</text>
        <button class="debug-btn" @click="checkLogin">检查登录</button>
        <button class="debug-btn" @click="loadMockData">加载模拟数据</button>
        <button class="debug-btn" @click="testAPI">测试API</button>
        <button class="debug-btn" @click="goToMainPage">返回主页面</button>
      </view>
      
      <view class="debug-section" v-if="analysisData">
        <text class="section-title">分析数据预览</text>
        <text class="debug-item">主要情绪: {{ analysisData.primaryEmotion?.name }}</text>
        <text class="debug-item">置信度: {{ analysisData.primaryEmotion?.confidence }}%</text>
        <text class="debug-item">AI驱动: {{ analysisData.ai_powered ? '是' : '否' }}</text>
        <text class="debug-item">测试模式: {{ analysisData.test_mode ? '是' : '否' }}</text>
      </view>
    </view>
    
    <!-- 如果有数据，显示简化的分析结果 -->
    <view class="simple-analysis" v-if="hasData">
      <view class="card">
        <text class="card-title">情绪分析结果</text>
        <view class="emotion-display">
          <text class="emotion-icon">{{ analysisData.primaryEmotion?.icon }}</text>
          <text class="emotion-name">{{ analysisData.primaryEmotion?.name }}</text>
          <text class="confidence">置信度: {{ analysisData.primaryEmotion?.confidence }}%</text>
        </view>
        
        <view class="status-badges">
          <text class="badge ai-badge" v-if="analysisData.ai_powered">🤖 AI驱动</text>
          <text class="badge test-badge" v-if="analysisData.test_mode">🧪 测试模式</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { aiAPI, emotionAPI, getToken } from '../../utils/api'

// 响应式数据
const isLoading = ref(false)
const analysisData = ref<any>({})
const errorMsg = ref('')

// 计算属性
const hasToken = computed(() => !!getToken())
const hasData = computed(() => analysisData.value && analysisData.value.primaryEmotion)

// 方法
const checkLogin = () => {
  const token = getToken()
  if (token) {
    uni.showToast({
      title: '已登录',
      icon: 'success'
    })
  } else {
    uni.showToast({
      title: '未登录',
      icon: 'none'
    })
    uni.navigateTo({
      url: '/pages/login/index'
    })
  }
}

const loadMockData = () => {
  console.log('加载模拟数据')
  analysisData.value = {
    timestamp: Date.now(),
    primaryEmotion: {
      name: '焦虑',
      icon: '😟',
      confidence: 85
    },
    ai_powered: true,
    test_mode: true
  }
  errorMsg.value = ''
  uni.showToast({
    title: '模拟数据已加载',
    icon: 'success'
  })
}

const testAPI = async () => {
  try {
    isLoading.value = true
    errorMsg.value = ''
    
    const token = getToken()
    if (!token) {
      throw new Error('未登录')
    }
    
    // 先测试获取情绪记录
    const records = await emotionAPI.getRecentRecords()
    console.log('获取到的记录:', records)
    
    if (!records || (records.results && records.results.length === 0) || records.length === 0) {
      throw new Error('没有情绪记录数据')
    }
    
    const recordList = records.results || records
    
    // 测试AI分析API
    const analysisRequest = {
      emotion_records: recordList.slice(0, 1).map((r: any) => r.id),
      analysis_type: 'comprehensive'
    }
    
    console.log('调用AI分析API:', analysisRequest)
    const aiResponse = await aiAPI.realtimeAnalysis(analysisRequest)
    console.log('AI分析响应:', aiResponse)
    
    analysisData.value = aiResponse
    
    uni.showToast({
      title: 'API测试成功',
      icon: 'success'
    })
    
  } catch (error) {
    console.error('API测试失败:', error)
    errorMsg.value = error.message || '测试失败'
    uni.showToast({
      title: `测试失败: ${error.message}`,
      icon: 'none'
    })
  } finally {
    isLoading.value = false
  }
}

const goToMainPage = () => {
  uni.navigateBack()
}

onMounted(() => {
  console.log('调试页面已加载')
})
</script>

<style scoped>
.container {
  padding: 20rpx;
  background: #f8f9fa;
  min-height: 100vh;
}

.debug-panel {
  background: white;
  border-radius: 16rpx;
  padding: 30rpx;
  margin-bottom: 30rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.1);
}

.debug-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 30rpx;
  display: block;
}

.debug-section {
  margin-bottom: 30rpx;
}

.section-title {
  font-size: 26rpx;
  font-weight: 600;
  color: #666;
  margin-bottom: 16rpx;
  display: block;
}

.debug-item {
  font-size: 24rpx;
  color: #888;
  margin-bottom: 8rpx;
  display: block;
}

.debug-btn {
  background: #007bff;
  color: white;
  border: none;
  border-radius: 12rpx;
  padding: 16rpx 24rpx;
  margin: 8rpx 8rpx 8rpx 0;
  font-size: 24rpx;
}

.simple-analysis {
  background: white;
  border-radius: 16rpx;
  padding: 30rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.1);
}

.card-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 20rpx;
  display: block;
}

.emotion-display {
  text-align: center;
  margin-bottom: 20rpx;
}

.emotion-icon {
  font-size: 60rpx;
  display: block;
  margin-bottom: 10rpx;
}

.emotion-name {
  font-size: 32rpx;
  font-weight: 600;
  color: #333;
  display: block;
  margin-bottom: 8rpx;
}

.confidence {
  font-size: 24rpx;
  color: #666;
  display: block;
}

.status-badges {
  display: flex;
  gap: 12rpx;
  justify-content: center;
  margin-top: 20rpx;
}

.badge {
  padding: 8rpx 16rpx;
  border-radius: 20rpx;
  font-size: 20rpx;
  font-weight: 500;
}

.ai-badge {
  background: #e3f2fd;
  color: #1976d2;
}

.test-badge {
  background: #fff3e0;
  color: #f57c00;
}
</style> 