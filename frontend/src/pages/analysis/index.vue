<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header" v-if="!isLoading">
      <view class="header-left">
        <text class="page-title">AI分析报告</text>
        <view class="analysis-status-section">
          <text class="analysis-status">✨ 智能分析完成</text>
          <view class="ai-status-badge" :class="{ 'ai-powered': analysisData?.ai_powered }">
            <text class="status-icon">{{ getAIStatusIcon(analysisData) }}</text>
            <text class="status-text">{{ getAIStatusText(analysisData) }}</text>
          </view>
        </view>
      </view>
      <view class="header-actions">
        <button class="header-btn" @click="saveAnalysis">
          <text class="btn-icon">💾</text>
          <text class="btn-text">保存</text>
        </button>
        <button class="header-btn" @click="reanalyze">
          <text class="btn-icon">🔄</text>
          <text class="btn-text">重新分析</text>
        </button>
      </view>
    </view>

    <!-- 加载状态 -->
    <view class="loading-section" v-if="isLoading">
      <view class="loading-animation">
        <view class="loading-dots">
          <view class="dot"></view>
          <view class="dot"></view>
          <view class="dot"></view>
        </view>
        <text class="loading-text">AI正在分析中...</text>
      </view>
    </view>

    <!-- 分析结果 -->
    <view class="analysis-content" v-else>
      <!-- 情绪概览卡片 -->
      <view class="emotion-overview">
        <view class="card-header">
          <text class="card-title">情绪分析</text>
          <text class="analysis-time">{{ formatTime(analysisData.timestamp) }}</text>
        </view>
        
        <view class="primary-emotion">
          <text class="emotion-icon">{{ analysisData.primaryEmotion.icon }}</text>
          <view class="emotion-details">
            <text class="emotion-name">{{ analysisData.primaryEmotion.name }}</text>
            <text class="emotion-confidence">置信度: {{ analysisData.primaryEmotion.confidence }}%</text>
          </view>
        </view>

        <view class="emotion-spectrum" v-if="analysisData.emotionSpectrum">
          <text class="spectrum-title">情绪光谱</text>
          <view class="spectrum-bars">
            <view 
              class="spectrum-item" 
              v-for="emotion in analysisData.emotionSpectrum" 
              :key="emotion.name"
            >
              <text class="spectrum-name">{{ emotion.name }}</text>
              <view class="spectrum-bar">
                <view 
                  class="spectrum-fill" 
                  :style="{ width: emotion.percentage + '%' }"
                ></view>
              </view>
              <text class="spectrum-value">{{ emotion.percentage }}%</text>
            </view>
          </view>
        </view>
      </view>

      <!-- AI洞察 -->
      <view class="ai-insights">
        <view class="card-header">
          <text class="card-title">AI洞察</text>
          <text class="ai-badge">✨ AI分析</text>
        </view>
        
        <view class="insight-item" v-for="insight in analysisData.insights" :key="insight.type">
          <view class="insight-header">
            <text class="insight-icon">{{ insight.icon }}</text>
            <text class="insight-title">{{ insight.title }}</text>
            <button class="insight-share-btn" @click="shareInsight(insight)">
              <text class="share-icon">📋</text>
            </button>
          </view>
          <text class="insight-content">{{ insight.content }}</text>
          <view class="insight-actions" v-if="insight.actionable">
            <button class="insight-action-btn" @click="applyInsight(insight)">
              应用建议
            </button>
          </view>
        </view>
      </view>

      <!-- 个性化建议 -->
      <view class="suggestions">
        <view class="card-header">
          <text class="card-title">个性化建议</text>
        </view>
        
        <view class="suggestion-tabs">
          <view 
            class="tab-item" 
            v-for="(tab, index) in suggestionTabs" 
            :key="tab.type"
            :class="{ active: activeTab === index }"
            @click="switchTab(index)"
          >
            <text class="tab-icon">{{ tab.icon }}</text>
            <text class="tab-text">{{ tab.title }}</text>
          </view>
        </view>

        <view class="suggestion-content">
          <view 
            class="suggestion-item" 
            v-for="suggestion in currentSuggestions" 
            :key="suggestion.id"
          >
            <view class="suggestion-header">
              <text class="suggestion-title">{{ suggestion.title }}</text>
              <text class="difficulty-tag" :class="suggestion.difficulty">
                {{ getDifficultyLabel(suggestion.difficulty) }}
              </text>
            </view>
            <text class="suggestion-desc">{{ suggestion.description }}</text>
            <view class="suggestion-actions">
              <button 
                class="action-btn primary" 
                @click="applySuggestion(suggestion)"
              >
                试试看
              </button>
              <button 
                class="action-btn secondary" 
                @click="saveSuggestion(suggestion)"
              >
                收藏
              </button>
              <button 
                class="action-btn tertiary" 
                @click="viewDetailedSuggestion(suggestion)"
              >
                详情
              </button>
            </view>
          </view>
        </view>
      </view>

      <!-- 情绪趋势 -->
      <view class="emotion-trend" v-if="analysisData.trend">
        <view class="card-header">
          <text class="card-title">情绪趋势</text>
          <text class="trend-period">近7天</text>
        </view>
        
        <view class="trend-chart">
          <canvas 
            canvas-id="trendChart" 
            class="chart-canvas"
            @touchstart="onChartTouch"
          ></canvas>
        </view>
        
        <view class="trend-summary">
          <view class="trend-item">
            <text class="trend-label">平均情绪</text>
            <text class="trend-value">{{ analysisData.trend.average }}/10</text>
          </view>
          <view class="trend-item">
            <text class="trend-label">波动程度</text>
            <text class="trend-value">{{ analysisData.trend.volatility }}</text>
          </view>
          <view class="trend-item">
            <text class="trend-label">改善趋势</text>
            <text class="trend-value" :class="getTrendClass(analysisData.trend.direction)">
              {{ getTrendDirection(analysisData.trend.direction) }}
            </text>
          </view>
        </view>
      </view>

      <!-- 深度分析结果 -->
      <view class="deep-analysis" v-if="analysisData.deepAnalysis">
        <view class="card-header">
          <text class="card-title">深度分析</text>
          <text class="analysis-score">分析得分: {{ analysisData.deepAnalysis.score }}/100</text>
        </view>
        
        <view class="analysis-dimensions">
          <view 
            class="dimension-item" 
            v-for="dimension in analysisData.deepAnalysis.dimensions" 
            :key="dimension.name"
          >
            <view class="dimension-header">
              <text class="dimension-name">{{ dimension.name }}</text>
              <text class="dimension-score">{{ dimension.score }}/10</text>
            </view>
            <view class="dimension-bar">
              <view 
                class="dimension-fill" 
                :style="{ width: (dimension.score / 10 * 100) + '%' }"
              ></view>
            </view>
            <text class="dimension-desc">{{ dimension.description }}</text>
          </view>
        </view>
      </view>

      <!-- 行动计划 -->
      <view class="action-plan">
        <view class="card-header">
          <text class="card-title">行动计划</text>
          <text class="plan-duration">7天计划</text>
        </view>
        
        <view class="plan-timeline">
          <view 
            class="timeline-item" 
            v-for="(day, index) in analysisData.actionPlan" 
            :key="index"
          >
            <view class="timeline-dot" :class="{ completed: day.completed }"></view>
            <view class="timeline-content">
              <text class="timeline-date">第{{ index + 1 }}天</text>
              <text class="timeline-title">{{ day.title }}</text>
              <text class="timeline-desc">{{ day.description }}</text>
              <view class="timeline-actions" v-if="!day.completed">
                <button class="complete-btn" @click="completeTask(index)">
                  完成
                </button>
              </view>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 底部操作 -->
    <view class="bottom-actions" v-if="!isLoading">
      <button class="action-button secondary" @click="shareAnalysis">
        分享分析
      </button>
      <button class="action-button primary" @click="newRecord">
        新的记录
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { aiAPI, emotionAPI, getToken, getUser } from '../../utils/api'

// 类型定义
interface EmotionSpectrum {
  name: string
  percentage: number
}

interface Insight {
  type: string
  icon: string
  title: string
  content: string
  actionable?: boolean
}

interface Suggestion {
  id: number
  title: string
  description: string
  difficulty: 'easy' | 'medium' | 'hard'
}

interface ActionPlanItem {
  title: string
  description: string
  completed: boolean
}

interface AnalysisData {
  timestamp?: number
  primaryEmotion?: {
    name: string
    icon: string
    confidence: number
  }
  emotionSpectrum?: EmotionSpectrum[]
  insights?: Insight[]
  suggestions?: {
    immediate?: Suggestion[]
    longterm?: Suggestion[]
    lifestyle?: Suggestion[]
    social?: Suggestion[]
  }
  trend?: {
    average: number
    volatility: string
    direction: string
  }
  deepAnalysis?: {
    score: number
    dimensions: Array<{
      name: string
      score: number
      description: string
    }>
  }
  actionPlan?: ActionPlanItem[]
  ai_powered?: boolean
}

// 响应式数据
const isLoading = ref(true)
const activeTab = ref(0)
const analysisData = ref<AnalysisData>({})

// 建议标签页
const suggestionTabs = ref([
  { type: 'immediate', title: '即时缓解', icon: '⚡' },
  { type: 'longterm', title: '长期改善', icon: '🎯' },
  { type: 'lifestyle', title: '生活方式', icon: '🌱' },
  { type: 'social', title: '社交支持', icon: '👥' }
])

// 计算当前建议
const currentSuggestions = computed(() => {
  if (!analysisData.value.suggestions) return []
  const currentType = suggestionTabs.value[activeTab.value].type as keyof typeof analysisData.value.suggestions
  return analysisData.value.suggestions[currentType] || []
})

// 方法
const formatTime = (timestamp: string | number) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  return date.toLocaleString('zh-CN', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const switchTab = (index: number) => {
  activeTab.value = index
}

const getDifficultyLabel = (difficulty: string) => {
  const difficultyMap: Record<string, string> = {
    'easy': '容易',
    'medium': '中等',
    'hard': '困难'
  }
  return difficultyMap[difficulty] || '中等'
}

const getTrendClass = (direction: string) => {
  if (direction === '上升') return 'trend-up'
  if (direction === '下降') return 'trend-down'
  return 'trend-stable'
}

const getTrendDirection = (direction: string) => {
  return direction || '稳定'
}

const getAIStatusIcon = (data: AnalysisData) => {
  return data?.ai_powered ? '🤖' : '📊'
}

const getAIStatusText = (data: AnalysisData) => {
  return data?.ai_powered ? 'AI驱动' : '数据分析'
}

const applySuggestion = (suggestion: Suggestion) => {
  uni.showModal({
    title: '应用建议',
    content: `确定要将"${suggestion.title}"添加到今日计划吗？`,
    success: (res) => {
      if (res.confirm) {
        uni.showToast({
          title: '已添加到计划',
          icon: 'success'
        })
      }
    }
  })
}

const saveSuggestion = (suggestion: Suggestion) => {
  uni.showToast({
    title: '已收藏',
    icon: 'success'
  })
}

const completeTask = (index: number) => {
  if (analysisData.value.actionPlan && analysisData.value.actionPlan[index]) {
    analysisData.value.actionPlan[index].completed = true
    uni.showToast({
      title: '任务完成！',
      icon: 'success'
    })
  }
}

const shareAnalysis = () => {
  uni.share({
    provider: 'weixin',
    type: 0,
    title: '我的情绪分析报告',
    summary: '通过AI分析，我对自己的情绪有了更深的了解',
    success: () => {
      uni.showToast({
        title: '分享成功',
        icon: 'success'
      })
    }
  })
}

const newRecord = () => {
  uni.switchTab({
    url: '/pages/record/index'
  })
}

// 重新分析
const reanalyze = async () => {
  uni.showModal({
    title: '重新分析',
    content: '将基于最新的情绪记录重新进行AI分析，是否继续？',
    success: async (res) => {
      if (res.confirm) {
        await fetchAnalysisData()
      }
    }
  })
}

// 保存分析结果
const saveAnalysis = async () => {
  try {
    const analysisResult = {
      analysis_data: analysisData.value,
      created_at: new Date().toISOString(),
      analysis_type: 'comprehensive'
    }
    
    // 这里可以调用保存分析结果的API
    // await aiAPI.saveAnalysis(analysisResult)
    
    uni.setStorageSync('latest_analysis', analysisResult)
    
    uni.showToast({
      title: '分析结果已保存',
      icon: 'success'
    })
  } catch (error) {
    console.error('保存分析结果失败:', error)
    uni.showToast({
      title: '保存失败',
      icon: 'none'
    })
  }
}

// 查看详细建议
const viewDetailedSuggestion = (suggestion: any) => {
  uni.showModal({
    title: suggestion.title,
    content: `${suggestion.description}\n\n难度：${getDifficultyLabel(suggestion.difficulty)}\n\n是否要将此建议添加到今日计划中？`,
    confirmText: '添加',
    cancelText: '取消',
    success: (res) => {
      if (res.confirm) {
        applySuggestion(suggestion)
      }
    }
  })
}

// 分享洞察
const shareInsight = (suggestion: any) => {
  uni.setClipboardData({
    data: `AI洞察: ${suggestion.content}`,
    success: () => {
      uni.showToast({
        title: '已复制到剪贴板',
        icon: 'success'
      })
    }
  })
}

// 应用洞察建议
const applyInsight = (insight: any) => {
  uni.showToast({
    title: '已添加到行动计划',
    icon: 'success'
  })
  
  // 可以将洞察转化为具体的行动项
  const actionItem = {
    title: `实践：${insight.title}`,
    description: insight.content,
    completed: false
  }
  
  if (analysisData.value.actionPlan) {
    analysisData.value.actionPlan.push(actionItem)
  }
}

const onChartTouch = (e: any) => {
  // 图表交互逻辑
  console.log('图表触摸事件', e)
}

// 模拟AI分析数据
const mockAnalysisData = (): AnalysisData => {
  return {
    timestamp: Date.now(),
    primaryEmotion: {
      name: '焦虑',
      icon: '😟',
      confidence: 85
    },
    emotionSpectrum: [
      { name: '焦虑', percentage: 45 },
      { name: '担心', percentage: 30 },
      { name: '紧张', percentage: 15 },
      { name: '不安', percentage: 10 }
    ],
    insights: [
      {
        type: 'pattern',
        icon: '🔍',
        title: '情绪模式识别',
        content: '你的焦虑情绪主要出现在工作场景中，特别是面对截止日期时。这是一种常见的适应性焦虑，说明你对工作很负责。'
      },
      {
        type: 'trigger',
        icon: '⚡',
        title: '触发因素分析',
        content: '分析显示，时间压力和完美主义倾向是你焦虑的主要触发因素。建议学习时间管理技巧和接受"足够好"的标准。'
      },
      {
        type: 'strength',
        icon: '💪',
        title: '情绪优势',
        content: '你具有很好的情绪觉察能力，能够准确识别和描述自己的感受。这是情绪管理的重要基础。'
      }
    ],
    suggestions: {
      immediate: [
        {
          id: 1,
          title: '4-7-8呼吸法',
          description: '吸气4秒，屏气7秒，呼气8秒。重复3-4次可快速缓解焦虑。',
          difficulty: 'easy' as const
        },
        {
          id: 2,
          title: '5-4-3-2-1接地技巧',
          description: '说出5个看到的、4个听到的、3个摸到的、2个闻到的、1个尝到的。',
          difficulty: 'easy' as const
        }
      ],
      longterm: [
        {
          id: 3,
          title: '认知重构练习',
          description: '识别并挑战消极思维模式，用更平衡的想法替代。',
          difficulty: 'medium' as const
        },
        {
          id: 4,
          title: '正念冥想',
          description: '每天10-15分钟的正念练习，提高情绪调节能力。',
          difficulty: 'medium' as const
        }
      ],
      lifestyle: [
        {
          id: 5,
          title: '规律运动',
          description: '每周3-4次有氧运动，每次30分钟，有助于缓解焦虑。',
          difficulty: 'medium' as const
        },
        {
          id: 6,
          title: '睡眠优化',
          description: '建立规律的睡眠时间，创造良好的睡眠环境。',
          difficulty: 'hard' as const
        }
      ],
      social: [
        {
          id: 7,
          title: '寻求支持',
          description: '与信任的朋友或家人分享你的感受，获得情感支持。',
          difficulty: 'medium' as const
        },
        {
          id: 8,
          title: '专业咨询',
          description: '如果焦虑持续影响生活，考虑寻求专业心理咨询师的帮助。',
          difficulty: 'hard' as const
        }
      ]
    },
    trend: {
      average: 6.5,
      volatility: '中等',
      direction: '稳定'
    },
    deepAnalysis: {
      score: 78,
      dimensions: [
        { name: '情绪觉察', score: 8, description: '能够准确识别自己的情绪状态' },
        { name: '应对策略', score: 6, description: '具备一定的情绪调节技巧，但需要加强' },
        { name: '社会支持', score: 7, description: '拥有良好的社会支持网络' },
        { name: '生活平衡', score: 5, description: '工作与生活平衡需要改善' }
      ]
    },
    actionPlan: [
      { title: '练习深呼吸', description: '每天早晨练习5分钟深呼吸', completed: false },
      { title: '记录触发因素', description: '观察并记录引起焦虑的具体情况', completed: false },
      { title: '尝试正念练习', description: '下载冥想App，尝试10分钟正念练习', completed: false },
      { title: '制定时间计划', description: '为重要任务制定详细的时间计划', completed: false },
      { title: '与朋友交流', description: '主动与一位朋友分享近期的感受', completed: false },
      { title: '评估进展', description: '回顾本周的情绪变化和应对效果', completed: false },
      { title: '调整策略', description: '根据一周的实践调整应对策略', completed: false }
    ]
  }
}

// 获取AI分析数据
const fetchAnalysisData = async (recordId?: string) => {
  try {
    const token = getToken()
    if (!token) {
      uni.showToast({
        title: '请先登录',
        icon: 'none'
      })
      uni.navigateTo({
        url: '/pages/login/index'
      })
      return
    }

    isLoading.value = true

    // 获取最近的情绪记录
    let records = []
    if (recordId) {
      // 如果有指定记录ID，获取特定记录
      const recordResponse = await emotionAPI.getRecordById(recordId)
      records = [recordResponse]
    } else {
      // 获取最近的记录用于分析
      const recentResponse = await emotionAPI.getRecentRecords()
      records = recentResponse.results || recentResponse
    }

    if (!records || records.length === 0) {
      uni.showModal({
        title: '暂无数据',
        content: '还没有情绪记录，请先记录一些情绪数据',
        success: (res) => {
          if (res.confirm) {
            uni.switchTab({
              url: '/pages/record/index'
            })
          }
        }
      })
      isLoading.value = false
      return
    }

    // 调用AI分析API
    const analysisRequest = {
      emotion_records: records.map((r: any) => r.id),
      analysis_type: 'comprehensive',
      include_suggestions: true,
      include_trend: true
    }

    const aiResponse = await aiAPI.requestAnalysis(analysisRequest)
    
    // 处理AI响应数据
    analysisData.value = processAIResponse(aiResponse, records)
    isLoading.value = false

  } catch (error) {
    console.error('获取分析数据失败:', error)
    isLoading.value = false
    
    // 如果API失败，使用模拟数据
    uni.showToast({
      title: 'AI分析服务暂时不可用，显示示例数据',
      icon: 'none',
      duration: 3000
    })
    
    setTimeout(() => {
      analysisData.value = mockAnalysisData()
    }, 1000)
  }
}

// 处理AI响应数据
const processAIResponse = (aiResponse: any, records: any[]) => {
  const latestRecord = records[0]
  
  return {
    timestamp: Date.now(),
    recordId: latestRecord.id,
    primaryEmotion: {
      name: getEmotionName(latestRecord.emotion_type),
      icon: getEmotionIcon(latestRecord.emotion_type),
      confidence: aiResponse.confidence || 85
    },
    emotionSpectrum: generateEmotionSpectrum(latestRecord, aiResponse),
    insights: parseInsights(aiResponse.insights || []),
    suggestions: parseSuggestions(aiResponse.suggestions || {}),
    trend: parseTrend(aiResponse.trend || {}),
    deepAnalysis: parseDeepAnalysis(aiResponse.deep_analysis || {}),
    actionPlan: parseActionPlan(aiResponse.action_plan || [])
  }
}

// 辅助函数：获取情绪中文名称
const getEmotionName = (emotionType: string): string => {
  const emotionMap: Record<string, string> = {
    'happy': '快乐',
    'sad': '悲伤',
    'angry': '愤怒',
    'anxious': '焦虑',
    'calm': '平静',
    'fearful': '恐惧'
  }
  return emotionMap[emotionType] || '未知'
}

// 辅助函数：获取情绪图标
const getEmotionIcon = (emotionType: string): string => {
  const iconMap: Record<string, string> = {
    'happy': '😄',
    'sad': '😢',
    'angry': '😡',
    'anxious': '😟',
    'calm': '😌',
    'fearful': '😨'
  }
  return iconMap[emotionType] || '😐'
}

// 生成情绪光谱数据
const generateEmotionSpectrum = (record: any, aiResponse: any) => {
  const spectrum = aiResponse.emotion_spectrum || []
  if (spectrum.length > 0) {
    return spectrum.map((item: any) => ({
      name: getEmotionName(item.emotion),
      percentage: Math.round(item.confidence * 100)
    }))
  }
  
  // 如果AI没有返回光谱数据，基于记录生成
  const intensity = record.intensity || 5
  const mainEmotion = getEmotionName(record.emotion_type)
  
  return [
    { name: mainEmotion, percentage: intensity * 10 },
    { name: '中性', percentage: Math.max(0, 100 - intensity * 10) }
  ]
}

// 解析AI洞察
const parseInsights = (insights: any[]) => {
  if (insights.length === 0) {
    return [
      {
        type: 'pattern',
        icon: '🔍',
        title: '情绪模式识别',
        content: '正在分析您的情绪模式，请多记录几次以获得更准确的分析。'
      }
    ]
  }
  
  return insights.map((insight: any) => ({
    type: insight.type || 'general',
    icon: getInsightIcon(insight.type),
    title: insight.title || 'AI洞察',
    content: insight.content || insight.description || ''
  }))
}

// 获取洞察图标
const getInsightIcon = (type: string): string => {
  const iconMap: Record<string, string> = {
    'pattern': '🔍',
    'trigger': '⚡',
    'strength': '💪',
    'recommendation': '💡',
    'trend': '📈',
    'warning': '⚠️'
  }
  return iconMap[type] || '💭'
}

// 解析建议数据
const parseSuggestions = (suggestions: any) => {
  const defaultSuggestions = {
    immediate: [
      {
        id: 1,
        title: '深呼吸练习',
        description: '进行3-5次深呼吸，帮助快速缓解紧张情绪。',
        difficulty: 'easy'
      }
    ],
    longterm: [
      {
        id: 2,
        title: '情绪日记',
        description: '坚持记录情绪变化，提高情绪觉察能力。',
        difficulty: 'medium'
      }
    ],
    lifestyle: [
      {
        id: 3,
        title: '规律作息',
        description: '保持规律的睡眠和饮食习惯。',
        difficulty: 'medium'
      }
    ],
    social: [
      {
        id: 4,
        title: '寻求支持',
        description: '与信任的人分享你的感受。',
        difficulty: 'easy'
      }
    ]
  }
  
  return {
    immediate: suggestions.immediate || defaultSuggestions.immediate,
    longterm: suggestions.longterm || defaultSuggestions.longterm,
    lifestyle: suggestions.lifestyle || defaultSuggestions.lifestyle,
    social: suggestions.social || defaultSuggestions.social
  }
}

// 解析趋势数据
const parseTrend = (trend: any) => {
  return {
    average: trend.average || 5.0,
    volatility: trend.volatility || '中等',
    direction: trend.direction || '稳定'
  }
}

// 解析深度分析数据
const parseDeepAnalysis = (deepAnalysis: any) => {
  return {
    score: deepAnalysis.score || 70,
    dimensions: deepAnalysis.dimensions || [
      { name: '情绪觉察', score: 7, description: '能够识别自己的情绪状态' },
      { name: '应对策略', score: 6, description: '具备基本的情绪调节能力' }
    ]
  }
}

// 解析行动计划
const parseActionPlan = (actionPlan: any[]) => {
  if (actionPlan.length === 0) {
    return [
      { title: '记录情绪', description: '每天记录一次情绪状态', completed: false },
      { title: '练习放松', description: '尝试深呼吸或冥想', completed: false },
      { title: '评估进展', description: '回顾一周的情绪变化', completed: false }
    ]
  }
  
  return actionPlan.map((plan: any) => ({
    title: plan.title || plan.name || '',
    description: plan.description || '',
    completed: plan.completed || false
  }))
}

// 获取建议优先级标签
const getPriorityLabel = (index: number) => {
  const labels = ['高优先级', '中优先级', '低优先级']
  return labels[index] || '建议'
}

// 生命周期
onMounted(() => {
  // 获取页面参数
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage.options || {}
  
  // 如果有recordId参数，分析特定记录
  const recordId = options.recordId
  
  fetchAnalysisData(recordId)
})
</script>

<style scoped>
/* CSS变量定义 */
:root {
  --primary-color: #667eea;
  --secondary-color: #764ba2;
  --success-color: #4CAF50;
  --warning-color: #FF9800;
  --error-color: #F44336;
  --text-primary: #2c3e50;
  --text-secondary: #6c757d;
  --background-color: #f8f9fa;
  --border-color: #e9ecef;
  --card-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.12);
  --card-shadow-hover: 0 12rpx 40rpx rgba(0, 0, 0, 0.18);
}

/* 全局容器 */
.container {
  padding: 20rpx;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
}

/* 页面头部优化 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx 25rpx;
  margin-bottom: 30rpx;
  background: white;
  border-radius: 25rpx;
  box-shadow: var(--card-shadow);
  border: 1rpx solid rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10rpx);
}

.header-left {
  display: flex;
  flex-direction: column;
}

.page-title {
  font-size: 38rpx;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 8rpx;
}

.analysis-status-section {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.analysis-status {
  font-size: 26rpx;
  color: var(--primary-color);
  font-weight: 500;
}

.ai-status-badge {
  display: flex;
  align-items: center;
  gap: 10rpx;
  padding: 12rpx 20rpx;
  border-radius: 25rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 6rpx 20rpx rgba(102, 126, 234, 0.3);
  transform: translateY(0);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.ai-status-badge:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.4);
}

.ai-status-badge .status-icon {
  font-size: 26rpx;
  animation: pulse 2s infinite;
}

.ai-status-badge .status-text {
  font-size: 22rpx;
  color: #ffffff;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 15rpx;
}

.header-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 18rpx 25rpx;
  background: white;
  border: 2rpx solid var(--border-color);
  border-radius: 20rpx;
  min-width: 110rpx;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.08);
}

.header-btn:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 6rpx 20rpx rgba(0, 0, 0, 0.15);
  border-color: var(--primary-color);
}

.btn-icon {
  font-size: 26rpx;
  margin-bottom: 6rpx;
  transition: transform 0.3s ease;
}

.header-btn:hover .btn-icon {
  transform: scale(1.1);
}

.btn-text {
  font-size: 22rpx;
  color: var(--text-secondary);
  font-weight: 500;
}

/* 加载动画优化 */
.loading-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 25rpx;
  margin: 20rpx;
  color: white;
  position: relative;
  overflow: hidden;
}

.loading-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  animation: shimmer 2s infinite;
}

.loading-animation {
  display: flex;
  flex-direction: column;
  align-items: center;
  z-index: 1;
}

.loading-dots {
  display: flex;
  gap: 8rpx;
  margin-bottom: 30rpx;
}

.dot {
  width: 12rpx;
  height: 12rpx;
  background: white;
  border-radius: 50%;
  animation: bounce 1.4s infinite ease-in-out both;
}

.dot:nth-child(1) { animation-delay: -0.32s; }
.dot:nth-child(2) { animation-delay: -0.16s; }
.dot:nth-child(3) { animation-delay: 0s; }

.loading-text {
  font-size: 30rpx;
  color: white;
  font-weight: 500;
  opacity: 0.95;
  animation: fadeInOut 2s infinite;
}

/* 分析内容卡片优化 */
.analysis-content > view {
  background: white;
  border-radius: 25rpx;
  padding: 35rpx;
  margin-bottom: 30rpx;
  box-shadow: var(--card-shadow);
  border: 1rpx solid rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10rpx);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.analysis-content > view::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
}

.analysis-content > view:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--card-shadow-hover);
}

/* 卡片标题优化 */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25rpx;
  padding-bottom: 15rpx;
  border-bottom: 2rpx solid #f8f9fa;
}

.card-title {
  font-size: 32rpx;
  font-weight: 700;
  color: var(--text-primary);
  position: relative;
}

.card-title::after {
  content: '';
  position: absolute;
  bottom: -8rpx;
  left: 0;
  width: 40rpx;
  height: 3rpx;
  background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
  border-radius: 2rpx;
}

.analysis-time {
  font-size: 22rpx;
  color: var(--text-secondary);
  background: #f8f9fa;
  padding: 8rpx 15rpx;
  border-radius: 15rpx;
}

.ai-badge {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 8rpx 15rpx;
  border-radius: 15rpx;
  font-size: 20rpx;
  font-weight: 600;
  box-shadow: 0 4rpx 12rpx rgba(102, 126, 234, 0.3);
}

/* 情绪概览优化 */
.primary-emotion {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 25rpx;
  background: linear-gradient(135deg, #f8f9ff 0%, #e8f4fd 100%);
  border-radius: 20rpx;
  margin-bottom: 25rpx;
  border: 2rpx solid rgba(102, 126, 234, 0.1);
}

.emotion-icon {
  font-size: 60rpx;
  animation: emotionPulse 3s infinite;
}

.emotion-details {
  flex: 1;
}

.emotion-name {
  font-size: 38rpx;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 8rpx;
}

.emotion-confidence {
  font-size: 26rpx;
  color: var(--text-secondary);
  font-weight: 500;
}

/* 情绪光谱优化 */
.emotion-spectrum {
  margin-top: 30rpx;
}

.spectrum-title {
  font-size: 28rpx;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 25rpx;
  display: block;
}

.spectrum-bars {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.spectrum-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 15rpx;
  background: #f8f9fa;
  border-radius: 15rpx;
  transition: all 0.3s ease;
}

.spectrum-item:hover {
  background: #e9ecef;
  transform: translateX(5rpx);
}

.spectrum-name {
  min-width: 100rpx;
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 600;
}

.spectrum-bar {
  flex: 1;
  height: 24rpx;
  background: #e9ecef;
  border-radius: 12rpx;
  overflow: hidden;
  position: relative;
}

.spectrum-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
  border-radius: 12rpx;
  transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.spectrum-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  animation: shimmer 2s infinite;
}

.spectrum-value {
  min-width: 70rpx;
  text-align: right;
  font-size: 24rpx;
  color: var(--primary-color);
  font-weight: 600;
}

/* AI洞察优化 */
.insight-item {
  margin-bottom: 25rpx;
  padding: 25rpx;
  background: linear-gradient(135deg, #f8f9ff 0%, #fff8f0 100%);
  border-radius: 20rpx;
  border: 2rpx solid rgba(102, 126, 234, 0.1);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.insight-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4rpx;
  height: 100%;
  background: linear-gradient(180deg, var(--primary-color), var(--secondary-color));
}

.insight-item:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.15);
  border-color: var(--primary-color);
}

.insight-item:last-child {
  margin-bottom: 0;
}

.insight-header {
  display: flex;
  align-items: center;
  margin-bottom: 15rpx;
}

.insight-icon {
  font-size: 32rpx;
  margin-right: 15rpx;
  animation: iconFloat 3s ease-in-out infinite;
}

.insight-title {
  font-size: 30rpx;
  font-weight: 700;
  color: var(--text-primary);
  flex: 1;
}

.insight-content {
  font-size: 26rpx;
  line-height: 1.7;
  color: var(--text-secondary);
  padding-left: 47rpx;
}

/* 建议系统优化 */
.suggestion-tabs {
  display: flex;
  margin-bottom: 30rpx;
  background: white;
  border-radius: 20rpx;
  padding: 10rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.08);
  border: 2rpx solid #f0f0f0;
}

.tab-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 18rpx 15rpx;
  border-radius: 15rpx;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
}

.tab-item.active {
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  box-shadow: 0 6rpx 20rpx rgba(102, 126, 234, 0.3);
  transform: translateY(-2rpx);
}

.tab-icon {
  font-size: 26rpx;
  margin-bottom: 8rpx;
  transition: transform 0.3s ease;
}

.tab-item.active .tab-icon {
  transform: scale(1.1);
}

.tab-text {
  font-size: 22rpx;
  color: var(--text-secondary);
  font-weight: 500;
  transition: all 0.3s ease;
}

.tab-item.active .tab-text {
  color: white;
  font-weight: 700;
}

.suggestion-content {
  display: flex;
  flex-direction: column;
  gap: 25rpx;
}

.suggestion-item {
  padding: 30rpx;
  border: 2rpx solid #f0f0f0;
  border-radius: 20rpx;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: white;
  position: relative;
  overflow: hidden;
}

.suggestion-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: linear-gradient(90deg, transparent, var(--primary-color), transparent);
  transform: translateX(-100%);
  transition: transform 0.3s ease;
}

.suggestion-item:hover {
  border-color: var(--primary-color);
  transform: translateY(-3rpx);
  box-shadow: 0 10rpx 30rpx rgba(102, 126, 234, 0.15);
}

.suggestion-item:hover::before {
  transform: translateX(0);
}

.suggestion-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15rpx;
}

.suggestion-title {
  font-size: 30rpx;
  font-weight: 700;
  color: var(--text-primary);
}

.difficulty-tag {
  padding: 8rpx 16rpx;
  border-radius: 25rpx;
  font-size: 20rpx;
  color: white;
  font-weight: 600;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.15);
}

.difficulty-tag.easy {
  background: linear-gradient(135deg, #4CAF50, #45a049);
}

.difficulty-tag.medium {
  background: linear-gradient(135deg, #FF9800, #f57c00);
}

.difficulty-tag.hard {
  background: linear-gradient(135deg, #F44336, #d32f2f);
}

.suggestion-desc {
  font-size: 26rpx;
  line-height: 1.7;
  color: var(--text-secondary);
  margin-bottom: 25rpx;
}

.suggestion-actions {
  display: flex;
  gap: 15rpx;
}

.action-btn {
  flex: 1;
  height: 70rpx;
  border-radius: 20rpx;
  font-size: 26rpx;
  font-weight: 600;
  border: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.action-btn::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  transition: all 0.6s ease;
  transform: translate(-50%, -50%);
}

.action-btn:active::before {
  width: 300rpx;
  height: 300rpx;
}

.action-btn.primary {
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  color: white;
  box-shadow: 0 6rpx 20rpx rgba(102, 126, 234, 0.3);
}

.action-btn.primary:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.4);
}

.action-btn.secondary {
  background: white;
  color: var(--primary-color);
  border: 2rpx solid var(--primary-color);
  box-shadow: 0 4rpx 15rpx rgba(102, 126, 234, 0.1);
}

.action-btn.secondary:hover {
  background: var(--primary-color);
  color: white;
  transform: translateY(-2rpx);
}

.action-btn.tertiary {
  background: linear-gradient(135deg, #fff8e1, #ffecb3);
  color: #f57c00;
  border: 2rpx solid #f57c00;
  flex: 0.8;
}

.action-btn.tertiary:hover {
  background: #f57c00;
  color: white;
  transform: translateY(-2rpx);
}

/* 分享和操作按钮优化 */
.insight-share-btn {
  margin-left: auto;
  padding: 10rpx 16rpx;
  background: linear-gradient(135deg, #f0f8ff, #e3f2fd);
  border: 2rpx solid var(--primary-color);
  border-radius: 25rpx;
  transition: all 0.3s ease;
}

.insight-share-btn:hover {
  background: var(--primary-color);
  transform: scale(1.05);
}

.insight-share-btn:hover .share-icon {
  color: white;
}

.share-icon {
  font-size: 22rpx;
  color: var(--primary-color);
  transition: color 0.3s ease;
}

.insight-actions {
  margin-top: 20rpx;
  display: flex;
  justify-content: flex-end;
}

.insight-action-btn {
  padding: 12rpx 25rpx;
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  color: white;
  border: none;
  border-radius: 25rpx;
  font-size: 22rpx;
  font-weight: 600;
  box-shadow: 0 4rpx 15rpx rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.insight-action-btn:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 6rpx 20rpx rgba(102, 126, 234, 0.4);
}

/* 趋势图表优化 */
.trend-chart {
  margin: 25rpx 0;
  padding: 20rpx;
  background: linear-gradient(135deg, #f8f9ff, #e8f4fd);
  border-radius: 20rpx;
  border: 2rpx solid rgba(102, 126, 234, 0.1);
}

.chart-canvas {
  width: 100%;
  height: 300rpx;
  border-radius: 15rpx;
}

.trend-summary {
  display: flex;
  justify-content: space-around;
  margin-top: 25rpx;
  padding: 20rpx;
  background: white;
  border-radius: 15rpx;
  box-shadow: 0 4rpx 15rpx rgba(0, 0, 0, 0.05);
}

.trend-item {
  text-align: center;
}

.trend-label {
  font-size: 22rpx;
  color: var(--text-secondary);
  display: block;
  margin-bottom: 8rpx;
}

.trend-value {
  font-size: 28rpx;
  font-weight: 700;
  color: var(--text-primary);
}

.trend-up {
  color: var(--success-color);
}

.trend-down {
  color: var(--error-color);
}

.trend-stable {
  color: var(--warning-color);
}

/* 底部操作区优化 */
.bottom-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 25rpx;
  display: flex;
  gap: 20rpx;
  box-shadow: 0 -8rpx 32rpx rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(10rpx);
  border-top: 1rpx solid rgba(0, 0, 0, 0.05);
}

.action-button {
  flex: 1;
  height: 80rpx;
  border-radius: 20rpx;
  font-size: 28rpx;
  font-weight: 600;
  border: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.action-button.primary {
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  color: white;
  box-shadow: 0 6rpx 20rpx rgba(102, 126, 234, 0.3);
}

.action-button.primary:hover {
  transform: translateY(-2rpx);
  box-shadow: 0 8rpx 25rpx rgba(102, 126, 234, 0.4);
}

.action-button.secondary {
  background: white;
  color: var(--primary-color);
  border: 2rpx solid var(--primary-color);
  box-shadow: 0 4rpx 15rpx rgba(102, 126, 234, 0.1);
}

.action-button.secondary:hover {
  background: var(--primary-color);
  color: white;
  transform: translateY(-2rpx);
}

/* 动画定义 */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

@keyframes fadeInOut {
  0%, 100% { opacity: 0.7; }
  50% { opacity: 1; }
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

@keyframes emotionPulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

@keyframes iconFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-3rpx); }
}

/* 响应式优化 */
@media (max-width: 750rpx) {
  .page-header {
    flex-direction: column;
    gap: 20rpx;
    align-items: stretch;
  }
  
  .header-actions {
    justify-content: center;
    gap: 10rpx;
  }
  
  .header-btn {
    flex-direction: row;
    min-width: auto;
    padding: 15rpx 20rpx;
    flex: 1;
  }
  
  .btn-icon {
    margin-bottom: 0;
    margin-right: 8rpx;
  }
  
  .suggestion-actions {
    flex-direction: column;
    gap: 15rpx;
  }
  
  .action-btn {
    flex: none;
  }
  
  .primary-emotion {
    flex-direction: column;
    text-align: center;
    gap: 15rpx;
  }
  
  .spectrum-item {
    flex-direction: column;
    gap: 10rpx;
    align-items: stretch;
  }
  
  .spectrum-name {
    min-width: auto;
    text-align: center;
  }
  
  .spectrum-value {
    text-align: center;
  }
}

/* 深色模式支持 */
@media (prefers-color-scheme: dark) {
  :root {
    --text-primary: #ffffff;
    --text-secondary: #b0b0b0;
    --background-color: #1a1a1a;
    --border-color: #333333;
  }
  
  .container {
    background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
  }
  
  .analysis-content > view {
    background: #2d2d2d;
    border-color: #404040;
  }
  
  .insight-item {
    background: linear-gradient(135deg, #2d2d2d 0%, #3d3d3d 100%);
    border-color: #404040;
  }
  
  .suggestion-item {
    background: #2d2d2d;
    border-color: #404040;
  }
}
</style> 