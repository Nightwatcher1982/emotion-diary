"use strict";
const common_vendor = require("../../common/vendor.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "index",
  setup(__props) {
    const userInfo = common_vendor.ref({
      nickname: "小明",
      description: "记录生活，感受美好",
      avatar: "/static/default-avatar.png",
      joinDate: "2024-01-01"
    });
    const userStats = common_vendor.ref({
      totalDays: 28,
      totalRecords: 56,
      averageMood: 6.8,
      streakDays: 7
    });
    const backupStatus = common_vendor.ref("synced");
    const currentTheme = common_vendor.ref("浅色");
    const reminderEnabled = common_vendor.ref(true);
    const voiceEnabled = common_vendor.ref(false);
    const recentAchievements = common_vendor.ref([
      { id: 1, name: "坚持者", icon: "🔥" },
      { id: 2, name: "探索者", icon: "🔍" },
      { id: 3, name: "分析师", icon: "📊" }
    ]);
    const formatDate = (dateString) => {
      const date = new Date(dateString);
      const year = date.getFullYear();
      const month = date.getMonth() + 1;
      const day = date.getDate();
      return `${year}年${month}月${day}日`;
    };
    const changeAvatar = () => {
      common_vendor.index.chooseImage({
        count: 1,
        sizeType: ["compressed"],
        sourceType: ["album", "camera"],
        success: (res) => {
          userInfo.value.avatar = res.tempFilePaths[0];
          common_vendor.index.showToast({
            title: "头像更新成功",
            icon: "success"
          });
        }
      });
    };
    const editProfile = () => {
      common_vendor.index.navigateTo({
        url: "/pages/profile/edit"
      });
    };
    const exportData = () => {
      common_vendor.index.showActionSheet({
        itemList: ["导出为JSON", "导出为CSV", "导出为PDF"],
        success: (res) => {
          const formats = ["JSON", "CSV", "PDF"];
          common_vendor.index.showToast({
            title: `导出${formats[res.tapIndex]}中...`,
            icon: "loading"
          });
          setTimeout(() => {
            common_vendor.index.showToast({
              title: "导出成功",
              icon: "success"
            });
          }, 2e3);
        }
      });
    };
    const backupData = () => {
      if (backupStatus.value === "syncing")
        return;
      backupStatus.value = "syncing";
      common_vendor.index.showToast({
        title: "备份中...",
        icon: "loading"
      });
      setTimeout(() => {
        backupStatus.value = "synced";
        common_vendor.index.showToast({
          title: "备份成功",
          icon: "success"
        });
      }, 3e3);
    };
    const importData = () => {
      common_vendor.index.chooseFile({
        count: 1,
        extension: [".json", ".csv"],
        success: (res) => {
          common_vendor.index.showToast({
            title: "导入成功",
            icon: "success"
          });
        }
      });
    };
    const themeSettings = () => {
      common_vendor.index.showActionSheet({
        itemList: ["浅色主题", "深色主题", "跟随系统"],
        success: (res) => {
          const themes = ["浅色", "深色", "跟随系统"];
          currentTheme.value = themes[res.tapIndex];
          common_vendor.index.showToast({
            title: `已切换到${themes[res.tapIndex]}主题`,
            icon: "success"
          });
        }
      });
    };
    const reminderSettings = () => {
      common_vendor.index.navigateTo({
        url: "/pages/settings/reminder"
      });
    };
    const toggleReminder = (e) => {
      reminderEnabled.value = e.detail.value;
      const message = reminderEnabled.value ? "已开启提醒" : "已关闭提醒";
      common_vendor.index.showToast({
        title: message,
        icon: "success"
      });
    };
    const privacySettings = () => {
      common_vendor.index.navigateTo({
        url: "/pages/settings/privacy"
      });
    };
    const aiSettings = () => {
      common_vendor.index.navigateTo({
        url: "/pages/settings/ai"
      });
    };
    const toggleVoice = (e) => {
      voiceEnabled.value = e.detail.value;
      const message = voiceEnabled.value ? "已开启语音识别" : "已关闭语音识别";
      common_vendor.index.showToast({
        title: message,
        icon: "success"
      });
    };
    const analysisHistory = () => {
      common_vendor.index.navigateTo({
        url: "/pages/analysis/history"
      });
    };
    const voiceSettings = () => {
      common_vendor.index.navigateTo({
        url: "/pages/settings/voice"
      });
    };
    const userGuide = () => {
      common_vendor.index.navigateTo({
        url: "/pages/help/guide"
      });
    };
    const feedback = () => {
      common_vendor.index.navigateTo({
        url: "/pages/help/feedback"
      });
    };
    const aboutApp = () => {
      common_vendor.index.showModal({
        title: "关于心晴日记",
        content: "版本: v1.0.0\n一款AI驱动的情绪记录应用\n帮助你更好地了解和管理情绪",
        showCancel: false
      });
    };
    const viewAllAchievements = () => {
      common_vendor.index.navigateTo({
        url: "/pages/achievements/index"
      });
    };
    const logout = () => {
      common_vendor.index.showModal({
        title: "确认退出",
        content: "退出登录后需要重新登录才能使用",
        success: (res) => {
          if (res.confirm) {
            common_vendor.index.clearStorageSync();
            common_vendor.index.showToast({
              title: "已退出登录",
              icon: "success"
            });
            setTimeout(() => {
              common_vendor.index.reLaunch({
                url: "/pages/login/index"
              });
            }, 1500);
          }
        }
      });
    };
    common_vendor.onMounted(() => {
      console.log("加载个人中心数据");
    });
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: userInfo.value.avatar,
        b: common_vendor.o(changeAvatar),
        c: common_vendor.t(userInfo.value.nickname),
        d: common_vendor.t(userInfo.value.description),
        e: common_vendor.t(formatDate(userInfo.value.joinDate)),
        f: common_vendor.o(editProfile),
        g: common_vendor.t(userStats.value.totalDays),
        h: common_vendor.t(userStats.value.totalRecords),
        i: common_vendor.t(userStats.value.averageMood),
        j: common_vendor.t(userStats.value.streakDays),
        k: common_vendor.o(exportData),
        l: backupStatus.value === "synced"
      }, backupStatus.value === "synced" ? {} : {}, {
        m: common_vendor.o(backupData),
        n: common_vendor.o(importData),
        o: common_vendor.t(currentTheme.value),
        p: common_vendor.o(themeSettings),
        q: reminderEnabled.value,
        r: common_vendor.o(toggleReminder),
        s: common_vendor.o(reminderSettings),
        t: common_vendor.o(privacySettings),
        v: common_vendor.o(aiSettings),
        w: voiceEnabled.value,
        x: common_vendor.o(toggleVoice),
        y: common_vendor.o(voiceSettings),
        z: common_vendor.o(analysisHistory),
        A: common_vendor.o(userGuide),
        B: common_vendor.o(feedback),
        C: common_vendor.o(aboutApp),
        D: common_vendor.o(viewAllAchievements),
        E: common_vendor.f(recentAchievements.value, (achievement, k0, i0) => {
          return {
            a: common_vendor.t(achievement.icon),
            b: common_vendor.t(achievement.name),
            c: achievement.id
          };
        }),
        F: common_vendor.o(logout)
      });
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-f97f9319"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/profile/index.vue"]]);
wx.createPage(MiniProgramPage);
