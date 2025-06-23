"use strict";
const common_vendor = require("../../common/vendor.js");
const utils_api = require("../../utils/api.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "history",
  setup(__props) {
    const analyses = common_vendor.ref([]);
    const isLoading = common_vendor.ref(false);
    const hasMore = common_vendor.ref(true);
    const currentPage = common_vendor.ref(1);
    const selectedTimeRange = common_vendor.ref(0);
    const selectedSort = common_vendor.ref(0);
    const timeRangeOptions = common_vendor.ref([
      "全部时间",
      "最近一周",
      "最近一月",
      "最近三月"
    ]);
    const sortOptions = common_vendor.ref([
      "按时间排序",
      "按评分排序",
      "按置信度排序"
    ]);
    const totalAnalyses = common_vendor.computed(() => analyses.value.length);
    const averageScore = common_vendor.computed(() => {
      if (analyses.value.length === 0)
        return "0.0";
      const total = analyses.value.reduce((sum, analysis) => sum + (analysis.user_rating || 0), 0);
      return (total / analyses.value.length).toFixed(1);
    });
    const filteredAnalyses = common_vendor.computed(() => {
      let filtered = [...analyses.value];
      const now = /* @__PURE__ */ new Date();
      switch (selectedTimeRange.value) {
        case 1:
          const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1e3);
          filtered = filtered.filter((a) => new Date(a.created_at) >= weekAgo);
          break;
        case 2:
          const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1e3);
          filtered = filtered.filter((a) => new Date(a.created_at) >= monthAgo);
          break;
        case 3:
          const threeMonthsAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1e3);
          filtered = filtered.filter((a) => new Date(a.created_at) >= threeMonthsAgo);
          break;
      }
      switch (selectedSort.value) {
        case 0:
          filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
          break;
        case 1:
          filtered.sort((a, b) => (b.user_rating || 0) - (a.user_rating || 0));
          break;
        case 2:
          filtered.sort((a, b) => b.confidence_score - a.confidence_score);
          break;
      }
      return filtered;
    });
    const loadAnalysisHistory = async (page = 1) => {
      try {
        isLoading.value = true;
        const response = await utils_api.aiAPI.getAnalysisHistory({
          page,
          page_size: 10
        });
        if (page === 1) {
          analyses.value = response.results || [];
        } else {
          analyses.value.push(...response.results || []);
        }
        hasMore.value = !!response.next;
        currentPage.value = page;
      } catch (error) {
        console.error("加载分析历史失败:", error);
        common_vendor.index.showToast({
          title: "加载失败，请重试",
          icon: "none"
        });
      } finally {
        isLoading.value = false;
      }
    };
    const loadMore = () => {
      if (!hasMore.value || isLoading.value)
        return;
      loadAnalysisHistory(currentPage.value + 1);
    };
    const onTimeRangeChange = (e) => {
      selectedTimeRange.value = e.detail.value;
    };
    const onSortChange = (e) => {
      selectedSort.value = e.detail.value;
    };
    const formatDate = (dateString) => {
      const date = new Date(dateString);
      const now = /* @__PURE__ */ new Date();
      const diffTime = now.getTime() - date.getTime();
      const diffDays = Math.floor(diffTime / (1e3 * 60 * 60 * 24));
      if (diffDays === 0)
        return "今天";
      if (diffDays === 1)
        return "昨天";
      if (diffDays < 7)
        return `${diffDays}天前`;
      const month = date.getMonth() + 1;
      const day = date.getDate();
      return `${month}月${day}日`;
    };
    const formatTime = (dateString) => {
      const date = new Date(dateString);
      const hour = date.getHours().toString().padStart(2, "0");
      const minute = date.getMinutes().toString().padStart(2, "0");
      return `${hour}:${minute}`;
    };
    const getEmotionIcon = (emotion) => {
      const iconMap = {
        "happy": "😊",
        "sad": "😢",
        "angry": "😠",
        "anxious": "😰",
        "excited": "🤩",
        "calm": "😌",
        "confused": "😕"
      };
      return iconMap[emotion] || "😐";
    };
    const getEmotionName = (emotion) => {
      const nameMap = {
        "happy": "快乐",
        "sad": "悲伤",
        "angry": "愤怒",
        "anxious": "焦虑",
        "excited": "兴奋",
        "calm": "平静",
        "confused": "困惑"
      };
      return nameMap[emotion] || "未知";
    };
    const getStatusClass = (confidence) => {
      if (confidence >= 80)
        return "status-high";
      if (confidence >= 60)
        return "status-medium";
      return "status-low";
    };
    const getStatusText = (confidence) => {
      if (confidence >= 80)
        return "高置信度";
      if (confidence >= 60)
        return "中置信度";
      return "低置信度";
    };
    const viewAnalysisDetail = (analysis) => {
      common_vendor.index.navigateTo({
        url: `/pages/analysis/index?analysisId=${analysis.id}`
      });
    };
    const goToRecord = () => {
      common_vendor.index.switchTab({
        url: "/pages/record/index"
      });
    };
    common_vendor.onMounted(() => {
      loadAnalysisHistory();
    });
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: common_vendor.t(common_vendor.unref(totalAnalyses)),
        b: common_vendor.t(common_vendor.unref(averageScore)),
        c: common_vendor.t(timeRangeOptions.value[selectedTimeRange.value]),
        d: timeRangeOptions.value,
        e: selectedTimeRange.value,
        f: common_vendor.o(onTimeRangeChange),
        g: common_vendor.t(sortOptions.value[selectedSort.value]),
        h: sortOptions.value,
        i: selectedSort.value,
        j: common_vendor.o(onSortChange),
        k: common_vendor.f(common_vendor.unref(filteredAnalyses), (analysis, k0, i0) => {
          var _a;
          return common_vendor.e({
            a: common_vendor.t(formatDate(analysis.created_at)),
            b: common_vendor.t(formatTime(analysis.created_at)),
            c: common_vendor.t(getStatusText(analysis.confidence_score)),
            d: common_vendor.n(getStatusClass(analysis.confidence_score)),
            e: common_vendor.t(getEmotionIcon(analysis.primary_emotion)),
            f: common_vendor.t(getEmotionName(analysis.primary_emotion)),
            g: analysis.intensity_level * 10 + "%",
            h: common_vendor.t(analysis.intensity_level),
            i: common_vendor.t(((_a = analysis.key_insights[0]) == null ? void 0 : _a.content) || "暂无洞察"),
            j: analysis.key_insights.length > 1
          }, analysis.key_insights.length > 1 ? {
            k: common_vendor.t(analysis.key_insights.length - 1)
          } : {}, {
            l: analysis.suggestions.length > 0
          }, analysis.suggestions.length > 0 ? common_vendor.e({
            m: common_vendor.f(analysis.suggestions.slice(0, 3), (suggestion, index, i1) => {
              return {
                a: common_vendor.t(suggestion.title),
                b: index
              };
            }),
            n: analysis.suggestions.length > 3
          }, analysis.suggestions.length > 3 ? {
            o: common_vendor.t(analysis.suggestions.length - 3)
          } : {}) : {}, {
            p: analysis.confidence_score + "%",
            q: common_vendor.t(analysis.confidence_score),
            r: analysis.id,
            s: common_vendor.o(($event) => viewAnalysisDetail(analysis), analysis.id)
          });
        }),
        l: isLoading.value
      }, isLoading.value ? {} : {}, {
        m: !isLoading.value && common_vendor.unref(filteredAnalyses).length === 0
      }, !isLoading.value && common_vendor.unref(filteredAnalyses).length === 0 ? {
        n: common_vendor.o(goToRecord)
      } : {}, {
        o: hasMore.value && !isLoading.value
      }, hasMore.value && !isLoading.value ? {
        p: common_vendor.o(loadMore)
      } : {});
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-59893226"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/analysis/history.vue"]]);
wx.createPage(MiniProgramPage);
