"use strict";
const common_vendor = require("../../common/vendor.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const selectedCategory = common_vendor.ref("all");
    const showModal = common_vendor.ref(false);
    const selectedAchievement = common_vendor.ref(null);
    const achievementStats = common_vendor.ref({
      total: 48,
      unlocked: 12,
      points: 850,
      rank: "情绪探索者"
    });
    const categories = [
      { key: "all", name: "全部", icon: "🏆" },
      { key: "record", name: "记录", icon: "📝" },
      { key: "analysis", name: "分析", icon: "📊" },
      { key: "streak", name: "坚持", icon: "🔥" },
      { key: "social", name: "社交", icon: "👥" },
      { key: "milestone", name: "里程碑", icon: "🎯" },
      { key: "special", name: "特殊", icon: "⭐" }
    ];
    const levels = [
      { name: "情绪新手", requiredPoints: 0 },
      { name: "情绪学徒", requiredPoints: 100 },
      { name: "情绪探索者", requiredPoints: 500 },
      { name: "情绪分析师", requiredPoints: 1e3 },
      { name: "情绪大师", requiredPoints: 2e3 },
      { name: "情绪导师", requiredPoints: 5e3 }
    ];
    const achievements = common_vendor.ref([
      {
        id: 1,
        name: "初次记录",
        description: "完成第一次情绪记录",
        icon: "🌱",
        points: 10,
        rarity: "common",
        category: "record",
        unlocked: true,
        unlockedAt: "2024-06-01T10:30:00Z",
        hint: "开始你的情绪记录之旅"
      },
      {
        id: 2,
        name: "坚持一周",
        description: "连续7天记录情绪",
        icon: "🔥",
        points: 50,
        rarity: "rare",
        category: "streak",
        unlocked: true,
        unlockedAt: "2024-06-08T09:15:00Z",
        hint: "保持记录的习惯"
      },
      {
        id: 3,
        name: "AI分析师",
        description: "使用AI分析功能10次",
        icon: "🤖",
        points: 30,
        rarity: "common",
        category: "analysis",
        unlocked: false,
        progress: 6,
        target: 10,
        hint: "多使用AI分析功能了解自己"
      },
      {
        id: 4,
        name: "情绪光谱",
        description: "记录所有7种基础情绪",
        icon: "🌈",
        points: 80,
        rarity: "epic",
        category: "milestone",
        unlocked: false,
        progress: 5,
        target: 7,
        hint: "体验更多元的情绪"
      },
      {
        id: 5,
        name: "深度思考者",
        description: "完成50次深度分析",
        icon: "🧠",
        points: 100,
        rarity: "epic",
        category: "analysis",
        unlocked: false,
        progress: 23,
        target: 50,
        hint: "深入探索内心世界"
      },
      {
        id: 6,
        name: "月度坚持者",
        description: "连续30天记录情绪",
        icon: "📅",
        points: 200,
        rarity: "legendary",
        category: "streak",
        unlocked: false,
        progress: 18,
        target: 30,
        hint: "养成长期记录的好习惯"
      },
      {
        id: 7,
        name: "社交达人",
        description: "分享成就5次",
        icon: "📢",
        points: 40,
        rarity: "rare",
        category: "social",
        unlocked: true,
        unlockedAt: "2024-06-15T14:20:00Z",
        hint: "与朋友分享你的成长"
      },
      {
        id: 8,
        name: "午夜记录者",
        description: "在午夜12点记录情绪",
        icon: "🌙",
        points: 25,
        rarity: "rare",
        category: "special",
        unlocked: false,
        hint: "在特殊时刻记录特殊心情"
      }
    ]);
    const recentUnlocks = common_vendor.ref([
      {
        id: 7,
        name: "社交达人",
        icon: "📢",
        unlockedAt: "2024-06-15T14:20:00Z"
      },
      {
        id: 2,
        name: "坚持一周",
        icon: "🔥",
        unlockedAt: "2024-06-08T09:15:00Z"
      }
    ]);
    const filteredAchievements = common_vendor.computed(() => {
      if (selectedCategory.value === "all") {
        return achievements.value;
      }
      return achievements.value.filter((a) => a.category === selectedCategory.value);
    });
    const currentLevel = common_vendor.computed(() => {
      const points = achievementStats.value.points;
      for (let i = levels.length - 1; i >= 0; i--) {
        if (points >= levels[i].requiredPoints) {
          return levels[i];
        }
      }
      return levels[0];
    });
    const nextLevel = common_vendor.computed(() => {
      const currentIndex = levels.findIndex((l) => l.name === currentLevel.value.name);
      return currentIndex < levels.length - 1 ? levels[currentIndex + 1] : levels[levels.length - 1];
    });
    const levelProgress = common_vendor.computed(() => {
      const points = achievementStats.value.points;
      const currentPoints = currentLevel.value.requiredPoints;
      const nextPoints = nextLevel.value.requiredPoints;
      if (currentPoints === nextPoints)
        return 100;
      return (points - currentPoints) / (nextPoints - currentPoints) * 100;
    });
    const selectCategory = (category) => {
      selectedCategory.value = category;
    };
    const getRarityText = (rarity) => {
      const rarityMap = {
        common: "普通",
        rare: "稀有",
        epic: "史诗",
        legendary: "传说"
      };
      return rarityMap[rarity] || "普通";
    };
    const formatUnlockTime = (timeStr) => {
      if (!timeStr)
        return "";
      const date = new Date(timeStr);
      const now = /* @__PURE__ */ new Date();
      const diff = now.getTime() - date.getTime();
      const days = Math.floor(diff / (1e3 * 60 * 60 * 24));
      if (days === 0) {
        return "今天解锁";
      } else if (days === 1) {
        return "昨天解锁";
      } else if (days < 7) {
        return `${days}天前解锁`;
      } else {
        return date.toLocaleDateString("zh-CN");
      }
    };
    const formatRecentTime = (timeStr) => {
      if (!timeStr)
        return "";
      const date = new Date(timeStr);
      const now = /* @__PURE__ */ new Date();
      const diff = now.getTime() - date.getTime();
      const hours = Math.floor(diff / (1e3 * 60 * 60));
      const days = Math.floor(hours / 24);
      if (hours < 1) {
        return "刚刚";
      } else if (hours < 24) {
        return `${hours}小时前`;
      } else {
        return `${days}天前`;
      }
    };
    const viewAchievementDetail = (achievement) => {
      selectedAchievement.value = achievement;
      showModal.value = true;
    };
    const closeModal = () => {
      showModal.value = false;
      selectedAchievement.value = null;
    };
    const shareAchievement = () => {
      const achievement = selectedAchievement.value;
      if (!achievement)
        return;
      common_vendor.index.share({
        provider: "weixin",
        scene: "WXSceneSession",
        type: 0,
        href: "",
        title: `我获得了成就：${achievement.name}`,
        summary: achievement.description,
        imageUrl: "",
        success: () => {
          common_vendor.index.showToast({
            title: "分享成功",
            icon: "success"
          });
          closeModal();
        },
        fail: () => {
          common_vendor.index.showToast({
            title: "分享失败",
            icon: "none"
          });
        }
      });
    };
    const viewAllRecent = () => {
      common_vendor.index.showModal({
        title: "最近解锁",
        content: "查看所有最近解锁的成就",
        showCancel: false
      });
    };
    common_vendor.onMounted(() => {
      console.log("加载成就系统数据");
    });
    return (_ctx, _cache) => {
      var _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p, _q, _r, _s, _t;
      return common_vendor.e({
        a: common_vendor.t(achievementStats.value.total),
        b: common_vendor.t(achievementStats.value.unlocked),
        c: common_vendor.t(achievementStats.value.points),
        d: common_vendor.t(achievementStats.value.rank),
        e: common_vendor.t(common_vendor.unref(currentLevel).name),
        f: common_vendor.t(common_vendor.unref(nextLevel).name),
        g: common_vendor.unref(levelProgress) + "%",
        h: common_vendor.t(achievementStats.value.points),
        i: common_vendor.t(common_vendor.unref(nextLevel).requiredPoints),
        j: common_vendor.f(categories, (category, k0, i0) => {
          return {
            a: common_vendor.t(category.icon),
            b: common_vendor.t(category.name),
            c: category.key,
            d: selectedCategory.value === category.key ? 1 : "",
            e: common_vendor.o(($event) => selectCategory(category.key), category.key)
          };
        }),
        k: common_vendor.f(common_vendor.unref(filteredAchievements), (achievement, k0, i0) => {
          return common_vendor.e({
            a: common_vendor.t(achievement.icon),
            b: achievement.unlocked && achievement.rarity !== "common"
          }, achievement.unlocked && achievement.rarity !== "common" ? {} : {}, {
            c: achievement.unlocked
          }, achievement.unlocked ? {} : {}, {
            d: common_vendor.t(achievement.name),
            e: common_vendor.t(achievement.description),
            f: !achievement.unlocked && achievement.progress !== void 0
          }, !achievement.unlocked && achievement.progress !== void 0 ? {
            g: achievement.progress / achievement.target * 100 + "%",
            h: common_vendor.t(achievement.progress),
            i: common_vendor.t(achievement.target)
          } : {}, {
            j: achievement.unlocked
          }, achievement.unlocked ? {
            k: common_vendor.t(formatUnlockTime(achievement.unlockedAt))
          } : {}, {
            l: common_vendor.t(achievement.points),
            m: common_vendor.t(getRarityText(achievement.rarity)),
            n: common_vendor.n(achievement.rarity),
            o: achievement.id,
            p: achievement.unlocked ? 1 : "",
            q: !achievement.unlocked ? 1 : "",
            r: achievement.rarity === "rare" ? 1 : "",
            s: achievement.rarity === "epic" ? 1 : "",
            t: achievement.rarity === "legendary" ? 1 : "",
            v: common_vendor.o(($event) => viewAchievementDetail(achievement), achievement.id)
          });
        }),
        l: recentUnlocks.value.length > 0
      }, recentUnlocks.value.length > 0 ? {
        m: common_vendor.o(viewAllRecent),
        n: common_vendor.f(recentUnlocks.value, (achievement, k0, i0) => {
          return {
            a: common_vendor.t(achievement.icon),
            b: common_vendor.t(achievement.name),
            c: common_vendor.t(formatRecentTime(achievement.unlockedAt)),
            d: achievement.id,
            e: common_vendor.o(($event) => viewAchievementDetail(achievement), achievement.id)
          };
        })
      } : {}, {
        o: showModal.value
      }, showModal.value ? common_vendor.e({
        p: common_vendor.t((_a = selectedAchievement.value) == null ? void 0 : _a.icon),
        q: common_vendor.n((_b = selectedAchievement.value) == null ? void 0 : _b.rarity),
        r: common_vendor.t((_c = selectedAchievement.value) == null ? void 0 : _c.name),
        s: common_vendor.t(getRarityText((_d = selectedAchievement.value) == null ? void 0 : _d.rarity)),
        t: common_vendor.n((_e = selectedAchievement.value) == null ? void 0 : _e.rarity),
        v: common_vendor.t((_f = selectedAchievement.value) == null ? void 0 : _f.description),
        w: common_vendor.t((_g = selectedAchievement.value) == null ? void 0 : _g.points),
        x: (_h = selectedAchievement.value) == null ? void 0 : _h.unlocked
      }, ((_i = selectedAchievement.value) == null ? void 0 : _i.unlocked) ? {
        y: common_vendor.t(formatUnlockTime((_j = selectedAchievement.value) == null ? void 0 : _j.unlockedAt))
      } : {}, {
        z: !((_k = selectedAchievement.value) == null ? void 0 : _k.unlocked)
      }, !((_l = selectedAchievement.value) == null ? void 0 : _l.unlocked) ? {
        A: common_vendor.t(((_m = selectedAchievement.value) == null ? void 0 : _m.progress) || 0),
        B: common_vendor.t((_n = selectedAchievement.value) == null ? void 0 : _n.target)
      } : {}, {
        C: common_vendor.t(getRarityText((_o = selectedAchievement.value) == null ? void 0 : _o.rarity)),
        D: !((_p = selectedAchievement.value) == null ? void 0 : _p.unlocked)
      }, !((_q = selectedAchievement.value) == null ? void 0 : _q.unlocked) ? {
        E: common_vendor.t((_r = selectedAchievement.value) == null ? void 0 : _r.hint)
      } : {}, {
        F: common_vendor.o(closeModal),
        G: (_s = selectedAchievement.value) == null ? void 0 : _s.unlocked
      }, ((_t = selectedAchievement.value) == null ? void 0 : _t.unlocked) ? {
        H: common_vendor.o(shareAchievement)
      } : {}, {
        I: common_vendor.o(() => {
        }),
        J: common_vendor.o(closeModal)
      }) : {});
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-4a7a9692"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/achievements/index.vue"]]);
wx.createPage(MiniProgramPage);
