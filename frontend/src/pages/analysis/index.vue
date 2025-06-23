<template>
  <view class="container">
    <!-- 装饰性背景 -->
    <view class="bg-decoration"></view>

    <!-- 调试面板 -->
    <view v-if="showDebug" class="debug-panel">
      <text class="debug-title">🔧 调试信息</text>
      <text class="debug-item">加载状态: {{ isLoading ? '加载中' : '已完成' }}</text>
      <text class="debug-item">数据状态: {{ hasAnalysisData ? '有数据' : '无数据' }}</text>
      <text class="debug-item">错误信息: {{ error || '无' }}</text>
      <text class="debug-item">最后更新: {{ lastUpdate }}</text>
    </view>

    <!-- 浮动操作按钮 -->
    <view class="floating-actions">
      <button @click="toggleDebug" class="floating-btn">🔧</button>
    </view>

    <!-- 页面头部 -->
    <view class="page-header glass-card">
      <view class="header-content">
        <text class="page-title">AI情绪分析</text>
        <view class="status-info">
          <view class="status-badge">
            <text class="status-text">✅ AI测试模式</text>
          </view>
          <text class="time-text">{{ getCurrentTime() }}</text>
        </view>
        <view class="action-buttons">
          <button @click="saveReport" class="primary-btn">
            <text class="btn-icon">💾</text>
            <text class="btn-text">保存报告</text>
          </button>
          <button @click="refreshAnalysis" class="secondary-btn">
            <text class="btn-icon">🔄</text>
            <text class="btn-text">重新分析</text>
          </button>
        </view>
      </view>
    </view>

    <!-- 加载状态 -->
    <view v-if="isLoading" class="loading-container glass-card">
      <view class="loading-animation"></view>
      <text class="loading-title">🧠 AI正在分析中...</text>
      <text class="loading-subtitle">请稍候，正在生成您的情绪洞察</text>
    </view>

    <!-- 空状态 -->
    <view v-else-if="!hasAnalysisData" class="empty-state glass-card">
      <text class="empty-icon">🤔</text>
      <text class="empty-title">暂无分析数据</text>
      <text class="empty-subtitle">记录您的情绪，让AI为您提供专业的心理分析和个性化建议</text>
      <view class="empty-actions">
        <button @click="showExampleData" class="primary-btn">
          <text class="btn-icon">✨</text>
          <text class="btn-text">查看示例数据</text>
        </button>
        <button @click="goToRecord" class="secondary-btn">
          <text class="btn-icon">📝</text>
          <text class="btn-text">去记录情绪</text>
        </button>
      </view>
    </view>

    <!-- 分析报告内容 -->
    <view v-else class="analysis-report">
      
      <!-- 情绪概览卡片 -->
      <view class="emotion-summary-card glass-card">
        <view class="card-header">
          <view class="card-title-section">
            <text class="card-title">🎯 核心洞察</text>
            <view class="emotion-pulse"></view>
          </view>
          <text class="view-more" @click="toggleCoreInsights">
            <text>{{ showCoreInsights ? '收起详情' : '查看详情' }}</text>
            <text class="arrow-icon" :class="{ 'rotated': showCoreInsights }">→</text>
          </text>
        </view>
        <text class="card-subtitle">主要情绪状态分析</text>
        
        <view class="emotion-display">
          <view class="emotion-visual">
            <view class="emotion-icon-container">
              <view class="emotion-glow"></view>
              <text class="emotion-icon">{{ analysisData.primaryEmotion.icon }}</text>
            </view>
            <view class="emotion-spectrum">
              <view class="spectrum-bar">
                <view class="spectrum-fill" :style="{ width: analysisData.primaryEmotion.confidence + '%' }"></view>
              </view>
              <text class="intensity-text">{{ analysisData.primaryEmotion.confidence }}%</text>
            </view>
          </view>
          <view class="emotion-details">
            <text class="emotion-name">{{ analysisData.primaryEmotion.name }}</text>
            <view class="emotion-meta">
              <view class="meta-item">
                <text class="meta-icon">📊</text>
                <text class="meta-text">置信度 {{ analysisData.primaryEmotion.confidence }}%</text>
              </view>
              <view class="meta-item">
                <text class="meta-icon">⏰</text>
                <text class="meta-text">{{ getCurrentTime() }}</text>
              </view>
            </view>
          </view>
        </view>

        <!-- 核心洞察详情展开 -->
        <view v-if="showCoreInsights" class="core-insights-detail">
          <view class="insights-section">
            <text class="insights-title">🧠 AI深度分析</text>
            <view class="insights-content">
              <view class="insight-item" v-for="(insight, index) in analysisData.coreInsights" :key="index">
                <view class="insight-header">
                  <text class="insight-icon">{{ insight.icon }}</text>
                  <text class="insight-category">{{ insight.category }}</text>
                  <view class="insight-confidence">
                    <text class="confidence-text">{{ insight.confidence }}%</text>
                  </view>
                </view>
                <text class="insight-description">{{ insight.description }}</text>
                <view class="insight-tags">
                  <text v-for="tag in insight.tags" :key="tag" class="insight-tag">{{ tag }}</text>
                </view>
              </view>
            </view>
          </view>

          <view class="emotion-triggers-section">
            <text class="section-title">🎯 情绪触发因素</text>
            <view class="triggers-list">
              <view class="trigger-item" v-for="(trigger, index) in analysisData.emotionTriggers" :key="index">
                <view class="trigger-icon-container">
                  <text class="trigger-icon">{{ trigger.icon }}</text>
                </view>
                <view class="trigger-content">
                  <text class="trigger-name">{{ trigger.name }}</text>
                  <text class="trigger-description">{{ trigger.description }}</text>
                  <view class="trigger-intensity">
                    <view class="intensity-bar">
                      <view class="intensity-fill" :style="{ width: trigger.intensity + '%' }"></view>
                    </view>
                    <text class="intensity-label">影响强度 {{ trigger.intensity }}%</text>
                  </view>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- 情绪光谱卡片 -->
      <view v-if="analysisData.emotionSpectrum" class="emotion-spectrum-card glass-card">
        <view class="card-header">
          <view class="card-title-section">
            <text class="card-title">📊 情绪光谱分析</text>
          </view>
          <text class="view-more" @click="toggleSpectrumDetail">
            <text>{{ showSpectrumDetail ? '收起详情' : '展开详情' }}</text>
            <text class="arrow-icon" :class="{ 'rotated': showSpectrumDetail }">→</text>
          </text>
        </view>
        
        <view class="spectrum-list">
          <view 
            v-for="(emotion, index) in analysisData.emotionSpectrum" 
            :key="emotion.name"
            class="spectrum-item"
            @click="selectEmotion(emotion, index)"
            :class="{ 'selected': selectedEmotionIndex === index }"
          >
            <view class="spectrum-header">
              <view class="spectrum-name-section">
                <text class="spectrum-icon">{{ emotion.icon }}</text>
                <text class="spectrum-name">{{ emotion.name }}</text>
              </view>
              <text class="spectrum-percentage">{{ emotion.percentage }}%</text>
            </view>
            <view class="spectrum-bar-container">
              <view 
                class="spectrum-bar-fill" 
                :class="'spectrum-color-' + index"
                :style="{ width: emotion.percentage + '%' }"
              ></view>
            </view>
            
            <!-- 选中情绪的详细信息 -->
            <view v-if="selectedEmotionIndex === index && showSpectrumDetail" class="emotion-detail-info">
              <view class="detail-metrics">
                <view class="metric-item">
                  <text class="metric-label">强度等级</text>
                  <view class="metric-value-container">
                    <view class="metric-stars">
                      <text v-for="star in 5" :key="star" 
                            class="star" 
                            :class="{ 'filled': star <= emotion.intensity }">★</text>
                    </view>
                    <text class="metric-text">{{ emotion.intensityLabel }}</text>
                  </view>
                </view>
                <view class="metric-item">
                  <text class="metric-label">持续时间</text>
                  <text class="metric-value">{{ emotion.duration }}</text>
                </view>
                <view class="metric-item">
                  <text class="metric-label">影响范围</text>
                  <text class="metric-value">{{ emotion.impact }}</text>
                </view>
              </view>
              
              <view class="emotion-characteristics">
                <text class="characteristics-title">特征描述</text>
                <text class="characteristics-text">{{ emotion.characteristics }}</text>
              </view>
              
              <view class="related-emotions">
                <text class="related-title">相关情绪</text>
                <view class="related-tags">
                  <text v-for="related in emotion.relatedEmotions" :key="related" class="related-tag">{{ related }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>

        <!-- 情绪光谱总览图表 -->
        <view v-if="showSpectrumDetail" class="spectrum-chart-section">
          <text class="chart-title">📈 情绪分布图表</text>
          <view class="emotion-radar-chart">
            <view class="radar-container">
              <view class="radar-grid">
                <view class="grid-circle" v-for="circle in 4" :key="circle" :style="{ width: circle * 25 + '%', height: circle * 25 + '%' }"></view>
                <view class="grid-line" v-for="line in 8" :key="line" :style="{ transform: 'rotate(' + (line * 45) + 'deg)' }"></view>
              </view>
              <view class="radar-data">
                <view 
                  v-for="(emotion, index) in analysisData.emotionSpectrum" 
                  :key="emotion.name"
                  class="radar-point"
                  :style="getRadarPointStyle(emotion, index)"
                >
                  <view class="point-dot" :class="'color-' + index"></view>
                  <text class="point-label">{{ emotion.name }}</text>
                </view>
              </view>
            </view>
          </view>
          
          <view class="chart-legend">
            <view v-for="(emotion, index) in analysisData.emotionSpectrum" :key="emotion.name" class="legend-item">
              <view class="legend-color" :class="'spectrum-color-' + index"></view>
              <text class="legend-text">{{ emotion.name }} ({{ emotion.percentage }}%)</text>
            </view>
          </view>
        </view>
      </view>

      <!-- AI建议卡片 -->
      <view class="ai-suggestions-card glass-card">
        <view class="card-header">
          <view class="card-title-section">
            <text class="card-title">💡 AI个性化建议</text>
          </view>
        </view>
        
        <view class="suggestions-content">
          <view class="suggestion-category" v-for="(category, categoryIndex) in analysisData.suggestions" :key="categoryIndex">
            <view class="category-header">
              <text class="category-icon">{{ category.icon }}</text>
              <text class="category-title">{{ category.title }}</text>
              <view class="category-priority" :class="'priority-' + category.priority">
                <text class="priority-text">{{ category.priorityLabel }}</text>
              </view>
            </view>
            
            <view class="category-suggestions">
              <view class="suggestion-item" v-for="(suggestion, index) in category.items" :key="index">
                <view class="suggestion-content">
                  <text class="suggestion-title">{{ suggestion.title }}</text>
                  <text class="suggestion-description">{{ suggestion.description }}</text>
                  <view class="suggestion-benefits">
                    <text class="benefits-title">预期效果：</text>
                    <text class="benefits-text">{{ suggestion.benefits }}</text>
                  </view>
                </view>
                <view class="suggestion-action">
                  <button class="action-btn" @click="applySuggestion(suggestion)">
                    <text class="action-text">尝试</text>
                  </button>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>

    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      isLoading: false,
      hasAnalysisData: true,
      showDebug: false,
      error: null,
      lastUpdate: new Date().toLocaleString(),
      showCoreInsights: false,
      showSpectrumDetail: false,
      selectedEmotionIndex: -1,
      analysisData: {
        primaryEmotion: {
          name: '悲伤',
          icon: '😢',
          confidence: 85
        },
        coreInsights: [
          {
            icon: '🎭',
            category: '情绪模式',
            confidence: 92,
            description: '您当前处于深度内省状态，这种情绪反应通常与重要生活事件或人际关系变化相关。',
            tags: ['内省', '敏感', '深度思考']
          },
          {
            icon: '🧘',
            category: '心理状态',
            confidence: 88,
            description: '分析显示您具有很强的情感感知能力，但可能需要更多的自我关怀和情绪调节。',
            tags: ['高敏感', '共情能力', '需要关怀']
          },
          {
            icon: '🌱',
            category: '成长潜力',
            confidence: 95,
            description: '当前的情绪体验是个人成长的重要机会，通过适当的引导可以转化为积极的力量。',
            tags: ['成长机会', '转化潜力', '自我发现']
          }
        ],
        emotionTriggers: [
          {
            icon: '👥',
            name: '人际关系',
            description: '与重要他人的互动模式影响情绪状态',
            intensity: 78
          },
          {
            icon: '💼',
            name: '工作压力',
            description: '职业相关的期望和挑战带来情绪波动',
            intensity: 65
          },
          {
            icon: '🏠',
            name: '生活环境',
            description: '周围环境的变化对情绪产生微妙影响',
            intensity: 45
          }
        ],
        emotionSpectrum: [
          { 
            name: '悲伤', 
            icon: '😢',
            percentage: 65,
            intensity: 4,
            intensityLabel: '中高强度',
            duration: '2-3小时',
            impact: '中等影响',
            characteristics: '深层的情感体验，伴随着对过去事件的反思和对未来的不确定感。这种情绪有助于处理失落和变化。',
            relatedEmotions: ['失落', '怀念', '反思', '孤独']
          },
          { 
            name: '焦虑', 
            icon: '😰',
            percentage: 21,
            intensity: 3,
            intensityLabel: '中等强度',
            duration: '1-2小时',
            impact: '轻度影响',
            characteristics: '对未来不确定性的担忧，伴随着身体紧张感。适度的焦虑有助于保持警觉和准备应对挑战。',
            relatedEmotions: ['担忧', '紧张', '不安', '警觉']
          },
          { 
            name: '平静', 
            icon: '😌',
            percentage: 14,
            intensity: 2,
            intensityLabel: '轻度',
            duration: '30分钟-1小时',
            impact: '积极影响',
            characteristics: '内心的宁静状态，思维清晰，情绪稳定。这是恢复和自我调节的重要时刻。',
            relatedEmotions: ['宁静', '放松', '清晰', '稳定']
          }
        ],
        suggestions: [
          {
            icon: '🧘‍♀️',
            title: '情绪调节',
            priority: 'high',
            priorityLabel: '高优先级',
            items: [
              {
                title: '深呼吸练习',
                description: '每天进行5-10分钟的深呼吸冥想，帮助缓解焦虑情绪',
                benefits: '降低压力水平，提升情绪稳定性'
              },
              {
                title: '情绪日记',
                description: '记录每日情绪变化，识别触发因素和模式',
                benefits: '增强自我觉察，改善情绪管理能力'
              }
            ]
          },
          {
            icon: '🤝',
            title: '社交支持',
            priority: 'medium',
            priorityLabel: '中优先级',
            items: [
              {
                title: '寻求倾听',
                description: '与信任的朋友或家人分享您的感受',
                benefits: '获得情感支持，减少孤独感'
              },
              {
                title: '参与社交活动',
                description: '适度参与轻松愉快的社交互动',
                benefits: '提升情绪，扩展支持网络'
              }
            ]
          },
          {
            icon: '🎨',
            title: '创意表达',
            priority: 'low',
            priorityLabel: '低优先级',
            items: [
              {
                title: '艺术创作',
                description: '通过绘画、写作或音乐表达内心感受',
                benefits: '情绪释放，促进自我理解'
              }
            ]
          }
        ]
      }
    }
  },
  methods: {
    toggleDebug() {
      this.showDebug = !this.showDebug
    },
    getCurrentTime() {
      return new Date().toLocaleString()
    },
    saveReport() {
      console.log('保存报告')
      uni.showToast({
        title: '报告已保存',
        icon: 'success'
      })
    },
    refreshAnalysis() {
      console.log('重新分析')
      this.isLoading = true
      setTimeout(() => {
        this.isLoading = false
        this.lastUpdate = new Date().toLocaleString()
        uni.showToast({
          title: '分析已更新',
          icon: 'success'
        })
      }, 2000)
    },
    showExampleData() {
      this.hasAnalysisData = true
    },
    goToRecord() {
      uni.navigateTo({
        url: '/pages/record/index'
      })
    },
    toggleCoreInsights() {
      this.showCoreInsights = !this.showCoreInsights
    },
    toggleSpectrumDetail() {
      this.showSpectrumDetail = !this.showSpectrumDetail
      if (!this.showSpectrumDetail) {
        this.selectedEmotionIndex = -1
      }
    },
    selectEmotion(emotion, index) {
      if (this.showSpectrumDetail) {
        this.selectedEmotionIndex = this.selectedEmotionIndex === index ? -1 : index
      }
    },
    getRadarPointStyle(emotion, index) {
      const angle = (index * 360) / this.analysisData.emotionSpectrum.length
      const radius = (emotion.percentage / 100) * 40 // 40% 是最大半径
      const x = 50 + radius * Math.cos((angle - 90) * Math.PI / 180)
      const y = 50 + radius * Math.sin((angle - 90) * Math.PI / 180)
      
      return {
        left: x + '%',
        top: y + '%',
        transform: 'translate(-50%, -50%)'
      }
    },
    applySuggestion(suggestion) {
      console.log('应用建议:', suggestion.title)
      uni.showToast({
        title: '已添加到计划',
        icon: 'success'
      })
    }
  }
}
</script>

<style scoped>
/* CSS变量定义 - 与其他页面保持一致 */
:root {
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  --success-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --shadow-light: 0 8rpx 32rpx rgba(31, 38, 135, 0.37);
  --shadow-card: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);
}

.container {
  padding: 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
  position: relative;
}

/* 背景装饰 - 与首页一致 */
.container::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: 
    radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.bg-decoration {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  z-index: 0;
}

/* 调试面板 */
.debug-panel {
  position: fixed;
  top: 50rpx;
  left: 20rpx;
  right: 20rpx;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 20rpx;
  border-radius: 16rpx;
  z-index: 9999;
  font-size: 24rpx;
  max-height: 300rpx;
  overflow-y: auto;
}

.debug-title {
  font-weight: 700;
  margin-bottom: 10rpx;
  display: block;
}

.debug-item {
  display: block;
  margin-bottom: 5rpx;
}

/* 浮动按钮 */
.floating-actions {
  position: fixed;
  top: 120rpx;
  right: 30rpx;
  z-index: 1000;
}

.floating-btn {
  width: 80rpx;
  height: 80rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10px);
  border: 1px solid var(--glass-border);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #2d3748;
  font-size: 24rpx;
  box-shadow: var(--shadow-card);
  transition: all 0.3s ease;
}

.floating-btn:active {
  transform: scale(0.95);
}

/* 毛玻璃卡片样式 - 与其他页面一致 */
.glass-card {
  background: var(--glass-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--glass-border);
  border-radius: 25rpx;
  box-shadow: var(--shadow-light);
  margin: 0 20rpx 30rpx;
  position: relative;
  z-index: 1;
}

.glass-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
  border-radius: 25rpx;
}

/* 页面头部 */
.page-header {
  margin-top: 30rpx;
  padding: 30rpx;
  overflow: hidden;
}

.header-content {
  position: relative;
  z-index: 2;
}

.page-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 20rpx;
  display: block;
  text-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.1);
}

.status-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 25rpx;
}

.status-badge {
  background: rgba(34, 197, 94, 0.2);
  border: 1px solid rgba(34, 197, 94, 0.3);
  border-radius: 20rpx;
  padding: 8rpx 16rpx;
}

.status-text {
  color: #15803d;
  font-weight: 600;
  font-size: 22rpx;
}

.time-text {
  color: #4a5568;
  font-weight: 500;
  font-size: 24rpx;
}

.action-buttons {
  display: flex;
  gap: 15rpx;
}

.primary-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 25rpx;
  padding: 15rpx 25rpx;
  font-weight: 600;
  font-size: 24rpx;
  box-shadow: var(--shadow-card);
  transition: all 0.3s ease;
}

.primary-btn:active {
  transform: scale(0.95);
}

.secondary-btn {
  display: flex;
  align-items: center;
  gap: 8rpx;
  background: var(--glass-bg);
  color: #2d3748;
  border: 1px solid var(--glass-border);
  border-radius: 25rpx;
  padding: 15rpx 25rpx;
  font-weight: 600;
  font-size: 24rpx;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.secondary-btn:active {
  transform: scale(0.95);
}

.btn-icon {
  font-size: 20rpx;
}

.btn-text {
  font-size: 24rpx;
}

/* 加载状态 */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400rpx;
  padding: 40rpx;
  text-align: center;
}

.loading-animation {
  width: 80rpx;
  height: 80rpx;
  border: 6rpx solid rgba(102, 126, 234, 0.2);
  border-top: 6rpx solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 30rpx;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-title {
  color: #2d3748;
  font-weight: 700;
  font-size: 28rpx;
  margin-bottom: 15rpx;
  text-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.1);
}

.loading-subtitle {
  color: #4a5568;
  font-weight: 500;
  font-size: 24rpx;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400rpx;
  padding: 40rpx;
  text-align: center;
}

.empty-icon {
  font-size: 100rpx;
  margin-bottom: 30rpx;
  opacity: 0.7;
}

.empty-title {
  color: #2d3748;
  font-weight: 700;
  font-size: 32rpx;
  margin-bottom: 20rpx;
  text-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.1);
}

.empty-subtitle {
  color: #4a5568;
  font-weight: 500;
  font-size: 26rpx;
  line-height: 1.5;
  margin-bottom: 40rpx;
}

.empty-actions {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  width: 100%;
}

/* 分析报告 */
.analysis-report {
  padding: 0 0 40rpx;
}

/* 情绪概览卡片 - 采用首页样式 */
.emotion-summary-card {
  padding: 30rpx;
  overflow: hidden;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25rpx;
  position: relative;
  z-index: 2;
}

.card-title-section {
  display: flex;
  align-items: center;
}

.card-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2d3748;
  margin-right: 15rpx;
}

.emotion-pulse {
  width: 12rpx;
  height: 12rpx;
  background: #48bb78;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(72, 187, 120, 0.7);
  }
  70% {
    transform: scale(1);
    box-shadow: 0 0 0 10rpx rgba(72, 187, 120, 0);
  }
  100% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(72, 187, 120, 0);
  }
}

.view-more {
  display: flex;
  align-items: center;
  font-size: 26rpx;
  color: #667eea;
  font-weight: 600;
  transition: all 0.3s ease;
}

.view-more:active {
  transform: scale(0.95);
}

.arrow-icon {
  margin-left: 8rpx;
  transition: transform 0.3s ease;
}

.view-more:active .arrow-icon {
  transform: translateX(5rpx);
}

/* 箭头旋转动画 */
.arrow-icon.rotated {
  transform: rotate(90deg);
}

.card-subtitle {
  color: #4a5568;
  font-weight: 500;
  font-size: 26rpx;
  margin-bottom: 30rpx;
  position: relative;
  z-index: 2;
}

.emotion-display {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  position: relative;
  z-index: 2;
}

.emotion-visual {
  display: flex;
  align-items: center;
  gap: 25rpx;
}

.emotion-icon-container {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.emotion-glow {
  position: absolute;
  width: 80rpx;
  height: 80rpx;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.3) 0%, transparent 70%);
  border-radius: 50%;
  animation: glow 3s ease-in-out infinite alternate;
}

@keyframes glow {
  from { transform: scale(0.8); opacity: 0.5; }
  to { transform: scale(1.2); opacity: 0.8; }
}

.emotion-icon {
  font-size: 60rpx;
  position: relative;
  z-index: 2;
  filter: drop-shadow(0 4rpx 8rpx rgba(0, 0, 0, 0.1));
}

.emotion-spectrum {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.spectrum-bar {
  height: 8rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 10rpx;
  overflow: hidden;
  position: relative;
}

.spectrum-fill {
  height: 100%;
  background: linear-gradient(90deg, #48bb78, #38a169, #2f855a);
  border-radius: 10rpx;
  transition: width 1s ease-out;
  position: relative;
}

.spectrum-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.intensity-text {
  font-size: 24rpx;
  color: #4a5568;
  font-weight: 600;
  align-self: flex-end;
}

.emotion-details {
  display: flex;
  flex-direction: column;
  gap: 15rpx;
}

.emotion-name {
  font-size: 36rpx;
  font-weight: 700;
  color: #2d3748;
  text-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.1);
}

.emotion-meta {
  display: flex;
  gap: 20rpx;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.meta-icon {
  font-size: 20rpx;
  opacity: 0.8;
}

.meta-text {
  font-size: 24rpx;
  color: #4a5568;
  font-weight: 500;
}

/* 情绪光谱卡片 */
.emotion-spectrum-card {
  padding: 30rpx;
  overflow: hidden;
}

.spectrum-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  position: relative;
  z-index: 2;
}

.spectrum-item {
  background: rgba(255, 255, 255, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 16rpx;
  padding: 20rpx;
  transition: all 0.3s ease;
  cursor: pointer;
}

.spectrum-item:active {
  transform: scale(0.98);
}

.spectrum-item.selected {
  background: rgba(255, 255, 255, 0.5);
  border: 2px solid rgba(102, 126, 234, 0.5);
  box-shadow: 0 4rpx 20rpx rgba(102, 126, 234, 0.2);
}

.spectrum-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15rpx;
}

.spectrum-name-section {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.spectrum-icon {
  font-size: 24rpx;
}

.spectrum-name {
  color: #2d3748;
  font-weight: 700;
  font-size: 28rpx;
}

.spectrum-percentage {
  color: #4a5568;
  font-weight: 600;
  font-size: 26rpx;
}

.spectrum-bar-container {
  background: rgba(255, 255, 255, 0.4);
  border-radius: 10rpx;
  height: 16rpx;
  overflow: hidden;
  position: relative;
}

.spectrum-bar-fill {
  height: 100%;
  border-radius: 10rpx;
  transition: width 1s ease-out;
  position: relative;
}

.spectrum-bar-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  animation: shimmer 2s infinite;
}

.spectrum-color-0 {
  background: linear-gradient(90deg, #ef4444, #dc2626);
}

.spectrum-color-1 {
  background: linear-gradient(90deg, #f59e0b, #d97706);
}

.spectrum-color-2 {
  background: linear-gradient(90deg, #10b981, #059669);
}

/* 情绪详情信息 */
.emotion-detail-info {
  margin-top: 20rpx;
  padding: 20rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 12rpx;
  border-top: 2px solid rgba(102, 126, 234, 0.3);
}

.detail-metrics {
  display: flex;
  flex-direction: column;
  gap: 15rpx;
  margin-bottom: 20rpx;
}

.metric-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric-label {
  color: #4a5568;
  font-weight: 600;
  font-size: 24rpx;
}

.metric-value-container {
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.metric-stars {
  display: flex;
  gap: 2rpx;
}

.star {
  color: #d1d5db;
  font-size: 20rpx;
  transition: color 0.3s ease;
}

.star.filled {
  color: #f59e0b;
}

.metric-text {
  color: #4a5568;
  font-weight: 500;
  font-size: 22rpx;
}

.metric-value {
  color: #4a5568;
  font-weight: 600;
  font-size: 24rpx;
}

.emotion-characteristics {
  margin-bottom: 20rpx;
}

.characteristics-title {
  color: #2d3748;
  font-weight: 700;
  font-size: 26rpx;
  margin-bottom: 10rpx;
  display: block;
}

.characteristics-text {
  color: #4a5568;
  font-weight: 500;
  font-size: 24rpx;
  line-height: 1.6;
}

.related-emotions {
  margin-top: 15rpx;
}

.related-title {
  color: #2d3748;
  font-weight: 700;
  font-size: 26rpx;
  margin-bottom: 10rpx;
  display: block;
}

.related-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.related-tag {
  background: rgba(102, 126, 234, 0.2);
  color: #667eea;
  border-radius: 16rpx;
  padding: 6rpx 12rpx;
  font-size: 22rpx;
  font-weight: 600;
}

/* 核心洞察详情展开 */
.core-insights-detail {
  margin-top: 30rpx;
  padding: 25rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.3);
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-20rpx);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.insights-section {
  margin-bottom: 30rpx;
}

.insights-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 20rpx;
  display: block;
}

.insights-content {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.insight-item {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 16rpx;
  padding: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.insight-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 15rpx;
}

.insight-icon {
  font-size: 28rpx;
}

.insight-category {
  color: #2d3748;
  font-weight: 700;
  font-size: 28rpx;
  flex: 1;
}

.insight-confidence {
  background: rgba(34, 197, 94, 0.2);
  border: 1px solid rgba(34, 197, 94, 0.3);
  border-radius: 20rpx;
  padding: 6rpx 12rpx;
}

.confidence-text {
  color: #15803d;
  font-weight: 700;
  font-size: 22rpx;
}

.insight-description {
  color: #4a5568;
  font-weight: 500;
  font-size: 26rpx;
  line-height: 1.6;
  margin-bottom: 15rpx;
}

.insight-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}

.insight-tag {
  background: rgba(102, 126, 234, 0.2);
  color: #667eea;
  border-radius: 16rpx;
  padding: 6rpx 12rpx;
  font-size: 22rpx;
  font-weight: 600;
}

.emotion-triggers-section {
  padding: 25rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 20rpx;
  display: block;
}

.triggers-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.trigger-item {
  display: flex;
  align-items: flex-start;
  gap: 15rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 16rpx;
  padding: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.trigger-icon-container {
  background: rgba(102, 126, 234, 0.2);
  border-radius: 12rpx;
  padding: 10rpx;
  min-width: 48rpx;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.trigger-icon {
  font-size: 24rpx;
}

.trigger-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.trigger-name {
  color: #2d3748;
  font-weight: 700;
  font-size: 28rpx;
}

.trigger-description {
  color: #4a5568;
  font-weight: 500;
  font-size: 24rpx;
  line-height: 1.5;
}

.trigger-intensity {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  min-width: 120rpx;
}

.intensity-bar {
  height: 8rpx;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 10rpx;
  overflow: hidden;
  position: relative;
}

.intensity-fill {
  height: 100%;
  background: linear-gradient(90deg, #f59e0b, #d97706);
  border-radius: 10rpx;
  transition: width 1s ease-out;
  position: relative;
}

.intensity-label {
  font-size: 20rpx;
  color: #4a5568;
  font-weight: 600;
  text-align: center;
}

/* 情绪光谱总览图表 */
.spectrum-chart-section {
  margin-top: 30rpx;
  padding: 25rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.3);
  animation: slideDown 0.3s ease-out;
}

.chart-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 25rpx;
  display: block;
  text-align: center;
}

.emotion-radar-chart {
  position: relative;
  width: 100%;
  height: 300rpx;
  margin-bottom: 25rpx;
}

.radar-container {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.radar-grid {
  position: absolute;
  width: 200rpx;
  height: 200rpx;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.grid-circle {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
}

.grid-line {
  position: absolute;
  top: 0;
  left: 50%;
  width: 1px;
  height: 100%;
  background: rgba(255, 255, 255, 0.2);
  transform-origin: center top;
}

.radar-data {
  position: absolute;
  width: 200rpx;
  height: 200rpx;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.radar-point {
  position: absolute;
  transform: translate(-50%, -50%);
}

.point-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 50%;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.2);
}

.color-0 .point-dot {
  background: #ef4444;
}

.color-1 .point-dot {
  background: #f59e0b;
}

.color-2 .point-dot {
  background: #10b981;
}

.point-label {
  position: absolute;
  top: -30rpx;
  left: 50%;
  transform: translateX(-50%);
  color: #2d3748;
  font-weight: 600;
  font-size: 20rpx;
  white-space: nowrap;
  text-shadow: 0 1rpx 2rpx rgba(255, 255, 255, 0.8);
}

.chart-legend {
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding: 15rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 16rpx;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.legend-color {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
}

.legend-text {
  color: #4a5568;
  font-weight: 600;
  font-size: 20rpx;
}

/* AI建议卡片 */
.ai-suggestions-card {
  padding: 30rpx;
  overflow: hidden;
}

.suggestions-content {
  display: flex;
  flex-direction: column;
  gap: 25rpx;
  position: relative;
  z-index: 2;
}

.suggestion-category {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20rpx;
  padding: 25rpx;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.category-header {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 20rpx;
}

.category-icon {
  font-size: 28rpx;
}

.category-title {
  color: #2d3748;
  font-weight: 700;
  font-size: 28rpx;
  flex: 1;
}

.category-priority {
  border-radius: 20rpx;
  padding: 6rpx 12rpx;
}

.priority-high {
  background: rgba(239, 68, 68, 0.2);
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.priority-medium {
  background: rgba(245, 158, 11, 0.2);
  border: 1px solid rgba(245, 158, 11, 0.3);
}

.priority-low {
  background: rgba(16, 185, 129, 0.2);
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.priority-text {
  font-weight: 700;
  font-size: 22rpx;
}

.priority-high .priority-text {
  color: #dc2626;
}

.priority-medium .priority-text {
  color: #d97706;
}

.priority-low .priority-text {
  color: #059669;
}

.category-suggestions {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.suggestion-item {
  display: flex;
  align-items: flex-start;
  gap: 20rpx;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 16rpx;
  padding: 20rpx;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.suggestion-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10rpx;
}

.suggestion-title {
  color: #2d3748;
  font-weight: 700;
  font-size: 26rpx;
}

.suggestion-description {
  color: #4a5568;
  font-weight: 500;
  font-size: 24rpx;
  line-height: 1.5;
}

.suggestion-benefits {
  margin-top: 10rpx;
}

.benefits-title {
  color: #667eea;
  font-weight: 700;
  font-size: 22rpx;
  margin-bottom: 5rpx;
}

.benefits-text {
  color: #4a5568;
  font-weight: 500;
  font-size: 22rpx;
  line-height: 1.4;
}

.suggestion-action {
  display: flex;
  align-items: center;
}

.action-btn {
  background: var(--primary-gradient);
  color: white;
  border: none;
  border-radius: 20rpx;
  padding: 12rpx 20rpx;
  font-weight: 700;
  font-size: 22rpx;
  box-shadow: 0 4rpx 12rpx rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
  min-width: 80rpx;
}

.action-btn:active {
  transform: scale(0.95);
  box-shadow: 0 2rpx 8rpx rgba(102, 126, 234, 0.4);
}

.action-text {
  font-size: 22rpx;
}
</style> 