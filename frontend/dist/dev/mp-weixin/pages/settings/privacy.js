"use strict";
const common_vendor = require("../../common/vendor.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "privacy",
  setup(__props) {
    const protectionLevel = common_vendor.ref("标准");
    const autoLockTime = common_vendor.ref(5);
    const privacySettings = common_vendor.reactive({
      localEncryption: true,
      e2eEncryption: false,
      anonymousAnalysis: true,
      dataMasking: true,
      locationProtection: true,
      biometricAuth: false,
      anonymousStats: true,
      crashReports: true,
      thirdPartyAnalytics: false
    });
    const protectionLevels = [
      {
        name: "基础",
        icon: "🛡️",
        description: "基本的隐私保护，适合一般用户"
      },
      {
        name: "标准",
        icon: "🔒",
        description: "平衡隐私保护与功能体验"
      },
      {
        name: "高级",
        icon: "🔐",
        description: "最高级别的隐私保护，可能影响部分功能"
      }
    ];
    const appLockStatus = common_vendor.computed(() => {
      if (privacySettings.biometricAuth) {
        return "已启用生物识别";
      }
      return "未启用";
    });
    const autoLockTimeText = common_vendor.computed(() => {
      if (autoLockTime.value === 0) {
        return "立即锁定";
      } else if (autoLockTime.value === 60) {
        return "1小时后";
      } else {
        return `${autoLockTime.value}分钟后`;
      }
    });
    const getLevelDescription = () => {
      const level = protectionLevels.find((l) => l.name === protectionLevel.value);
      return level ? level.description : "";
    };
    const selectProtectionLevel = (level) => {
      protectionLevel.value = level;
      if (level === "基础") {
        privacySettings.localEncryption = false;
        privacySettings.e2eEncryption = false;
        privacySettings.anonymousAnalysis = false;
        privacySettings.dataMasking = false;
      } else if (level === "标准") {
        privacySettings.localEncryption = true;
        privacySettings.e2eEncryption = false;
        privacySettings.anonymousAnalysis = true;
        privacySettings.dataMasking = true;
      } else if (level === "高级") {
        privacySettings.localEncryption = true;
        privacySettings.e2eEncryption = true;
        privacySettings.anonymousAnalysis = true;
        privacySettings.dataMasking = true;
        privacySettings.locationProtection = true;
      }
      common_vendor.index.showToast({
        title: `已切换到${level}保护`,
        icon: "success"
      });
    };
    const toggleLocalEncryption = (e) => {
      privacySettings.localEncryption = e.detail.value;
      const message = privacySettings.localEncryption ? "已启用本地加密" : "已关闭本地加密";
      common_vendor.index.showToast({
        title: message,
        icon: "success"
      });
    };
    const toggleE2EEncryption = (e) => {
      privacySettings.e2eEncryption = e.detail.value;
      if (privacySettings.e2eEncryption) {
        common_vendor.index.showModal({
          title: "端到端加密",
          content: "启用后，即使是我们也无法访问您的数据。请妥善保管您的密码，忘记后无法恢复。",
          success: (res) => {
            if (!res.confirm) {
              privacySettings.e2eEncryption = false;
            }
          }
        });
      }
    };
    const toggleAnonymousAnalysis = (e) => {
      privacySettings.anonymousAnalysis = e.detail.value;
    };
    const toggleDataMasking = (e) => {
      privacySettings.dataMasking = e.detail.value;
    };
    const toggleLocationProtection = (e) => {
      privacySettings.locationProtection = e.detail.value;
    };
    const toggleBiometricAuth = (e) => {
      privacySettings.biometricAuth = e.detail.value;
      if (privacySettings.biometricAuth) {
        common_vendor.index.showModal({
          title: "生物识别验证",
          content: "请使用指纹或面部识别进行验证",
          success: (res) => {
            if (res.confirm) {
              common_vendor.index.showToast({
                title: "验证成功",
                icon: "success"
              });
            } else {
              privacySettings.biometricAuth = false;
            }
          }
        });
      }
    };
    const toggleAnonymousStats = (e) => {
      privacySettings.anonymousStats = e.detail.value;
    };
    const toggleCrashReports = (e) => {
      privacySettings.crashReports = e.detail.value;
    };
    const toggleThirdPartyAnalytics = (e) => {
      privacySettings.thirdPartyAnalytics = e.detail.value;
    };
    const setAppLock = () => {
      common_vendor.index.showActionSheet({
        itemList: ["设置密码锁", "设置图案锁", "关闭应用锁"],
        success: (res) => {
          const options = ["密码锁", "图案锁", "关闭"];
          common_vendor.index.showToast({
            title: `已设置${options[res.tapIndex]}`,
            icon: "success"
          });
        }
      });
    };
    const setBiometricAuth = () => {
      common_vendor.index.showModal({
        title: "生物识别设置",
        content: "是否启用指纹或面部识别？",
        success: (res) => {
          if (res.confirm) {
            privacySettings.biometricAuth = true;
          }
        }
      });
    };
    const setAutoLockTime = () => {
      common_vendor.index.showActionSheet({
        itemList: ["立即锁定", "1分钟后", "5分钟后", "15分钟后", "30分钟后", "1小时后"],
        success: (res) => {
          const times = [0, 1, 5, 15, 30, 60];
          autoLockTime.value = times[res.tapIndex];
          common_vendor.index.showToast({
            title: "设置成功",
            icon: "success"
          });
        }
      });
    };
    const viewDataUsage = () => {
      common_vendor.index.showModal({
        title: "数据使用情况",
        content: "本地数据：2.3MB\n云端备份：1.8MB\n缓存数据：0.5MB",
        showCancel: false
      });
    };
    const exportPersonalData = () => {
      common_vendor.index.showLoading({
        title: "导出中..."
      });
      setTimeout(() => {
        common_vendor.index.hideLoading();
        common_vendor.index.showToast({
          title: "导出完成",
          icon: "success"
        });
      }, 2e3);
    };
    const deleteAllData = () => {
      common_vendor.index.showModal({
        title: "危险操作",
        content: '此操作将永久删除所有数据，无法恢复。请输入"DELETE"确认删除。',
        editable: true,
        success: (res) => {
          if (res.confirm && res.content === "DELETE") {
            common_vendor.index.showLoading({
              title: "删除中..."
            });
            setTimeout(() => {
              common_vendor.index.hideLoading();
              common_vendor.index.showToast({
                title: "数据已删除",
                icon: "success"
              });
            }, 2e3);
          } else if (res.confirm) {
            common_vendor.index.showToast({
              title: "输入错误，删除取消",
              icon: "none"
            });
          }
        }
      });
    };
    const viewPrivacyPolicy = () => {
      common_vendor.index.navigateTo({
        url: "/pages/legal/privacy-policy"
      });
    };
    const viewTermsOfService = () => {
      common_vendor.index.navigateTo({
        url: "/pages/legal/terms-of-service"
      });
    };
    const viewDataPolicy = () => {
      common_vendor.index.navigateTo({
        url: "/pages/legal/data-policy"
      });
    };
    const saveSettings = () => {
      common_vendor.index.showLoading({
        title: "保存中..."
      });
      setTimeout(() => {
        common_vendor.index.hideLoading();
        common_vendor.index.showToast({
          title: "设置已保存",
          icon: "success"
        });
        setTimeout(() => {
          common_vendor.index.navigateBack();
        }, 1500);
      }, 1e3);
    };
    return (_ctx, _cache) => {
      return {
        a: common_vendor.t(protectionLevel.value),
        b: common_vendor.n(protectionLevel.value.toLowerCase()),
        c: common_vendor.t(getLevelDescription()),
        d: common_vendor.f(protectionLevels, (level, k0, i0) => {
          return common_vendor.e({
            a: common_vendor.t(level.icon),
            b: common_vendor.t(level.name),
            c: common_vendor.t(level.description),
            d: protectionLevel.value === level.name
          }, protectionLevel.value === level.name ? {} : {}, {
            e: level.name,
            f: protectionLevel.value === level.name ? 1 : "",
            g: common_vendor.o(($event) => selectProtectionLevel(level.name), level.name)
          });
        }),
        e: privacySettings.localEncryption,
        f: common_vendor.o(toggleLocalEncryption),
        g: privacySettings.e2eEncryption,
        h: common_vendor.o(toggleE2EEncryption),
        i: privacySettings.anonymousAnalysis,
        j: common_vendor.o(toggleAnonymousAnalysis),
        k: privacySettings.dataMasking,
        l: common_vendor.o(toggleDataMasking),
        m: privacySettings.locationProtection,
        n: common_vendor.o(toggleLocationProtection),
        o: common_vendor.t(common_vendor.unref(appLockStatus)),
        p: common_vendor.o(setAppLock),
        q: privacySettings.biometricAuth,
        r: common_vendor.o(toggleBiometricAuth),
        s: common_vendor.o(setBiometricAuth),
        t: common_vendor.t(common_vendor.unref(autoLockTimeText)),
        v: common_vendor.o(setAutoLockTime),
        w: privacySettings.anonymousStats,
        x: common_vendor.o(toggleAnonymousStats),
        y: privacySettings.crashReports,
        z: common_vendor.o(toggleCrashReports),
        A: privacySettings.thirdPartyAnalytics,
        B: common_vendor.o(toggleThirdPartyAnalytics),
        C: common_vendor.o(viewDataUsage),
        D: common_vendor.o(exportPersonalData),
        E: common_vendor.o(deleteAllData),
        F: common_vendor.o(viewPrivacyPolicy),
        G: common_vendor.o(viewTermsOfService),
        H: common_vendor.o(viewDataPolicy),
        I: common_vendor.o(saveSettings)
      };
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-4c5261bb"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/settings/privacy.vue"]]);
wx.createPage(MiniProgramPage);
