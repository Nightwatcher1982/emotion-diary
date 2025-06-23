"use strict";
const common_vendor = require("../../common/vendor.js");
const utils_api = require("../../utils/api.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const username = common_vendor.ref("小明");
    const todayEmotion = common_vendor.ref(null);
    const recentRecords = common_vendor.ref([]);
    const isLoading = common_vendor.ref(true);
    const user = common_vendor.ref(null);
    const weatherInfo = common_vendor.ref({
      icon: "☀️",
      desc: "晴朗"
    });
    const quickEmotions = common_vendor.ref([
      { name: "快乐", icon: "😄", type: "happy" },
      { name: "平静", icon: "😌", type: "calm" },
      { name: "焦虑", icon: "😟", type: "anxious" },
      { name: "悲伤", icon: "😢", type: "sad" },
      { name: "愤怒", icon: "😡", type: "angry" },
      { name: "恐惧", icon: "😨", type: "fearful" }
    ]);
    const greetingText = common_vendor.computed(() => {
      const hour = (/* @__PURE__ */ new Date()).getHours();
      if (hour < 6)
        return "夜深了";
      if (hour < 12)
        return "早上好";
      if (hour < 18)
        return "下午好";
      return "晚上好";
    });
    const greetingEmoji = common_vendor.computed(() => {
      const hour = (/* @__PURE__ */ new Date()).getHours();
      if (hour < 6)
        return "🌙";
      if (hour < 12)
        return "🌅";
      if (hour < 18)
        return "☀️";
      return "🌆";
    });
    const currentDate = common_vendor.computed(() => {
      const now = /* @__PURE__ */ new Date();
      const month = now.getMonth() + 1;
      const date = now.getDate();
      const weekdays = ["日", "一", "二", "三", "四", "五", "六"];
      const weekday = weekdays[now.getDay()];
      return `${month}月${date}日 星期${weekday}`;
    });
    const goToRecord = () => {
      common_vendor.index.switchTab({
        url: "/pages/record/index"
      });
    };
    const goToStatistics = () => {
      common_vendor.index.switchTab({
        url: "/pages/statistics/index"
      });
    };
    const quickRecord = async (emotion) => {
      try {
        common_vendor.index.showLoading({
          title: "记录中..."
        });
        const recordData = {
          emotion_type: emotion.type,
          intensity: 5,
          // 默认强度
          scenario: "personal",
          description: `快速记录${emotion.name}情绪`,
          triggers: ["快速记录"],
          physical_symptoms: [],
          coping_methods: []
        };
        await utils_api.emotionAPI.createRecord(recordData);
        common_vendor.index.hideLoading();
        common_vendor.index.showToast({
          title: `${emotion.name}情绪记录成功`,
          icon: "success"
        });
        await loadData();
      } catch (error) {
        common_vendor.index.hideLoading();
        console.error("快速记录失败:", error);
        common_vendor.index.showToast({
          title: "记录失败，请重试",
          icon: "none"
        });
      }
    };
    const viewRecord = (record) => {
      common_vendor.index.navigateTo({
        url: `/pages/analysis/index?recordId=${record.id}`
      });
    };
    const formatTime = (timestamp) => {
      const date = new Date(timestamp);
      const hour = date.getHours().toString().padStart(2, "0");
      const minute = date.getMinutes().toString().padStart(2, "0");
      return `${hour}:${minute}`;
    };
    const checkAuthAndLoadData = async () => {
      const token = utils_api.getToken();
      if (!token) {
        common_vendor.index.navigateTo({
          url: "/pages/login/index"
        });
        return;
      }
      user.value = utils_api.getUser();
      if (user.value) {
        username.value = user.value.nickname || user.value.username;
      }
      await loadData();
    };
    const loadData = async () => {
      isLoading.value = true;
      try {
        const [todayRecords, recentRecordsData] = await Promise.all([
          utils_api.emotionAPI.getTodayRecords(),
          utils_api.emotionAPI.getRecentRecords()
        ]);
        if (todayRecords && todayRecords.length > 0) {
          const latestRecord = todayRecords[0];
          todayEmotion.value = {
            name: getEmotionDisplayName(latestRecord.emotion_type),
            icon: getEmotionIcon(latestRecord.emotion_type),
            intensity: latestRecord.intensity,
            scene: getScenarioDisplayName(latestRecord.scenario),
            time: formatTime(latestRecord.emotion_time)
          };
        } else {
          todayEmotion.value = null;
        }
        recentRecords.value = recentRecordsData.slice(0, 3).map((record) => ({
          id: record.id,
          emotion: getEmotionIcon(record.emotion_type),
          name: getEmotionDisplayName(record.emotion_type),
          time: formatTime(record.emotion_time),
          content: record.description.length > 30 ? record.description.substring(0, 30) + "..." : record.description
        }));
      } catch (error) {
        console.error("加载数据失败:", error);
        common_vendor.index.showToast({
          title: "数据加载失败",
          icon: "none"
        });
        if ((error == null ? void 0 : error.message) === "Unauthorized") {
          common_vendor.index.navigateTo({
            url: "/pages/login/index"
          });
        }
      } finally {
        isLoading.value = false;
      }
    };
    const getEmotionDisplayName = (emotionType) => {
      const emotionMap = {
        "happy": "快乐",
        "sad": "悲伤",
        "angry": "愤怒",
        "anxious": "焦虑",
        "calm": "平静",
        "fearful": "恐惧",
        "excited": "兴奋",
        "frustrated": "沮丧",
        "grateful": "感激",
        "lonely": "孤独",
        "confident": "自信",
        "overwhelmed": "不知所措"
      };
      return emotionMap[emotionType] || emotionType;
    };
    const getEmotionIcon = (emotionType) => {
      const iconMap = {
        "happy": "😊",
        "sad": "😢",
        "angry": "😠",
        "anxious": "😰",
        "calm": "😌",
        "fearful": "😨",
        "excited": "🤩",
        "frustrated": "😤",
        "grateful": "🙏",
        "lonely": "😔",
        "confident": "😎",
        "overwhelmed": "🤯"
      };
      return iconMap[emotionType] || "😊";
    };
    const getScenarioDisplayName = (scenario) => {
      const scenarioMap = {
        "work": "工作",
        "study": "学习",
        "family": "家庭",
        "social": "社交",
        "health": "健康",
        "finance": "财务",
        "relationship": "感情",
        "personal": "个人",
        "entertainment": "娱乐",
        "travel": "旅行",
        "other": "其他"
      };
      return scenarioMap[scenario] || scenario;
    };
    common_vendor.onMounted(() => {
      checkAuthAndLoadData();
    });
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: common_vendor.t(common_vendor.unref(greetingText)),
        b: common_vendor.t(username.value || "用户"),
        c: common_vendor.t(common_vendor.unref(greetingEmoji)),
        d: common_vendor.t(common_vendor.unref(currentDate)),
        e: weatherInfo.value
      }, weatherInfo.value ? {
        f: common_vendor.t(weatherInfo.value.icon),
        g: common_vendor.t(weatherInfo.value.desc)
      } : {}, {
        h: todayEmotion.value
      }, todayEmotion.value ? {} : {}, {
        i: common_vendor.o(goToStatistics),
        j: todayEmotion.value
      }, todayEmotion.value ? {
        k: common_vendor.t(todayEmotion.value.icon),
        l: todayEmotion.value.intensity * 10 + "%",
        m: common_vendor.t(todayEmotion.value.intensity),
        n: common_vendor.t(todayEmotion.value.name),
        o: common_vendor.t(todayEmotion.value.scene),
        p: common_vendor.t(todayEmotion.value.time)
      } : {
        q: common_vendor.o(goToRecord)
      }, {
        r: common_vendor.f(quickEmotions.value, (emotion, k0, i0) => {
          return {
            a: common_vendor.n(emotion.type),
            b: common_vendor.t(emotion.icon),
            c: common_vendor.t(emotion.name),
            d: emotion.name,
            e: common_vendor.o(($event) => quickRecord(emotion), emotion.name)
          };
        }),
        s: recentRecords.value.length > 0
      }, recentRecords.value.length > 0 ? {
        t: common_vendor.o(goToStatistics),
        v: common_vendor.f(recentRecords.value, (record, index, i0) => {
          return common_vendor.e({
            a: common_vendor.t(record.emotion),
            b: common_vendor.t(record.name),
            c: common_vendor.t(record.time),
            d: common_vendor.t(record.content),
            e: index < recentRecords.value.length - 1
          }, index < recentRecords.value.length - 1 ? {} : {}, {
            f: record.id,
            g: common_vendor.o(($event) => viewRecord(record), record.id)
          });
        })
      } : {}, {
        w: common_vendor.o(goToRecord)
      });
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-83a5a03c"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/index/index.vue"]]);
wx.createPage(MiniProgramPage);
