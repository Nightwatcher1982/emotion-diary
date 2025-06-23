"use strict";
const common_vendor = require("../../common/vendor.js");
if (!Math) {
  SimpleChart();
}
const SimpleChart = () => "../../components/SimpleChart.js";
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const selectedTime = common_vendor.ref("week");
    const chartType = common_vendor.ref("line");
    const activePatternTab = common_vendor.ref("week");
    const timeOptions = common_vendor.ref([
      { value: "week", label: "本周" },
      { value: "month", label: "本月" },
      { value: "quarter", label: "本季度" },
      { value: "year", label: "本年" }
    ]);
    const patternTabs = common_vendor.ref([
      { type: "week", label: "周模式" },
      { type: "hour", label: "时段模式" }
    ]);
    const statsData = common_vendor.ref({
      totalRecords: 28,
      averageMood: 6.8,
      streakDays: 7,
      improvementRate: 15
    });
    const overviewItems = common_vendor.computed(() => [
      {
        icon: "📝",
        value: statsData.value.totalRecords,
        label: "总记录数"
      },
      {
        icon: "😊",
        value: statsData.value.averageMood.toFixed(1),
        label: "平均情绪"
      },
      {
        icon: "🔥",
        value: statsData.value.streakDays,
        label: "连续天数"
      },
      {
        icon: "📈",
        value: `${statsData.value.improvementRate}%`,
        label: "改善率"
      }
    ]);
    const emotionDistribution = common_vendor.ref([
      { name: "快乐", value: 33.3, color: "#FFD700" },
      { name: "焦虑", value: 18.2, color: "#FF8C00" },
      { name: "平静", value: 15.9, color: "#87CEEB" },
      { name: "悲伤", value: 13.6, color: "#6495ED" },
      { name: "愤怒", value: 11.4, color: "#DC143C" },
      { name: "恐惧", value: 7.6, color: "#9370DB" }
    ]);
    const sceneStats = common_vendor.ref([
      { name: "个人", value: 18, color: "#FFB6C1" },
      { name: "工作", value: 8, color: "#4A90E2" },
      { name: "社交", value: 6, color: "#90EE90" },
      { name: "学习", value: 4, color: "#20B2AA" },
      { name: "健康", value: 3, color: "#DDA0DD" },
      { name: "其他", value: 2, color: "#F0E68C" }
    ]);
    const weekPattern = common_vendor.ref([
      { name: "周一", value: 6.2, color: "#4A90E2" },
      { name: "周二", value: 7.1, color: "#4A90E2" },
      { name: "周三", value: 5.8, color: "#4A90E2" },
      { name: "周四", value: 6.9, color: "#4A90E2" },
      { name: "周五", value: 7.5, color: "#4A90E2" },
      { name: "周六", value: 8.2, color: "#4A90E2" },
      { name: "周日", value: 7.8, color: "#4A90E2" }
    ]);
    const hourPattern = common_vendor.ref([
      { hour: "早晨", value: 7.2, color: "#FFD700" },
      { hour: "上午", value: 6.8, color: "#FFA500" },
      { hour: "中午", value: 6.5, color: "#FF8C00" },
      { hour: "下午", value: 6.2, color: "#FF6347" },
      { hour: "傍晚", value: 7, color: "#9370DB" },
      { hour: "晚上", value: 7.5, color: "#4169E1" }
    ]);
    const emotionWords = common_vendor.ref([
      { text: "开心", size: 48, color: "#FFD700" },
      { text: "焦虑", size: 36, color: "#FF8C00" },
      { text: "平静", size: 32, color: "#87CEEB" },
      { text: "压力", size: 28, color: "#DC143C" },
      { text: "满足", size: 24, color: "#90EE90" },
      { text: "疲惫", size: 20, color: "#9370DB" }
    ]);
    const achievements = common_vendor.ref([
      {
        id: 1,
        name: "初心者",
        icon: "🌱",
        description: "完成第一次情绪记录",
        unlocked: true,
        progress: 1,
        target: 1
      },
      {
        id: 2,
        name: "坚持者",
        icon: "🔥",
        description: "连续记录7天",
        unlocked: true,
        progress: 7,
        target: 7
      },
      {
        id: 3,
        name: "探索者",
        icon: "🔍",
        description: "尝试所有情绪类型",
        unlocked: false,
        progress: 4,
        target: 6
      },
      {
        id: 4,
        name: "分析师",
        icon: "📊",
        description: "使用AI分析10次",
        unlocked: false,
        progress: 6,
        target: 10
      }
    ]);
    const unlockedAchievements = common_vendor.computed(
      () => achievements.value.filter((a) => a.unlocked).length
    );
    const totalAchievements = common_vendor.computed(() => achievements.value.length);
    const selectTime = (value) => {
      selectedTime.value = value;
      loadStatsData();
    };
    const toggleChartType = () => {
      chartType.value = chartType.value === "line" ? "bar" : "line";
    };
    const switchPatternTab = (type) => {
      activePatternTab.value = type;
    };
    const getTrendDescription = () => {
      const trend = statsData.value.improvementRate;
      if (trend > 10)
        return "情绪呈上升趋势 📈";
      if (trend > 0)
        return "情绪保持稳定 ➡️";
      return "需要关注情绪变化 📉";
    };
    const getDominantEmotion = () => {
      const dominant = emotionDistribution.value[0];
      return `${dominant.name} ${dominant.value}%`;
    };
    const onChartClick = (data) => {
      console.log("Chart clicked:", data);
      common_vendor.index.showToast({
        title: `查看${data.name}详情`,
        icon: "none"
      });
    };
    const onEmotionClick = (data) => {
      console.log("Emotion clicked:", data);
      common_vendor.index.showToast({
        title: `${data.name}: ${data.value}%`,
        icon: "none"
      });
    };
    const onSceneClick = (data) => {
      console.log("Scene clicked:", data);
      common_vendor.index.showToast({
        title: `${data.name}: ${data.value}次`,
        icon: "none"
      });
    };
    const onWeekClick = (data) => {
      console.log("Week clicked:", data);
      common_vendor.index.showToast({
        title: `${data.name}: ${data.value}分`,
        icon: "none"
      });
    };
    const onHeatmapClick = (data) => {
      console.log("Heatmap clicked:", data);
      common_vendor.index.showToast({
        title: `${data.hour}: ${data.value}分`,
        icon: "none"
      });
    };
    const viewWordDetail = (word) => {
      console.log("Word clicked:", word);
      common_vendor.index.showToast({
        title: `查看"${word.text}"相关记录`,
        icon: "none"
      });
    };
    const viewAchievement = (achievement) => {
      console.log("Achievement clicked:", achievement);
      const message = achievement.unlocked ? `已获得: ${achievement.description}` : `进度: ${achievement.progress}/${achievement.target}`;
      common_vendor.index.showToast({
        title: message,
        icon: "none"
      });
    };
    const exportReport = () => {
      common_vendor.index.showToast({
        title: "正在生成报告...",
        icon: "loading"
      });
      setTimeout(() => {
        common_vendor.index.showToast({
          title: "报告已生成",
          icon: "success"
        });
      }, 2e3);
    };
    const refreshData = () => {
      common_vendor.index.showToast({
        title: "正在刷新数据...",
        icon: "loading"
      });
      loadStatsData();
    };
    const shareStats = () => {
      common_vendor.index.showToast({
        title: "分享功能开发中",
        icon: "none"
      });
    };
    const loadStatsData = async () => {
      try {
        console.log("Loading stats data for:", selectedTime.value);
      } catch (error) {
        console.error("Failed to load stats:", error);
        common_vendor.index.showToast({
          title: "数据加载失败",
          icon: "none"
        });
      }
    };
    common_vendor.onMounted(() => {
      loadStatsData();
    });
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: common_vendor.t(statsData.value.totalRecords),
        b: common_vendor.f(timeOptions.value, (option, k0, i0) => {
          return {
            a: common_vendor.t(option.label),
            b: option.value,
            c: selectedTime.value === option.value ? 1 : "",
            d: common_vendor.o(($event) => selectTime(option.value), option.value)
          };
        }),
        c: common_vendor.f(common_vendor.unref(overviewItems), (item, index, i0) => {
          return {
            a: common_vendor.t(item.icon),
            b: common_vendor.t(item.value),
            c: common_vendor.t(item.label),
            d: index
          };
        }),
        d: common_vendor.t(getTrendDescription()),
        e: common_vendor.t(chartType.value === "line" ? "📈" : "📊"),
        f: common_vendor.o(toggleChartType),
        g: common_vendor.o(onChartClick),
        h: common_vendor.p({
          ["chart-type"]: chartType.value,
          data: weekPattern.value,
          title: "本周情绪变化"
        }),
        i: common_vendor.t(getDominantEmotion()),
        j: common_vendor.o(onEmotionClick),
        k: common_vendor.p({
          ["chart-type"]: "pie",
          data: emotionDistribution.value,
          title: "情绪类型分布"
        }),
        l: common_vendor.o(onSceneClick),
        m: common_vendor.p({
          ["chart-type"]: "bar",
          data: sceneStats.value,
          title: "不同场景记录次数"
        }),
        n: common_vendor.f(patternTabs.value, (tab, k0, i0) => {
          return {
            a: common_vendor.t(tab.label),
            b: tab.type,
            c: activePatternTab.value === tab.type ? 1 : "",
            d: common_vendor.o(($event) => switchPatternTab(tab.type), tab.type)
          };
        }),
        o: activePatternTab.value === "week"
      }, activePatternTab.value === "week" ? {
        p: common_vendor.o(onWeekClick),
        q: common_vendor.p({
          ["chart-type"]: "bar",
          data: weekPattern.value,
          title: "一周情绪变化"
        })
      } : {}, {
        r: activePatternTab.value === "hour"
      }, activePatternTab.value === "hour" ? {
        s: common_vendor.o(onHeatmapClick),
        t: common_vendor.p({
          ["chart-type"]: "heatmap",
          data: hourPattern.value,
          title: "时段活跃度热力图"
        })
      } : {}, {
        v: common_vendor.f(emotionWords.value, (word, k0, i0) => {
          return {
            a: common_vendor.t(word.text),
            b: word.color,
            c: word.text,
            d: word.size + "rpx",
            e: word.color,
            f: common_vendor.o(($event) => viewWordDetail(word), word.text)
          };
        }),
        w: common_vendor.t(common_vendor.unref(unlockedAchievements)),
        x: common_vendor.t(common_vendor.unref(totalAchievements)),
        y: common_vendor.t(Math.round(common_vendor.unref(unlockedAchievements) / common_vendor.unref(totalAchievements) * 100)),
        z: common_vendor.f(achievements.value, (achievement, k0, i0) => {
          return common_vendor.e({
            a: common_vendor.t(achievement.icon),
            b: achievement.unlocked
          }, achievement.unlocked ? {} : {}, {
            c: common_vendor.t(achievement.name),
            d: !achievement.unlocked
          }, !achievement.unlocked ? {
            e: achievement.progress / achievement.target * 100 + "%"
          } : {}, {
            f: achievement.unlocked
          }, achievement.unlocked ? {
            g: common_vendor.t(achievement.description)
          } : {}, {
            h: achievement.id,
            i: achievement.unlocked ? 1 : "",
            j: common_vendor.o(($event) => viewAchievement(achievement), achievement.id)
          });
        }),
        A: common_vendor.o(exportReport),
        B: common_vendor.o(refreshData),
        C: common_vendor.o(shareStats)
      });
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-e32fc36d"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/statistics/index.vue"]]);
wx.createPage(MiniProgramPage);
