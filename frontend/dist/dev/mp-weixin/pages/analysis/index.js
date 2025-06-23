"use strict";
const common_vendor = require("../../common/vendor.js");
const utils_api = require("../../utils/api.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const isLoading = common_vendor.ref(true);
    const activeTab = common_vendor.ref(0);
    const analysisData = common_vendor.ref({});
    const suggestionTabs = common_vendor.ref([
      { type: "immediate", title: "即时缓解", icon: "⚡" },
      { type: "longterm", title: "长期改善", icon: "🎯" },
      { type: "lifestyle", title: "生活方式", icon: "🌱" },
      { type: "social", title: "社交支持", icon: "👥" }
    ]);
    const currentSuggestions = common_vendor.computed(() => {
      if (!analysisData.value.suggestions)
        return [];
      const currentType = suggestionTabs.value[activeTab.value].type;
      return analysisData.value.suggestions[currentType] || [];
    });
    const formatTime = (timestamp) => {
      if (!timestamp)
        return "";
      const date = new Date(timestamp);
      return date.toLocaleString("zh-CN", {
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
      });
    };
    const switchTab = (index) => {
      activeTab.value = index;
    };
    const getDifficultyLabel = (difficulty) => {
      const difficultyMap = {
        "easy": "容易",
        "medium": "中等",
        "hard": "困难"
      };
      return difficultyMap[difficulty] || "中等";
    };
    const getTrendClass = (direction) => {
      if (direction === "上升")
        return "trend-up";
      if (direction === "下降")
        return "trend-down";
      return "trend-stable";
    };
    const getTrendDirection = (direction) => {
      return direction || "稳定";
    };
    const getAIStatusIcon = (data) => {
      return (data == null ? void 0 : data.ai_powered) ? "🤖" : "📊";
    };
    const getAIStatusText = (data) => {
      return (data == null ? void 0 : data.ai_powered) ? "AI驱动" : "数据分析";
    };
    const applySuggestion = (suggestion) => {
      common_vendor.index.showModal({
        title: "应用建议",
        content: `确定要将"${suggestion.title}"添加到今日计划吗？`,
        success: (res) => {
          if (res.confirm) {
            common_vendor.index.showToast({
              title: "已添加到计划",
              icon: "success"
            });
          }
        }
      });
    };
    const saveSuggestion = (suggestion) => {
      common_vendor.index.showToast({
        title: "已收藏",
        icon: "success"
      });
    };
    const completeTask = (index) => {
      if (analysisData.value.actionPlan && analysisData.value.actionPlan[index]) {
        analysisData.value.actionPlan[index].completed = true;
        common_vendor.index.showToast({
          title: "任务完成！",
          icon: "success"
        });
      }
    };
    const shareAnalysis = () => {
      common_vendor.index.share({
        provider: "weixin",
        type: 0,
        title: "我的情绪分析报告",
        summary: "通过AI分析，我对自己的情绪有了更深的了解",
        success: () => {
          common_vendor.index.showToast({
            title: "分享成功",
            icon: "success"
          });
        }
      });
    };
    const newRecord = () => {
      common_vendor.index.switchTab({
        url: "/pages/record/index"
      });
    };
    const reanalyze = async () => {
      common_vendor.index.showModal({
        title: "重新分析",
        content: "将基于最新的情绪记录重新进行AI分析，是否继续？",
        success: async (res) => {
          if (res.confirm) {
            await fetchAnalysisData();
          }
        }
      });
    };
    const saveAnalysis = async () => {
      try {
        const analysisResult = {
          analysis_data: analysisData.value,
          created_at: (/* @__PURE__ */ new Date()).toISOString(),
          analysis_type: "comprehensive"
        };
        common_vendor.index.setStorageSync("latest_analysis", analysisResult);
        common_vendor.index.showToast({
          title: "分析结果已保存",
          icon: "success"
        });
      } catch (error) {
        console.error("保存分析结果失败:", error);
        common_vendor.index.showToast({
          title: "保存失败",
          icon: "none"
        });
      }
    };
    const viewDetailedSuggestion = (suggestion) => {
      common_vendor.index.showModal({
        title: suggestion.title,
        content: `${suggestion.description}

难度：${getDifficultyLabel(suggestion.difficulty)}

是否要将此建议添加到今日计划中？`,
        confirmText: "添加",
        cancelText: "取消",
        success: (res) => {
          if (res.confirm) {
            applySuggestion(suggestion);
          }
        }
      });
    };
    const shareInsight = (suggestion) => {
      common_vendor.index.setClipboardData({
        data: `AI洞察: ${suggestion.content}`,
        success: () => {
          common_vendor.index.showToast({
            title: "已复制到剪贴板",
            icon: "success"
          });
        }
      });
    };
    const applyInsight = (insight) => {
      common_vendor.index.showToast({
        title: "已添加到行动计划",
        icon: "success"
      });
      const actionItem = {
        title: `实践：${insight.title}`,
        description: insight.content,
        completed: false
      };
      if (analysisData.value.actionPlan) {
        analysisData.value.actionPlan.push(actionItem);
      }
    };
    const onChartTouch = (e) => {
      console.log("图表触摸事件", e);
    };
    const mockAnalysisData = () => {
      return {
        timestamp: Date.now(),
        primaryEmotion: {
          name: "焦虑",
          icon: "😟",
          confidence: 85
        },
        emotionSpectrum: [
          { name: "焦虑", percentage: 45 },
          { name: "担心", percentage: 30 },
          { name: "紧张", percentage: 15 },
          { name: "不安", percentage: 10 }
        ],
        insights: [
          {
            type: "pattern",
            icon: "🔍",
            title: "情绪模式识别",
            content: "你的焦虑情绪主要出现在工作场景中，特别是面对截止日期时。这是一种常见的适应性焦虑，说明你对工作很负责。"
          },
          {
            type: "trigger",
            icon: "⚡",
            title: "触发因素分析",
            content: '分析显示，时间压力和完美主义倾向是你焦虑的主要触发因素。建议学习时间管理技巧和接受"足够好"的标准。'
          },
          {
            type: "strength",
            icon: "💪",
            title: "情绪优势",
            content: "你具有很好的情绪觉察能力，能够准确识别和描述自己的感受。这是情绪管理的重要基础。"
          }
        ],
        suggestions: {
          immediate: [
            {
              id: 1,
              title: "4-7-8呼吸法",
              description: "吸气4秒，屏气7秒，呼气8秒。重复3-4次可快速缓解焦虑。",
              difficulty: "easy"
            },
            {
              id: 2,
              title: "5-4-3-2-1接地技巧",
              description: "说出5个看到的、4个听到的、3个摸到的、2个闻到的、1个尝到的。",
              difficulty: "easy"
            }
          ],
          longterm: [
            {
              id: 3,
              title: "认知重构练习",
              description: "识别并挑战消极思维模式，用更平衡的想法替代。",
              difficulty: "medium"
            },
            {
              id: 4,
              title: "正念冥想",
              description: "每天10-15分钟的正念练习，提高情绪调节能力。",
              difficulty: "medium"
            }
          ],
          lifestyle: [
            {
              id: 5,
              title: "规律运动",
              description: "每周3-4次有氧运动，每次30分钟，有助于缓解焦虑。",
              difficulty: "medium"
            },
            {
              id: 6,
              title: "睡眠优化",
              description: "建立规律的睡眠时间，创造良好的睡眠环境。",
              difficulty: "hard"
            }
          ],
          social: [
            {
              id: 7,
              title: "寻求支持",
              description: "与信任的朋友或家人分享你的感受，获得情感支持。",
              difficulty: "medium"
            },
            {
              id: 8,
              title: "专业咨询",
              description: "如果焦虑持续影响生活，考虑寻求专业心理咨询师的帮助。",
              difficulty: "hard"
            }
          ]
        },
        trend: {
          average: 6.5,
          volatility: "中等",
          direction: "稳定"
        },
        deepAnalysis: {
          score: 78,
          dimensions: [
            { name: "情绪觉察", score: 8, description: "能够准确识别自己的情绪状态" },
            { name: "应对策略", score: 6, description: "具备一定的情绪调节技巧，但需要加强" },
            { name: "社会支持", score: 7, description: "拥有良好的社会支持网络" },
            { name: "生活平衡", score: 5, description: "工作与生活平衡需要改善" }
          ]
        },
        actionPlan: [
          { title: "练习深呼吸", description: "每天早晨练习5分钟深呼吸", completed: false },
          { title: "记录触发因素", description: "观察并记录引起焦虑的具体情况", completed: false },
          { title: "尝试正念练习", description: "下载冥想App，尝试10分钟正念练习", completed: false },
          { title: "制定时间计划", description: "为重要任务制定详细的时间计划", completed: false },
          { title: "与朋友交流", description: "主动与一位朋友分享近期的感受", completed: false },
          { title: "评估进展", description: "回顾本周的情绪变化和应对效果", completed: false },
          { title: "调整策略", description: "根据一周的实践调整应对策略", completed: false }
        ]
      };
    };
    const fetchAnalysisData = async (recordId) => {
      try {
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
        isLoading.value = true;
        let records = [];
        if (recordId) {
          const recordResponse = await utils_api.emotionAPI.getRecordById(recordId);
          records = [recordResponse];
        } else {
          const recentResponse = await utils_api.emotionAPI.getRecentRecords();
          records = recentResponse.results || recentResponse;
        }
        if (!records || records.length === 0) {
          common_vendor.index.showModal({
            title: "暂无数据",
            content: "还没有情绪记录，请先记录一些情绪数据",
            success: (res) => {
              if (res.confirm) {
                common_vendor.index.switchTab({
                  url: "/pages/record/index"
                });
              }
            }
          });
          isLoading.value = false;
          return;
        }
        const analysisRequest = {
          emotion_records: records.map((r) => r.id),
          analysis_type: "comprehensive",
          include_suggestions: true,
          include_trend: true
        };
        const aiResponse = await utils_api.aiAPI.requestAnalysis(analysisRequest);
        analysisData.value = processAIResponse(aiResponse, records);
        isLoading.value = false;
      } catch (error) {
        console.error("获取分析数据失败:", error);
        isLoading.value = false;
        common_vendor.index.showToast({
          title: "AI分析服务暂时不可用，显示示例数据",
          icon: "none",
          duration: 3e3
        });
        setTimeout(() => {
          analysisData.value = mockAnalysisData();
        }, 1e3);
      }
    };
    const processAIResponse = (aiResponse, records) => {
      const latestRecord = records[0];
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
      };
    };
    const getEmotionName = (emotionType) => {
      const emotionMap = {
        "happy": "快乐",
        "sad": "悲伤",
        "angry": "愤怒",
        "anxious": "焦虑",
        "calm": "平静",
        "fearful": "恐惧"
      };
      return emotionMap[emotionType] || "未知";
    };
    const getEmotionIcon = (emotionType) => {
      const iconMap = {
        "happy": "😄",
        "sad": "😢",
        "angry": "😡",
        "anxious": "😟",
        "calm": "😌",
        "fearful": "😨"
      };
      return iconMap[emotionType] || "😐";
    };
    const generateEmotionSpectrum = (record, aiResponse) => {
      const spectrum = aiResponse.emotion_spectrum || [];
      if (spectrum.length > 0) {
        return spectrum.map((item) => ({
          name: getEmotionName(item.emotion),
          percentage: Math.round(item.confidence * 100)
        }));
      }
      const intensity = record.intensity || 5;
      const mainEmotion = getEmotionName(record.emotion_type);
      return [
        { name: mainEmotion, percentage: intensity * 10 },
        { name: "中性", percentage: Math.max(0, 100 - intensity * 10) }
      ];
    };
    const parseInsights = (insights) => {
      if (insights.length === 0) {
        return [
          {
            type: "pattern",
            icon: "🔍",
            title: "情绪模式识别",
            content: "正在分析您的情绪模式，请多记录几次以获得更准确的分析。"
          }
        ];
      }
      return insights.map((insight) => ({
        type: insight.type || "general",
        icon: getInsightIcon(insight.type),
        title: insight.title || "AI洞察",
        content: insight.content || insight.description || ""
      }));
    };
    const getInsightIcon = (type) => {
      const iconMap = {
        "pattern": "🔍",
        "trigger": "⚡",
        "strength": "💪",
        "recommendation": "💡",
        "trend": "📈",
        "warning": "⚠️"
      };
      return iconMap[type] || "💭";
    };
    const parseSuggestions = (suggestions) => {
      const defaultSuggestions = {
        immediate: [
          {
            id: 1,
            title: "深呼吸练习",
            description: "进行3-5次深呼吸，帮助快速缓解紧张情绪。",
            difficulty: "easy"
          }
        ],
        longterm: [
          {
            id: 2,
            title: "情绪日记",
            description: "坚持记录情绪变化，提高情绪觉察能力。",
            difficulty: "medium"
          }
        ],
        lifestyle: [
          {
            id: 3,
            title: "规律作息",
            description: "保持规律的睡眠和饮食习惯。",
            difficulty: "medium"
          }
        ],
        social: [
          {
            id: 4,
            title: "寻求支持",
            description: "与信任的人分享你的感受。",
            difficulty: "easy"
          }
        ]
      };
      return {
        immediate: suggestions.immediate || defaultSuggestions.immediate,
        longterm: suggestions.longterm || defaultSuggestions.longterm,
        lifestyle: suggestions.lifestyle || defaultSuggestions.lifestyle,
        social: suggestions.social || defaultSuggestions.social
      };
    };
    const parseTrend = (trend) => {
      return {
        average: trend.average || 5,
        volatility: trend.volatility || "中等",
        direction: trend.direction || "稳定"
      };
    };
    const parseDeepAnalysis = (deepAnalysis) => {
      return {
        score: deepAnalysis.score || 70,
        dimensions: deepAnalysis.dimensions || [
          { name: "情绪觉察", score: 7, description: "能够识别自己的情绪状态" },
          { name: "应对策略", score: 6, description: "具备基本的情绪调节能力" }
        ]
      };
    };
    const parseActionPlan = (actionPlan) => {
      if (actionPlan.length === 0) {
        return [
          { title: "记录情绪", description: "每天记录一次情绪状态", completed: false },
          { title: "练习放松", description: "尝试深呼吸或冥想", completed: false },
          { title: "评估进展", description: "回顾一周的情绪变化", completed: false }
        ];
      }
      return actionPlan.map((plan) => ({
        title: plan.title || plan.name || "",
        description: plan.description || "",
        completed: plan.completed || false
      }));
    };
    common_vendor.onMounted(() => {
      const pages = getCurrentPages();
      const currentPage = pages[pages.length - 1];
      const options = currentPage.options || {};
      const recordId = options.recordId;
      fetchAnalysisData(recordId);
    });
    return (_ctx, _cache) => {
      var _a;
      return common_vendor.e({
        a: !isLoading.value
      }, !isLoading.value ? {
        b: common_vendor.t(getAIStatusIcon(analysisData.value)),
        c: common_vendor.t(getAIStatusText(analysisData.value)),
        d: ((_a = analysisData.value) == null ? void 0 : _a.ai_powered) ? 1 : "",
        e: common_vendor.o(saveAnalysis),
        f: common_vendor.o(reanalyze)
      } : {}, {
        g: isLoading.value
      }, isLoading.value ? {} : common_vendor.e({
        h: common_vendor.t(formatTime(analysisData.value.timestamp)),
        i: common_vendor.t(analysisData.value.primaryEmotion.icon),
        j: common_vendor.t(analysisData.value.primaryEmotion.name),
        k: common_vendor.t(analysisData.value.primaryEmotion.confidence),
        l: analysisData.value.emotionSpectrum
      }, analysisData.value.emotionSpectrum ? {
        m: common_vendor.f(analysisData.value.emotionSpectrum, (emotion, k0, i0) => {
          return {
            a: common_vendor.t(emotion.name),
            b: emotion.percentage + "%",
            c: common_vendor.t(emotion.percentage),
            d: emotion.name
          };
        })
      } : {}, {
        n: common_vendor.f(analysisData.value.insights, (insight, k0, i0) => {
          return common_vendor.e({
            a: common_vendor.t(insight.icon),
            b: common_vendor.t(insight.title),
            c: common_vendor.o(($event) => shareInsight(insight), insight.type),
            d: common_vendor.t(insight.content),
            e: insight.actionable
          }, insight.actionable ? {
            f: common_vendor.o(($event) => applyInsight(insight), insight.type)
          } : {}, {
            g: insight.type
          });
        }),
        o: common_vendor.f(suggestionTabs.value, (tab, index, i0) => {
          return {
            a: common_vendor.t(tab.icon),
            b: common_vendor.t(tab.title),
            c: tab.type,
            d: activeTab.value === index ? 1 : "",
            e: common_vendor.o(($event) => switchTab(index), tab.type)
          };
        }),
        p: common_vendor.f(common_vendor.unref(currentSuggestions), (suggestion, k0, i0) => {
          return {
            a: common_vendor.t(suggestion.title),
            b: common_vendor.t(getDifficultyLabel(suggestion.difficulty)),
            c: common_vendor.n(suggestion.difficulty),
            d: common_vendor.t(suggestion.description),
            e: common_vendor.o(($event) => applySuggestion(suggestion), suggestion.id),
            f: common_vendor.o(($event) => saveSuggestion(), suggestion.id),
            g: common_vendor.o(($event) => viewDetailedSuggestion(suggestion), suggestion.id),
            h: suggestion.id
          };
        }),
        q: analysisData.value.trend
      }, analysisData.value.trend ? {
        r: common_vendor.o(onChartTouch),
        s: common_vendor.t(analysisData.value.trend.average),
        t: common_vendor.t(analysisData.value.trend.volatility),
        v: common_vendor.t(getTrendDirection(analysisData.value.trend.direction)),
        w: common_vendor.n(getTrendClass(analysisData.value.trend.direction))
      } : {}, {
        x: analysisData.value.deepAnalysis
      }, analysisData.value.deepAnalysis ? {
        y: common_vendor.t(analysisData.value.deepAnalysis.score),
        z: common_vendor.f(analysisData.value.deepAnalysis.dimensions, (dimension, k0, i0) => {
          return {
            a: common_vendor.t(dimension.name),
            b: common_vendor.t(dimension.score),
            c: dimension.score / 10 * 100 + "%",
            d: common_vendor.t(dimension.description),
            e: dimension.name
          };
        })
      } : {}, {
        A: common_vendor.f(analysisData.value.actionPlan, (day, index, i0) => {
          return common_vendor.e({
            a: day.completed ? 1 : "",
            b: common_vendor.t(index + 1),
            c: common_vendor.t(day.title),
            d: common_vendor.t(day.description),
            e: !day.completed
          }, !day.completed ? {
            f: common_vendor.o(($event) => completeTask(index), index)
          } : {}, {
            g: index
          });
        })
      }), {
        B: !isLoading.value
      }, !isLoading.value ? {
        C: common_vendor.o(shareAnalysis),
        D: common_vendor.o(newRecord)
      } : {});
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-c6aadd33"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/analysis/index.vue"]]);
wx.createPage(MiniProgramPage);
