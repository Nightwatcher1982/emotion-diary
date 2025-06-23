<template>
  <view class="container">
    <!-- 页面头部 -->
    <view class="page-header">
      <text class="page-title">情绪记录</text>
      <button class="draft-button" @click="saveDraft">
        <text class="draft-icon">💾</text>
        <text class="draft-text">保存草稿</text>
      </button>
    </view>

    <!-- 进度指示器 -->
    <view class="progress-bar">
      <view class="progress-step" :class="{ active: currentStep >= 1 }">
        <text class="step-number">1</text>
        <text class="step-text">描述</text>
      </view>
      <view class="progress-line" :class="{ active: currentStep >= 2 }"></view>
      <view class="progress-step" :class="{ active: currentStep >= 2 }">
        <text class="step-number">2</text>
        <text class="step-text">情绪</text>
      </view>
      <view class="progress-line" :class="{ active: currentStep >= 3 }"></view>
      <view class="progress-step" :class="{ active: currentStep >= 3 }">
        <text class="step-number">3</text>
        <text class="step-text">场景</text>
      </view>
      <view class="progress-line" :class="{ active: currentStep >= 4 }"></view>
      <view class="progress-step" :class="{ active: currentStep >= 4 }">
        <text class="step-number">4</text>
        <text class="step-text">详情</text>
      </view>
    </view>

    <!-- 步骤1: 文本输入 -->
    <view class="step-content" v-if="currentStep === 1">
      <view class="step-title">
        <text class="title">今天发生了什么？</text>
        <text class="subtitle">用文字记录下你的感受</text>
      </view>
      
      <view class="input-section">
        <textarea 
          class="diary-input" 
          v-model="formData.text"
          placeholder="今天发生了什么？一句话描述也可以..."
          maxlength="200"
          auto-height
          @input="onTextInput"
        />
        <view class="char-count">
          <text class="count">{{ formData.text.length }}</text>
          <text class="max">/200</text>
        </view>
      </view>

      <!-- 语音输入按钮 -->
      <view class="voice-input" @click="startVoiceInput">
        <text class="voice-icon">🎤</text>
        <text class="voice-text">语音输入</text>
      </view>

      <view class="step-actions">
        <button class="next-button" @click="nextStep" :disabled="!formData.text.trim()">
          下一步
        </button>
      </view>
    </view>

    <!-- 步骤2: 情绪选择 -->
    <view class="step-content" v-if="currentStep === 2">
      <view class="step-title">
        <text class="title">选择你的情绪</text>
        <text class="subtitle">可以选择多个情绪</text>
      </view>

      <view class="emotions-grid">
        <view 
          class="emotion-item" 
          v-for="emotion in emotions" 
          :key="emotion.name"
          :class="{ selected: formData.emotions.includes(emotion.name) }"
          @click="toggleEmotion(emotion.name)"
        >
          <text class="emotion-icon">{{ emotion.icon }}</text>
          <text class="emotion-name">{{ emotion.name }}</text>
          <view class="emotion-desc">{{ emotion.description }}</view>
        </view>
      </view>

      <!-- 情绪强度滑块 -->
      <view class="intensity-section" v-if="formData.emotions.length > 0">
        <view class="intensity-title">
          <text>情绪强度</text>
          <text class="intensity-value">{{ formData.intensity }}/10</text>
        </view>
        <slider 
          class="intensity-slider"
          :value="formData.intensity"
          @change="onIntensityChange"
          min="1" 
          max="10" 
          step="1"
          activeColor="#4A90E2"
          backgroundColor="#e0e0e0"
          block-size="20"
        />
        <view class="intensity-labels">
          <text class="label-left">轻微</text>
          <text class="label-right">强烈</text>
        </view>
      </view>

      <view class="step-actions">
        <button class="prev-button" @click="prevStep">上一步</button>
        <button class="next-button" @click="nextStep" :disabled="formData.emotions.length === 0">
          下一步
        </button>
      </view>
    </view>

    <!-- 步骤3: 场景选择 -->
    <view class="step-content" v-if="currentStep === 3">
      <view class="step-title">
        <text class="title">选择相关场景</text>
        <text class="subtitle">这有助于AI更好地分析</text>
      </view>

      <view class="scenes-list">
        <view 
          class="scene-item" 
          v-for="scene in scenes" 
          :key="scene.name"
          :class="{ selected: formData.scene === scene.name }"
          @click="selectScene(scene.name)"
        >
          <text class="scene-icon">{{ scene.icon }}</text>
          <view class="scene-info">
            <text class="scene-name">{{ scene.name }}</text>
            <text class="scene-desc">{{ scene.description }}</text>
          </view>
          <text class="check-icon" v-if="formData.scene === scene.name">✓</text>
        </view>
      </view>

      <!-- 深度分析开关 -->
      <view class="deep-analysis-section">
        <view class="analysis-header" @click="toggleDeepAnalysis">
          <view class="analysis-info">
            <text class="analysis-title">深度分析</text>
            <text class="analysis-desc">回答几个问题，获得更精准的AI建议</text>
          </view>
          <switch 
            :checked="formData.enableDeepAnalysis"
            @change="onDeepAnalysisChange"
            color="#4A90E2"
          />
        </view>
      </view>

      <view class="step-actions">
        <button class="prev-button" @click="prevStep">上一步</button>
        <button class="next-button" @click="nextStep" :disabled="!formData.scene">
          下一步
        </button>
      </view>
    </view>

    <!-- 步骤4: 触发因素和身体症状 -->
    <view class="step-content" v-if="currentStep === 4">
      <view class="step-title">
        <text class="title">详细信息</text>
        <text class="subtitle">选择触发因素和身体症状（可选）</text>
      </view>

      <!-- 触发因素 -->
      <view class="detail-section">
        <view class="section-title">
          <text>触发因素</text>
        </view>
        <view class="triggers-grid">
          <view 
            class="trigger-item" 
            v-for="trigger in triggerOptions" 
            :key="trigger"
            :class="{ selected: formData.triggers.includes(trigger) }"
            @click="toggleTrigger(trigger)"
          >
            <text class="trigger-text">{{ trigger }}</text>
          </view>
        </view>
      </view>

      <!-- 身体症状 -->
      <view class="detail-section">
        <view class="section-title">
          <text>身体症状</text>
        </view>
        <view class="symptoms-grid">
          <view 
            class="symptom-item" 
            v-for="symptom in symptomOptions" 
            :key="symptom"
            :class="{ selected: formData.physicalSymptoms.includes(symptom) }"
            @click="toggleSymptom(symptom)"
          >
            <text class="symptom-text">{{ symptom }}</text>
          </view>
        </view>
      </view>

      <!-- 应对方式 -->
      <view class="detail-section">
        <view class="section-title">
          <text>应对方式</text>
        </view>
        <view class="coping-grid">
          <view 
            class="coping-item" 
            v-for="method in copingOptions" 
            :key="method"
            :class="{ selected: formData.copingMethods.includes(method) }"
            @click="toggleCoping(method)"
          >
            <text class="coping-text">{{ method }}</text>
          </view>
        </view>
      </view>

      <!-- 深度分析开关 -->
      <view class="deep-analysis-section">
        <view class="analysis-header" @click="toggleDeepAnalysis">
          <view class="analysis-info">
            <text class="analysis-title">深度分析</text>
            <text class="analysis-desc">回答几个问题，获得更精准的AI建议</text>
          </view>
          <switch 
            :checked="formData.enableDeepAnalysis"
            @change="onDeepAnalysisChange"
            color="#4A90E2"
          />
        </view>
      </view>

      <!-- 记录预览 -->
      <view class="record-preview">
        <view class="preview-title">
          <text>记录预览</text>
        </view>
        <view class="preview-content">
          <view class="preview-item">
            <text class="preview-label">情绪描述：</text>
            <text class="preview-text">{{ formData.text || '暂无' }}</text>
          </view>
          <view class="preview-item">
            <text class="preview-label">主要情绪：</text>
            <text class="preview-text">{{ formData.emotions.join('、') || '暂无' }}</text>
          </view>
          <view class="preview-item">
            <text class="preview-label">情绪强度：</text>
            <text class="preview-text">{{ formData.intensity }}/10</text>
          </view>
          <view class="preview-item">
            <text class="preview-label">相关场景：</text>
            <text class="preview-text">{{ formData.scene || '暂无' }}</text>
          </view>
          <view class="preview-item" v-if="formData.triggers.length > 0">
            <text class="preview-label">触发因素：</text>
            <text class="preview-text">{{ formData.triggers.join('、') }}</text>
          </view>
          <view class="preview-item" v-if="formData.physicalSymptoms.length > 0">
            <text class="preview-label">身体症状：</text>
            <text class="preview-text">{{ formData.physicalSymptoms.join('、') }}</text>
          </view>
          <view class="preview-item" v-if="formData.copingMethods.length > 0">
            <text class="preview-label">应对方式：</text>
            <text class="preview-text">{{ formData.copingMethods.join('、') }}</text>
          </view>
        </view>
      </view>

      <view class="step-actions">
        <button class="prev-button" @click="prevStep">上一步</button>
        <button class="save-button" @click="saveRecord">
          {{ formData.enableDeepAnalysis ? '继续深度分析' : '保存记录' }}
        </button>
      </view>
    </view>

    <!-- 深度分析问题 -->
    <view class="deep-analysis-modal" v-if="showDeepAnalysis">
      <view class="modal-content">
        <view class="modal-header">
          <text class="modal-title">深度分析 ({{ currentQuestion + 1 }}/{{ deepQuestions.length }})</text>
          <text class="close-btn" @click="closeDeepAnalysis">×</text>
        </view>
        
        <view class="question-content">
          <text class="question-text">{{ deepQuestions[currentQuestion].question }}</text>
          
          <view class="answer-options">
            <view 
              class="option-item" 
              v-for="(option, index) in deepQuestions[currentQuestion].options" 
              :key="index"
              :class="{ selected: formData.deepAnswers[currentQuestion] === index }"
              @click="selectAnswer(index)"
            >
              <text class="option-text">{{ option }}</text>
            </view>
          </view>
        </view>

        <view class="question-actions">
          <button 
            class="prev-question-btn" 
            @click="prevQuestion" 
            v-if="currentQuestion > 0"
          >
            上一题
          </button>
          <button 
            class="next-question-btn" 
            @click="nextQuestion"
            :disabled="formData.deepAnswers[currentQuestion] === undefined"
          >
            {{ currentQuestion === deepQuestions.length - 1 ? '完成分析' : '下一题' }}
          </button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { emotionAPI, getToken, getUser } from '../../utils/api'

// 类型定义
interface EmotionOption {
  name: string
  icon: string
  description: string
}

interface SceneOption {
  name: string
  icon: string
  description: string
}

interface DeepQuestion {
  question: string
  options: string[]
}

interface FormData {
  text: string
  emotions: string[]
  intensity: number
  scene: string
  triggers: string[]
  physicalSymptoms: string[]
  copingMethods: string[]
  enableDeepAnalysis: boolean
  deepAnswers: (number | undefined)[]
}

interface UniInputEvent {
  detail: {
    value: string | number | boolean
  }
}

// 响应式数据
const currentStep = ref<number>(1)
const showDeepAnalysis = ref<boolean>(false)
const currentQuestion = ref<number>(0)

const formData = reactive<FormData>({
  text: '',
  emotions: [],
  intensity: 5,
  scene: '',
  triggers: [],
  physicalSymptoms: [],
  copingMethods: [],
  enableDeepAnalysis: false,
  deepAnswers: []
})

// 情绪选项
const emotions = ref<EmotionOption[]>([
  { name: '快乐', icon: '😄', description: '愉悦、开心、满足' },
  { name: '焦虑', icon: '😟', description: '紧张、担心、不安' },
  { name: '愤怒', icon: '😡', description: '生气、愤怒、恼火' },
  { name: '悲伤', icon: '😢', description: '难过、沮丧、失落' },
  { name: '平静', icon: '😌', description: '放松、平和、宁静' },
  { name: '恐惧', icon: '😨', description: '害怕、恐慌、畏惧' }
])

// 场景选项
const scenes = ref<SceneOption[]>([
  { name: '工作', icon: '💼', description: '工作、职场、同事关系' },
  { name: '学习', icon: '📚', description: '学习、考试、学业压力' },
  { name: '生活', icon: '🏠', description: '日常生活、家庭、生活琐事' },
  { name: '社交', icon: '👥', description: '朋友聚会、社交活动' },
  { name: '健康', icon: '💊', description: '身体健康、医疗相关' },
  { name: '其他', icon: '🌟', description: '其他特殊情况' }
])

// 触发因素选项
const triggerOptions = ref<string[]>([
  '工作压力', '人际关系', '身体不适', '经济问题', 
  '学习困难', '家庭矛盾', '环境变化', '时间压力',
  '期望落空', '沟通问题', '决策困难', '其他'
])

// 身体症状选项
const symptomOptions = ref<string[]>([
  '心跳加速', '胸闷气短', '肌肉紧张', '头痛头晕',
  '失眠多梦', '食欲变化', '疲劳乏力', '出汗颤抖',
  '胃部不适', '注意力难集中', '无明显症状'
])

// 应对方式选项
const copingOptions = ref<string[]>([
  '深呼吸', '运动锻炼', '听音乐', '倾诉交流',
  '写日记', '冥想放松', '转移注意力', '寻求帮助',
  '积极思考', '接受现状', '暂时回避', '其他方式'
])

// 深度分析问题
const deepQuestions = ref<DeepQuestion[]>([
  {
    question: '这种情绪让你身体有什么反应？',
    options: ['心跳加速', '胸闷气短', '肌肉紧张', '头痛头晕', '没有明显反应']
  },
  {
    question: '你认为这种情绪主要由什么引起？',
    options: ['具体事件', '身体状态', '他人行为', '环境因素', '无明显原因']
  },
  {
    question: '面对这种情绪，你通常会？',
    options: ['分析问题', '寻求帮助', '暂时回避', '自我否定', '接受现状']
  },
  {
    question: '这种情绪对你的影响程度？',
    options: ['严重影响日常', '中等影响', '轻微影响', '基本无影响']
  },
  {
    question: '你希望通过什么方式改善？',
    options: ['运动锻炼', '倾诉交流', '专业帮助', '自我调节', '暂时不处理']
  }
])

// 方法
const onTextInput = (e: UniInputEvent) => {
  formData.text = e.detail.value as string
}

const onIntensityChange = (e: UniInputEvent) => {
  formData.intensity = e.detail.value as number
}

const onDeepAnalysisChange = (e: UniInputEvent) => {
  formData.enableDeepAnalysis = e.detail.value as boolean
}

const nextStep = () => {
  if (currentStep.value < 4) {
    currentStep.value++
  }
}

const prevStep = () => {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

const toggleEmotion = (emotionName: string) => {
  const index = formData.emotions.indexOf(emotionName)
  if (index > -1) {
    formData.emotions.splice(index, 1)
  } else {
    formData.emotions.push(emotionName)
  }
}

const selectScene = (sceneName: string) => {
  formData.scene = sceneName
}

const toggleTrigger = (trigger: string) => {
  const index = formData.triggers.indexOf(trigger)
  if (index > -1) {
    formData.triggers.splice(index, 1)
  } else {
    formData.triggers.push(trigger)
  }
}

const toggleSymptom = (symptom: string) => {
  const index = formData.physicalSymptoms.indexOf(symptom)
  if (index > -1) {
    formData.physicalSymptoms.splice(index, 1)
  } else {
    formData.physicalSymptoms.push(symptom)
  }
}

const toggleCoping = (method: string) => {
  const index = formData.copingMethods.indexOf(method)
  if (index > -1) {
    formData.copingMethods.splice(index, 1)
  } else {
    formData.copingMethods.push(method)
  }
}

const toggleDeepAnalysis = () => {
  formData.enableDeepAnalysis = !formData.enableDeepAnalysis
}

const startVoiceInput = () => {
  // 语音输入功能
  uni.showToast({
    title: '语音输入功能开发中',
    icon: 'none'
  })
}

const saveRecord = () => {
  if (formData.enableDeepAnalysis) {
    // 初始化深度分析答案数组
    formData.deepAnswers = new Array(deepQuestions.value.length).fill(undefined)
    showDeepAnalysis.value = true
    currentQuestion.value = 0
  } else {
    // 直接保存记录
    submitRecord()
  }
}

const selectAnswer = (answerIndex: number) => {
  formData.deepAnswers[currentQuestion.value] = answerIndex
}

const nextQuestion = () => {
  if (currentQuestion.value < deepQuestions.value.length - 1) {
    currentQuestion.value++
  } else {
    // 完成所有问题，提交记录
    closeDeepAnalysis()
    submitRecord()
  }
}

const prevQuestion = () => {
  if (currentQuestion.value > 0) {
    currentQuestion.value--
  }
}

const closeDeepAnalysis = () => {
  showDeepAnalysis.value = false
}

const submitRecord = async () => {
  // 检查认证状态
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

  // 数据验证
  if (!formData.text.trim()) {
    uni.showToast({
      title: '请输入情绪描述',
      icon: 'none'
    })
    return
  }

  if (formData.emotions.length === 0) {
    uni.showToast({
      title: '请选择至少一种情绪',
      icon: 'none'
    })
    return
  }

  if (!formData.scene) {
    uni.showToast({
      title: '请选择相关场景',
      icon: 'none'
    })
    return
  }

  try {
    uni.showLoading({
      title: '保存中...'
    })

    // 构建符合后端API的记录数据
    const recordData = {
      emotion_type: mapEmotionToBackend(formData.emotions[0]), // 主要情绪
      intensity: formData.intensity,
      scenario: mapSceneToBackend(formData.scene),
      description: formData.text,
      triggers: formData.triggers.length > 0 ? formData.triggers : ['手动记录'],
      physical_symptoms: formData.physicalSymptoms.length > 0 ? formData.physicalSymptoms : [],
      coping_methods: formData.copingMethods.length > 0 ? formData.copingMethods : ['情绪记录'],
      people_involved: [],
      location: '',
      weather: '',
      effectiveness_rating: null,
      is_private: false,
      enable_ai_analysis: formData.enableDeepAnalysis
    }

    // 如果启用了深度分析，添加额外信息
    if (formData.enableDeepAnalysis && formData.deepAnswers.length > 0) {
      // 将深度分析答案存储在triggers中
      const analysisData = deepQuestions.value.map((q, index) => {
        if (formData.deepAnswers[index] !== undefined) {
          return `${q.question}: ${q.options[formData.deepAnswers[index] as number]}`
        }
        return null
      }).filter((item): item is string => Boolean(item))
      
      recordData.triggers = [...recordData.triggers, ...analysisData]
    }

    console.log('提交记录数据:', recordData)

    // 调用API创建记录
    const response = await emotionAPI.createRecord(recordData)
    
    uni.hideLoading()
    
    // 显示成功提示
    uni.showToast({
      title: '记录保存成功',
      icon: 'success'
    })

    // 清除草稿并重置表单
    clearDraft()
    resetForm()

    // 跳转到分析页面，传递记录ID
    setTimeout(() => {
      if (formData.enableDeepAnalysis) {
        uni.navigateTo({
          url: `/pages/analysis/index?recordId=${response.id}`
        })
      } else {
        uni.switchTab({
          url: '/pages/index/index'
        })
      }
    }, 1500)

  } catch (error: any) {
    uni.hideLoading()
    console.error('保存记录失败:', error)
    
    uni.showToast({
      title: error?.message || '保存失败，请重试',
      icon: 'none',
      duration: 3000
    })
  }
}

// 重置表单
const resetForm = () => {
  formData.text = ''
  formData.emotions = []
  formData.intensity = 5
  formData.scene = ''
  formData.triggers = []
  formData.physicalSymptoms = []
  formData.copingMethods = []
  formData.enableDeepAnalysis = false
  formData.deepAnswers = []
  currentStep.value = 1
  showDeepAnalysis.value = false
  currentQuestion.value = 0
}

// 映射前端情绪到后端格式
const mapEmotionToBackend = (emotion: string): string => {
  const emotionMap: Record<string, string> = {
    '快乐': 'happy',
    '焦虑': 'anxious', 
    '愤怒': 'angry',
    '悲伤': 'sad',
    '平静': 'calm',
    '恐惧': 'fearful'
  }
  return emotionMap[emotion] || 'happy'
}

// 映射前端场景到后端格式
const mapSceneToBackend = (scene: string): string => {
  const sceneMap: Record<string, string> = {
    '工作': 'work',
    '学习': 'study',
    '生活': 'personal',
    '社交': 'social', 
    '健康': 'health',
    '其他': 'other'
  }
  return sceneMap[scene] || 'personal'
}

// 保存草稿
const saveDraft = () => {
  const draftData = {
    ...formData,
    currentStep: currentStep.value,
    timestamp: Date.now()
  }
  
  uni.setStorageSync('emotion_record_draft', draftData)
  
  uni.showToast({
    title: '草稿已保存',
    icon: 'success',
    duration: 1500
  })
}

// 加载草稿
const loadDraft = () => {
  try {
    const draft = uni.getStorageSync('emotion_record_draft')
    if (draft && draft.timestamp) {
      // 检查草稿是否在24小时内
      const now = Date.now()
      const draftAge = now - draft.timestamp
      const oneDayMs = 24 * 60 * 60 * 1000
      
      if (draftAge < oneDayMs) {
        uni.showModal({
          title: '发现草稿',
          content: '检测到未完成的记录，是否继续编辑？',
          success: (res) => {
            if (res.confirm) {
              // 恢复草稿数据
              Object.assign(formData, draft)
              currentStep.value = draft.currentStep || 1
              
              uni.showToast({
                title: '草稿已恢复',
                icon: 'success'
              })
            } else {
              // 清除草稿
              uni.removeStorageSync('emotion_record_draft')
            }
          }
        })
      } else {
        // 草稿过期，清除
        uni.removeStorageSync('emotion_record_draft')
      }
    }
  } catch (error) {
    console.log('加载草稿失败:', error)
  }
}

// 清除草稿
const clearDraft = () => {
  uni.removeStorageSync('emotion_record_draft')
}

// 生命周期
onMounted(() => {
  // 获取页面参数，支持快速记录
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1] as any
  const options = currentPage?.options || {}
  
  if (options.quickEmotion) {
    formData.emotions = [options.quickEmotion]
    currentStep.value = 2
  } else {
    // 尝试加载草稿
    loadDraft()
  }
})
</script>

<style scoped>
/* 页面特定变量（继承全局变量） */
:root {
  --glass-bg: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --shadow-light: 0 8rpx 32rpx rgba(0, 0, 0, 0.12);
  --shadow-medium: 0 12rpx 48rpx rgba(0, 0, 0, 0.18);
  --shadow-heavy: 0 16rpx 64rpx rgba(0, 0, 0, 0.24);
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --success-gradient: linear-gradient(135deg, #4ecdc4 0%, #44a08d 100%);
  --warning-gradient: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
  --error-gradient: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
  --text-primary: #2d3748;
  --text-secondary: #4a5568;
  --text-placeholder: #a0aec0;
  --primary-color: #667eea;
  --success-color: #48bb78;
  --warning-color: #ed8936;
  --error-color: #f56565;
}

.container {
  padding: 0;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
  position: relative;
  padding-bottom: 120rpx;
}

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

/* 页面头部 - 现代化设计 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 40rpx 30rpx 30rpx;
  position: relative;
  z-index: 1;
}

.page-title {
  font-size: 42rpx;
  font-weight: 800;
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
}

.draft-button {
  display: flex;
  align-items: center;
  gap: 8rpx;
  padding: 15rpx 25rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--glass-border);
  border-radius: 25rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.draft-button:hover {
  transform: translateY(-2rpx);
  box-shadow: var(--shadow-medium);
}

.draft-icon {
  font-size: 26rpx;
  filter: drop-shadow(0 2rpx 4rpx rgba(0, 0, 0, 0.1));
}

.draft-text {
  color: var(--text-primary);
  font-size: 26rpx;
  font-weight: 600;
}

/* 进度条 - 现代化设计 */
.progress-bar {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40rpx 30rpx;
  margin: 0 20rpx 30rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--glass-border);
  border-radius: 25rpx;
  box-shadow: var(--shadow-light);
  position: relative;
  overflow: hidden;
  z-index: 1;
}

.progress-bar::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
}

.progress-bar::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: var(--primary-gradient);
  border-radius: 25rpx 25rpx 0 0;
}

.progress-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  opacity: 0.6;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  transform: scale(0.9);
  position: relative;
  z-index: 2;
}

.progress-step.active {
  opacity: 1;
  transform: scale(1);
}

.step-number {
  width: 70rpx;
  height: 70rpx;
  border-radius: 50%;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 3rpx solid var(--glass-border);
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26rpx;
  font-weight: 700;
  margin-bottom: 12rpx;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: var(--shadow-light);
}

.progress-step.active .step-number {
  background: var(--primary-gradient);
  border-color: rgba(255, 255, 255, 0.3);
  color: white;
  transform: scale(1.1);
  box-shadow: var(--shadow-medium);
  animation: pulse-glow 2s ease-in-out infinite alternate;
}

@keyframes pulse-glow {
  0% { box-shadow: var(--shadow-medium); }
  100% { box-shadow: 0 8rpx 32rpx rgba(102, 126, 234, 0.4); }
}

.step-text {
  font-size: 24rpx;
  color: var(--text-secondary);
  font-weight: 600;
  transition: all 0.3s ease;
}

.progress-step.active .step-text {
  color: var(--text-primary);
  font-weight: 700;
}

.progress-line {
  width: 60rpx;
  height: 6rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(5rpx);
  border: 1rpx solid var(--glass-border);
  border-radius: 3rpx;
  margin: 0 15rpx;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.progress-line.active {
  background: var(--primary-gradient);
  border-color: rgba(255, 255, 255, 0.3);
  box-shadow: 0 2rpx 8rpx rgba(102, 126, 234, 0.3);
}

.progress-line.active::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  animation: shimmer 2s ease-in-out infinite;
}

@keyframes shimmer {
  0% { left: -100%; }
  100% { left: 100%; }
}

/* 步骤内容 - 现代化卡片 */
.step-content {
  background: var(--glass-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--glass-border);
  border-radius: 25rpx;
  padding: 50rpx 40rpx;
  margin: 0 20rpx 30rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  z-index: 1;
}

.step-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
}

.step-title {
  text-align: center;
  margin-bottom: 50rpx;
  position: relative;
}

.title {
  font-size: 40rpx;
  font-weight: 800;
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
  display: block;
  margin-bottom: 15rpx;
}

.subtitle {
  font-size: 28rpx;
  color: var(--text-secondary);
  opacity: 0.9;
  font-weight: 500;
}

/* 输入区域 - 现代化设计 */
.input-section {
  position: relative;
  margin-bottom: 40rpx;
}

.diary-input {
  width: 100%;
  min-height: 240rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  padding: 25rpx;
  font-size: 30rpx;
  line-height: 1.8;
  box-sizing: border-box;
  color: var(--text-primary);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: var(--shadow-light);
}

.diary-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 8rpx 32rpx rgba(102, 126, 234, 0.2);
  transform: translateY(-2rpx);
}

.diary-input::placeholder {
  color: var(--text-placeholder);
  opacity: 0.8;
}

.char-count {
  position: absolute;
  bottom: 20rpx;
  right: 25rpx;
  font-size: 24rpx;
  padding: 8rpx 16rpx;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(5rpx);
  border-radius: 15rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.1);
}

.count {
  color: var(--primary-color);
  font-weight: 600;
}

.max {
  color: var(--text-placeholder);
}

/* 语音输入 - 现代化按钮 */
.voice-input {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 25rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  margin-bottom: 50rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.voice-input::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s ease;
}

.voice-input:hover::before {
  left: 100%;
}

.voice-input:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.voice-icon {
  font-size: 36rpx;
  margin-right: 12rpx;
  filter: drop-shadow(0 2rpx 8rpx rgba(0, 0, 0, 0.1));
  animation: pulse-mic 2s ease-in-out infinite;
}

@keyframes pulse-mic {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.voice-text {
  font-size: 28rpx;
  color: var(--text-primary);
  font-weight: 600;
}

/* 情绪网格 - 现代化卡片 */
.emotions-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 25rpx;
  margin-bottom: 50rpx;
}

.emotion-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 35rpx 25rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.emotion-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: var(--primary-gradient);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.emotion-item:hover {
  transform: translateY(-6rpx);
  box-shadow: var(--shadow-medium);
}

.emotion-item:hover::before {
  transform: scaleX(1);
}

.emotion-item.selected {
  background: var(--primary-gradient);
  border-color: rgba(255, 255, 255, 0.3);
  color: white;
  transform: translateY(-6rpx) scale(1.02);
  box-shadow: 0 12rpx 48rpx rgba(102, 126, 234, 0.3);
}

.emotion-item.selected::before {
  transform: scaleX(1);
  background: rgba(255, 255, 255, 0.5);
}

.emotion-icon {
  font-size: 56rpx;
  margin-bottom: 15rpx;
  filter: drop-shadow(0 4rpx 12rpx rgba(0, 0, 0, 0.15));
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0rpx); }
  50% { transform: translateY(-4rpx); }
}

.emotion-item.selected .emotion-icon {
  animation: bounce 0.6s ease-in-out;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0rpx) scale(1); }
  50% { transform: translateY(-8rpx) scale(1.1); }
}

.emotion-name {
  font-size: 30rpx;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 8rpx;
  transition: color 0.3s ease;
}

.emotion-item.selected .emotion-name {
  color: white;
}

.emotion-desc {
  font-size: 24rpx;
  color: var(--text-secondary);
  text-align: center;
  opacity: 0.9;
  transition: color 0.3s ease;
}

.emotion-item.selected .emotion-desc {
  color: rgba(255, 255, 255, 0.9);
}

/* 强度滑块 - 现代化设计 */
.intensity-section {
  margin-bottom: 50rpx;
  padding: 30rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  box-shadow: var(--shadow-light);
}

.intensity-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25rpx;
  font-size: 30rpx;
  color: var(--text-primary);
  font-weight: 600;
}

.intensity-value {
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--primary-color);
  font-weight: 800;
  font-size: 32rpx;
  animation: pulse-value 1s ease-in-out;
}

@keyframes pulse-value {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

.intensity-slider {
  width: 100%;
  margin-bottom: 15rpx;
}

.intensity-labels {
  display: flex;
  justify-content: space-between;
  font-size: 24rpx;
  color: var(--text-secondary);
  font-weight: 500;
}

/* 场景列表 - 现代化设计 */
.scenes-list {
  margin-bottom: 50rpx;
}

.scene-item {
  display: flex;
  align-items: center;
  padding: 30rpx 25rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  margin-bottom: 20rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.scene-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transition: left 0.5s ease;
}

.scene-item:hover::before {
  left: 100%;
}

.scene-item:hover {
  transform: translateX(8rpx);
  box-shadow: var(--shadow-medium);
}

.scene-item.selected {
  background: var(--primary-gradient);
  border-color: rgba(255, 255, 255, 0.3);
  color: white;
  transform: translateX(8rpx);
  box-shadow: 0 8rpx 32rpx rgba(102, 126, 234, 0.3);
}

.scene-icon {
  font-size: 44rpx;
  margin-right: 25rpx;
  filter: drop-shadow(0 2rpx 8rpx rgba(0, 0, 0, 0.1));
}

.scene-info {
  flex: 1;
}

.scene-name {
  font-size: 30rpx;
  font-weight: 700;
  color: var(--text-primary);
  display: block;
  margin-bottom: 8rpx;
  transition: color 0.3s ease;
}

.scene-item.selected .scene-name {
  color: white;
}

.scene-desc {
  font-size: 24rpx;
  color: var(--text-secondary);
  opacity: 0.9;
  transition: color 0.3s ease;
}

.scene-item.selected .scene-desc {
  color: rgba(255, 255, 255, 0.9);
}

.check-icon {
  font-size: 32rpx;
  color: white;
  font-weight: bold;
  animation: checkmark 0.5s ease-in-out;
}

@keyframes checkmark {
  0% { transform: scale(0) rotate(0deg); }
  50% { transform: scale(1.2) rotate(180deg); }
  100% { transform: scale(1) rotate(360deg); }
}

/* 深度分析区域 - 现代化设计 */
.deep-analysis-section {
  padding: 30rpx 25rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  margin-bottom: 50rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.deep-analysis-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: var(--warning-gradient);
  border-radius: 20rpx 20rpx 0 0;
}

.deep-analysis-section:hover {
  transform: translateY(-2rpx);
  box-shadow: var(--shadow-medium);
}

.analysis-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.analysis-info {
  flex: 1;
}

.analysis-title {
  font-size: 30rpx;
  font-weight: 700;
  background: var(--warning-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
  display: block;
  margin-bottom: 8rpx;
}

.analysis-desc {
  font-size: 24rpx;
  color: var(--text-secondary);
  opacity: 0.9;
}

/* 按钮组 - 现代化设计 */
.step-actions {
  display: flex;
  gap: 25rpx;
  margin-top: 20rpx;
}

.prev-button,
.next-button,
.save-button {
  flex: 1;
  height: 90rpx;
  border-radius: 25rpx;
  font-size: 30rpx;
  font-weight: 600;
  border: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  box-shadow: var(--shadow-light);
}

.prev-button {
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  color: var(--text-primary);
}

.prev-button:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.next-button,
.save-button {
  background: var(--primary-gradient);
  color: white;
  box-shadow: 0 8rpx 32rpx rgba(102, 126, 234, 0.3);
}

.next-button::before,
.save-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.5s ease;
}

.next-button:hover::before,
.save-button:hover::before {
  left: 100%;
}

.next-button:hover,
.save-button:hover {
  transform: translateY(-4rpx);
  box-shadow: 0 12rpx 48rpx rgba(102, 126, 234, 0.4);
}

.next-button:disabled,
.save-button:disabled {
  background: var(--glass-bg);
  color: var(--text-placeholder);
  opacity: 0.6;
  transform: none;
  box-shadow: var(--shadow-light);
}

/* 深度分析模态框 - 现代化设计 */
.deep-analysis-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(10rpx);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: var(--glass-bg);
  backdrop-filter: blur(20rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 25rpx;
  margin: 30rpx;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: var(--shadow-heavy);
  animation: slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

@keyframes slideUp {
  from { transform: translateY(50rpx); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.modal-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 6rpx;
  background: var(--primary-gradient);
  border-radius: 25rpx 25rpx 0 0;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 40rpx;
  border-bottom: 2rpx solid var(--glass-border);
}

.modal-title {
  font-size: 34rpx;
  font-weight: 700;
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
}

.close-btn {
  font-size: 44rpx;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;
  width: 50rpx;
  height: 50rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
}

.close-btn:hover {
  background: rgba(255, 0, 0, 0.1);
  color: var(--error-color);
  transform: scale(1.1);
}

.question-content {
  padding: 40rpx;
}

.question-text {
  font-size: 32rpx;
  color: var(--text-primary);
  line-height: 1.8;
  margin-bottom: 40rpx;
  display: block;
  font-weight: 600;
}

.answer-options {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.option-item {
  padding: 30rpx 25rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(5rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.option-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transition: left 0.5s ease;
}

.option-item:hover::before {
  left: 100%;
}

.option-item:hover {
  transform: translateX(8rpx);
  box-shadow: var(--shadow-light);
}

.option-item.selected {
  background: var(--primary-gradient);
  border-color: rgba(255, 255, 255, 0.3);
  color: white;
  transform: translateX(8rpx);
  box-shadow: 0 8rpx 32rpx rgba(102, 126, 234, 0.3);
}

.option-text {
  font-size: 28rpx;
  color: var(--text-primary);
  font-weight: 500;
  transition: color 0.3s ease;
}

.option-item.selected .option-text {
  color: white;
  font-weight: 600;
}

.question-actions {
  padding: 40rpx;
  display: flex;
  gap: 25rpx;
  border-top: 2rpx solid var(--glass-border);
}

.prev-question-btn,
.next-question-btn {
  flex: 1;
  height: 90rpx;
  border-radius: 25rpx;
  font-size: 30rpx;
  font-weight: 600;
  border: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: var(--shadow-light);
}

.prev-question-btn {
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  color: var(--text-primary);
}

.prev-question-btn:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.next-question-btn {
  background: var(--primary-gradient);
  color: white;
  box-shadow: 0 8rpx 32rpx rgba(102, 126, 234, 0.3);
}

.next-question-btn:hover {
  transform: translateY(-4rpx);
  box-shadow: 0 12rpx 48rpx rgba(102, 126, 234, 0.4);
}

.next-question-btn:disabled {
  background: var(--glass-bg);
  color: var(--text-placeholder);
  opacity: 0.6;
  transform: none;
  box-shadow: var(--shadow-light);
}

/* 详细信息区域 - 现代化设计 */
.detail-section {
  margin-bottom: 50rpx;
}

.section-title {
  font-size: 30rpx;
  font-weight: 700;
  background: var(--primary-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
  margin-bottom: 25rpx;
  display: block;
}

.triggers-grid,
.symptoms-grid,
.coping-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.trigger-item,
.symptom-item,
.coping-item {
  padding: 18rpx 25rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(5rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 30rpx;
  box-shadow: var(--shadow-light);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.trigger-item::before,
.symptom-item::before,
.coping-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3rpx;
  background: var(--primary-gradient);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.trigger-item:hover,
.symptom-item:hover,
.coping-item:hover {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-medium);
}

.trigger-item:hover::before,
.symptom-item:hover::before,
.coping-item:hover::before {
  transform: scaleX(1);
}

.trigger-item.selected,
.symptom-item.selected,
.coping-item.selected {
  background: var(--primary-gradient);
  border-color: rgba(255, 255, 255, 0.3);
  color: white;
  transform: translateY(-4rpx);
  box-shadow: 0 8rpx 32rpx rgba(102, 126, 234, 0.3);
}

.trigger-item.selected::before,
.symptom-item.selected::before,
.coping-item.selected::before {
  transform: scaleX(1);
  background: rgba(255, 255, 255, 0.5);
}

.trigger-text,
.symptom-text,
.coping-text {
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 500;
  transition: all 0.3s ease;
}

.trigger-item.selected .trigger-text,
.symptom-item.selected .symptom-text,
.coping-item.selected .coping-text {
  color: white;
  font-weight: 600;
}

/* 记录预览 - 现代化设计 */
.record-preview {
  margin-bottom: 50rpx;
  background: var(--glass-bg);
  backdrop-filter: blur(10rpx);
  border: 2rpx solid var(--glass-border);
  border-radius: 20rpx;
  padding: 30rpx 25rpx;
  box-shadow: var(--shadow-light);
  position: relative;
  overflow: hidden;
}

.record-preview::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: var(--success-gradient);
  border-radius: 20rpx 20rpx 0 0;
}

.preview-title {
  font-size: 30rpx;
  font-weight: 700;
  background: var(--success-gradient);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  color: var(--text-primary);
  margin-bottom: 25rpx;
  display: block;
}

.preview-content {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.preview-item {
  display: flex;
  align-items: flex-start;
  gap: 15rpx;
  padding: 15rpx 0;
  border-bottom: 1rpx solid var(--glass-border);
}

.preview-item:last-child {
  border-bottom: none;
}

.preview-label {
  font-size: 26rpx;
  color: var(--text-secondary);
  min-width: 150rpx;
  flex-shrink: 0;
  font-weight: 600;
}

.preview-text {
  font-size: 26rpx;
  color: var(--text-primary);
  flex: 1;
  line-height: 1.6;
  font-weight: 500;
}

/* 深色模式特定样式调整 */
@media (prefers-color-scheme: dark) {
  .container {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  }
  
  .page-title,
  .title,
  .section-title,
  .preview-title,
  .modal-title {
    color: var(--text-primary);
  }
  
  .analysis-title {
    color: var(--text-primary);
  }
}
</style> 