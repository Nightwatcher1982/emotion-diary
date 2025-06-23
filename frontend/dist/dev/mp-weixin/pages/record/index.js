"use strict";
const common_vendor = require("../../common/vendor.js");
const utils_api = require("../../utils/api.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const currentStep = common_vendor.ref(1);
    const showDeepAnalysis = common_vendor.ref(false);
    const currentQuestion = common_vendor.ref(0);
    const formData = common_vendor.reactive({
      text: "",
      emotions: [],
      intensity: 5,
      scene: "",
      triggers: [],
      physicalSymptoms: [],
      copingMethods: [],
      enableDeepAnalysis: false,
      deepAnswers: []
    });
    const emotions = common_vendor.ref([
      { name: "快乐", icon: "😄", description: "愉悦、开心、满足" },
      { name: "焦虑", icon: "😟", description: "紧张、担心、不安" },
      { name: "愤怒", icon: "😡", description: "生气、愤怒、恼火" },
      { name: "悲伤", icon: "😢", description: "难过、沮丧、失落" },
      { name: "平静", icon: "😌", description: "放松、平和、宁静" },
      { name: "恐惧", icon: "😨", description: "害怕、恐慌、畏惧" }
    ]);
    const scenes = common_vendor.ref([
      { name: "工作", icon: "💼", description: "工作、职场、同事关系" },
      { name: "学习", icon: "📚", description: "学习、考试、学业压力" },
      { name: "生活", icon: "🏠", description: "日常生活、家庭、生活琐事" },
      { name: "社交", icon: "👥", description: "朋友聚会、社交活动" },
      { name: "健康", icon: "💊", description: "身体健康、医疗相关" },
      { name: "其他", icon: "🌟", description: "其他特殊情况" }
    ]);
    const triggerOptions = common_vendor.ref([
      "工作压力",
      "人际关系",
      "身体不适",
      "经济问题",
      "学习困难",
      "家庭矛盾",
      "环境变化",
      "时间压力",
      "期望落空",
      "沟通问题",
      "决策困难",
      "其他"
    ]);
    const symptomOptions = common_vendor.ref([
      "心跳加速",
      "胸闷气短",
      "肌肉紧张",
      "头痛头晕",
      "失眠多梦",
      "食欲变化",
      "疲劳乏力",
      "出汗颤抖",
      "胃部不适",
      "注意力难集中",
      "无明显症状"
    ]);
    const copingOptions = common_vendor.ref([
      "深呼吸",
      "运动锻炼",
      "听音乐",
      "倾诉交流",
      "写日记",
      "冥想放松",
      "转移注意力",
      "寻求帮助",
      "积极思考",
      "接受现状",
      "暂时回避",
      "其他方式"
    ]);
    const deepQuestions = common_vendor.ref([
      {
        question: "这种情绪让你身体有什么反应？",
        options: ["心跳加速", "胸闷气短", "肌肉紧张", "头痛头晕", "没有明显反应"]
      },
      {
        question: "你认为这种情绪主要由什么引起？",
        options: ["具体事件", "身体状态", "他人行为", "环境因素", "无明显原因"]
      },
      {
        question: "面对这种情绪，你通常会？",
        options: ["分析问题", "寻求帮助", "暂时回避", "自我否定", "接受现状"]
      },
      {
        question: "这种情绪对你的影响程度？",
        options: ["严重影响日常", "中等影响", "轻微影响", "基本无影响"]
      },
      {
        question: "你希望通过什么方式改善？",
        options: ["运动锻炼", "倾诉交流", "专业帮助", "自我调节", "暂时不处理"]
      }
    ]);
    const onTextInput = (e) => {
      formData.text = e.detail.value;
    };
    const onIntensityChange = (e) => {
      formData.intensity = e.detail.value;
    };
    const onDeepAnalysisChange = (e) => {
      formData.enableDeepAnalysis = e.detail.value;
    };
    const nextStep = () => {
      if (currentStep.value < 4) {
        currentStep.value++;
      }
    };
    const prevStep = () => {
      if (currentStep.value > 1) {
        currentStep.value--;
      }
    };
    const toggleEmotion = (emotionName) => {
      const index = formData.emotions.indexOf(emotionName);
      if (index > -1) {
        formData.emotions.splice(index, 1);
      } else {
        formData.emotions.push(emotionName);
      }
    };
    const selectScene = (sceneName) => {
      formData.scene = sceneName;
    };
    const toggleTrigger = (trigger) => {
      const index = formData.triggers.indexOf(trigger);
      if (index > -1) {
        formData.triggers.splice(index, 1);
      } else {
        formData.triggers.push(trigger);
      }
    };
    const toggleSymptom = (symptom) => {
      const index = formData.physicalSymptoms.indexOf(symptom);
      if (index > -1) {
        formData.physicalSymptoms.splice(index, 1);
      } else {
        formData.physicalSymptoms.push(symptom);
      }
    };
    const toggleCoping = (method) => {
      const index = formData.copingMethods.indexOf(method);
      if (index > -1) {
        formData.copingMethods.splice(index, 1);
      } else {
        formData.copingMethods.push(method);
      }
    };
    const toggleDeepAnalysis = () => {
      formData.enableDeepAnalysis = !formData.enableDeepAnalysis;
    };
    const startVoiceInput = () => {
      common_vendor.index.showToast({
        title: "语音输入功能开发中",
        icon: "none"
      });
    };
    const saveRecord = () => {
      if (formData.enableDeepAnalysis) {
        formData.deepAnswers = new Array(deepQuestions.value.length).fill(void 0);
        showDeepAnalysis.value = true;
        currentQuestion.value = 0;
      } else {
        submitRecord();
      }
    };
    const selectAnswer = (answerIndex) => {
      formData.deepAnswers[currentQuestion.value] = answerIndex;
    };
    const nextQuestion = () => {
      if (currentQuestion.value < deepQuestions.value.length - 1) {
        currentQuestion.value++;
      } else {
        closeDeepAnalysis();
        submitRecord();
      }
    };
    const prevQuestion = () => {
      if (currentQuestion.value > 0) {
        currentQuestion.value--;
      }
    };
    const closeDeepAnalysis = () => {
      showDeepAnalysis.value = false;
    };
    const submitRecord = async () => {
      const token = utils_api.getToken();
      if (!token) {
        common_vendor.index.showToast({
          title: "请先登录",
          icon: "none"
        });
        common_vendor.index.navigateTo({
          url: "/pages/login/index"
        });
        return;
      }
      if (!formData.text.trim()) {
        common_vendor.index.showToast({
          title: "请输入情绪描述",
          icon: "none"
        });
        return;
      }
      if (formData.emotions.length === 0) {
        common_vendor.index.showToast({
          title: "请选择至少一种情绪",
          icon: "none"
        });
        return;
      }
      if (!formData.scene) {
        common_vendor.index.showToast({
          title: "请选择相关场景",
          icon: "none"
        });
        return;
      }
      try {
        common_vendor.index.showLoading({
          title: "保存中..."
        });
        const recordData = {
          emotion_type: mapEmotionToBackend(formData.emotions[0]),
          // 主要情绪
          intensity: formData.intensity,
          scenario: mapSceneToBackend(formData.scene),
          description: formData.text,
          triggers: formData.triggers.length > 0 ? formData.triggers : ["手动记录"],
          physical_symptoms: formData.physicalSymptoms.length > 0 ? formData.physicalSymptoms : [],
          coping_methods: formData.copingMethods.length > 0 ? formData.copingMethods : ["情绪记录"],
          people_involved: [],
          location: "",
          weather: "",
          effectiveness_rating: null,
          is_private: false,
          enable_ai_analysis: formData.enableDeepAnalysis
        };
        if (formData.enableDeepAnalysis && formData.deepAnswers.length > 0) {
          const analysisData = deepQuestions.value.map((q, index) => {
            if (formData.deepAnswers[index] !== void 0) {
              return `${q.question}: ${q.options[formData.deepAnswers[index]]}`;
            }
            return null;
          }).filter((item) => Boolean(item));
          recordData.triggers = [...recordData.triggers, ...analysisData];
        }
        console.log("提交记录数据:", recordData);
        const response = await utils_api.emotionAPI.createRecord(recordData);
        common_vendor.index.hideLoading();
        common_vendor.index.showToast({
          title: "记录保存成功",
          icon: "success"
        });
        clearDraft();
        resetForm();
        setTimeout(() => {
          if (formData.enableDeepAnalysis) {
            common_vendor.index.navigateTo({
              url: `/pages/analysis/index?recordId=${response.id}`
            });
          } else {
            common_vendor.index.switchTab({
              url: "/pages/index/index"
            });
          }
        }, 1500);
      } catch (error) {
        common_vendor.index.hideLoading();
        console.error("保存记录失败:", error);
        common_vendor.index.showToast({
          title: (error == null ? void 0 : error.message) || "保存失败，请重试",
          icon: "none",
          duration: 3e3
        });
      }
    };
    const resetForm = () => {
      formData.text = "";
      formData.emotions = [];
      formData.intensity = 5;
      formData.scene = "";
      formData.triggers = [];
      formData.physicalSymptoms = [];
      formData.copingMethods = [];
      formData.enableDeepAnalysis = false;
      formData.deepAnswers = [];
      currentStep.value = 1;
      showDeepAnalysis.value = false;
      currentQuestion.value = 0;
    };
    const mapEmotionToBackend = (emotion) => {
      const emotionMap = {
        "快乐": "happy",
        "焦虑": "anxious",
        "愤怒": "angry",
        "悲伤": "sad",
        "平静": "calm",
        "恐惧": "fearful"
      };
      return emotionMap[emotion] || "happy";
    };
    const mapSceneToBackend = (scene) => {
      const sceneMap = {
        "工作": "work",
        "学习": "study",
        "生活": "personal",
        "社交": "social",
        "健康": "health",
        "其他": "other"
      };
      return sceneMap[scene] || "personal";
    };
    const saveDraft = () => {
      const draftData = {
        ...formData,
        currentStep: currentStep.value,
        timestamp: Date.now()
      };
      common_vendor.index.setStorageSync("emotion_record_draft", draftData);
      common_vendor.index.showToast({
        title: "草稿已保存",
        icon: "success",
        duration: 1500
      });
    };
    const loadDraft = () => {
      try {
        const draft = common_vendor.index.getStorageSync("emotion_record_draft");
        if (draft && draft.timestamp) {
          const now = Date.now();
          const draftAge = now - draft.timestamp;
          const oneDayMs = 24 * 60 * 60 * 1e3;
          if (draftAge < oneDayMs) {
            common_vendor.index.showModal({
              title: "发现草稿",
              content: "检测到未完成的记录，是否继续编辑？",
              success: (res) => {
                if (res.confirm) {
                  Object.assign(formData, draft);
                  currentStep.value = draft.currentStep || 1;
                  common_vendor.index.showToast({
                    title: "草稿已恢复",
                    icon: "success"
                  });
                } else {
                  common_vendor.index.removeStorageSync("emotion_record_draft");
                }
              }
            });
          } else {
            common_vendor.index.removeStorageSync("emotion_record_draft");
          }
        }
      } catch (error) {
        console.log("加载草稿失败:", error);
      }
    };
    const clearDraft = () => {
      common_vendor.index.removeStorageSync("emotion_record_draft");
    };
    common_vendor.onMounted(() => {
      const pages = getCurrentPages();
      const currentPage = pages[pages.length - 1];
      const options = (currentPage == null ? void 0 : currentPage.options) || {};
      if (options.quickEmotion) {
        formData.emotions = [options.quickEmotion];
        currentStep.value = 2;
      } else {
        loadDraft();
      }
    });
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: common_vendor.o(saveDraft),
        b: currentStep.value >= 1 ? 1 : "",
        c: currentStep.value >= 2 ? 1 : "",
        d: currentStep.value >= 2 ? 1 : "",
        e: currentStep.value >= 3 ? 1 : "",
        f: currentStep.value >= 3 ? 1 : "",
        g: currentStep.value >= 4 ? 1 : "",
        h: currentStep.value >= 4 ? 1 : "",
        i: currentStep.value === 1
      }, currentStep.value === 1 ? {
        j: common_vendor.o([($event) => formData.text = $event.detail.value, onTextInput]),
        k: formData.text,
        l: common_vendor.t(formData.text.length),
        m: common_vendor.o(startVoiceInput),
        n: common_vendor.o(nextStep),
        o: !formData.text.trim()
      } : {}, {
        p: currentStep.value === 2
      }, currentStep.value === 2 ? common_vendor.e({
        q: common_vendor.f(emotions.value, (emotion, k0, i0) => {
          return {
            a: common_vendor.t(emotion.icon),
            b: common_vendor.t(emotion.name),
            c: common_vendor.t(emotion.description),
            d: emotion.name,
            e: formData.emotions.includes(emotion.name) ? 1 : "",
            f: common_vendor.o(($event) => toggleEmotion(emotion.name), emotion.name)
          };
        }),
        r: formData.emotions.length > 0
      }, formData.emotions.length > 0 ? {
        s: common_vendor.t(formData.intensity),
        t: formData.intensity,
        v: common_vendor.o(onIntensityChange)
      } : {}, {
        w: common_vendor.o(prevStep),
        x: common_vendor.o(nextStep),
        y: formData.emotions.length === 0
      }) : {}, {
        z: currentStep.value === 3
      }, currentStep.value === 3 ? {
        A: common_vendor.f(scenes.value, (scene, k0, i0) => {
          return common_vendor.e({
            a: common_vendor.t(scene.icon),
            b: common_vendor.t(scene.name),
            c: common_vendor.t(scene.description),
            d: formData.scene === scene.name
          }, formData.scene === scene.name ? {} : {}, {
            e: scene.name,
            f: formData.scene === scene.name ? 1 : "",
            g: common_vendor.o(($event) => selectScene(scene.name), scene.name)
          });
        }),
        B: formData.enableDeepAnalysis,
        C: common_vendor.o(onDeepAnalysisChange),
        D: common_vendor.o(toggleDeepAnalysis),
        E: common_vendor.o(prevStep),
        F: common_vendor.o(nextStep),
        G: !formData.scene
      } : {}, {
        H: currentStep.value === 4
      }, currentStep.value === 4 ? common_vendor.e({
        I: common_vendor.f(triggerOptions.value, (trigger, k0, i0) => {
          return {
            a: common_vendor.t(trigger),
            b: trigger,
            c: formData.triggers.includes(trigger) ? 1 : "",
            d: common_vendor.o(($event) => toggleTrigger(trigger), trigger)
          };
        }),
        J: common_vendor.f(symptomOptions.value, (symptom, k0, i0) => {
          return {
            a: common_vendor.t(symptom),
            b: symptom,
            c: formData.physicalSymptoms.includes(symptom) ? 1 : "",
            d: common_vendor.o(($event) => toggleSymptom(symptom), symptom)
          };
        }),
        K: common_vendor.f(copingOptions.value, (method, k0, i0) => {
          return {
            a: common_vendor.t(method),
            b: method,
            c: formData.copingMethods.includes(method) ? 1 : "",
            d: common_vendor.o(($event) => toggleCoping(method), method)
          };
        }),
        L: formData.enableDeepAnalysis,
        M: common_vendor.o(onDeepAnalysisChange),
        N: common_vendor.o(toggleDeepAnalysis),
        O: common_vendor.t(formData.text || "暂无"),
        P: common_vendor.t(formData.emotions.join("、") || "暂无"),
        Q: common_vendor.t(formData.intensity),
        R: common_vendor.t(formData.scene || "暂无"),
        S: formData.triggers.length > 0
      }, formData.triggers.length > 0 ? {
        T: common_vendor.t(formData.triggers.join("、"))
      } : {}, {
        U: formData.physicalSymptoms.length > 0
      }, formData.physicalSymptoms.length > 0 ? {
        V: common_vendor.t(formData.physicalSymptoms.join("、"))
      } : {}, {
        W: formData.copingMethods.length > 0
      }, formData.copingMethods.length > 0 ? {
        X: common_vendor.t(formData.copingMethods.join("、"))
      } : {}, {
        Y: common_vendor.o(prevStep),
        Z: common_vendor.t(formData.enableDeepAnalysis ? "继续深度分析" : "保存记录"),
        aa: common_vendor.o(saveRecord)
      }) : {}, {
        ab: showDeepAnalysis.value
      }, showDeepAnalysis.value ? common_vendor.e({
        ac: common_vendor.t(currentQuestion.value + 1),
        ad: common_vendor.t(deepQuestions.value.length),
        ae: common_vendor.o(closeDeepAnalysis),
        af: common_vendor.t(deepQuestions.value[currentQuestion.value].question),
        ag: common_vendor.f(deepQuestions.value[currentQuestion.value].options, (option, index, i0) => {
          return {
            a: common_vendor.t(option),
            b: index,
            c: formData.deepAnswers[currentQuestion.value] === index ? 1 : "",
            d: common_vendor.o(($event) => selectAnswer(index), index)
          };
        }),
        ah: currentQuestion.value > 0
      }, currentQuestion.value > 0 ? {
        ai: common_vendor.o(prevQuestion)
      } : {}, {
        aj: common_vendor.t(currentQuestion.value === deepQuestions.value.length - 1 ? "完成分析" : "下一题"),
        ak: common_vendor.o(nextQuestion),
        al: formData.deepAnswers[currentQuestion.value] === void 0
      }) : {});
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-e218755a"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/record/index.vue"]]);
wx.createPage(MiniProgramPage);
