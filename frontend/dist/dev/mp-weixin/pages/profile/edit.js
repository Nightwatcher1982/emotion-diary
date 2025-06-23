"use strict";
const common_vendor = require("../../common/vendor.js");
const utils_api = require("../../utils/api.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "edit",
  setup(__props) {
    const userInfo = common_vendor.ref({
      nickname: "",
      bio: "",
      gender: "N",
      birth_date: "",
      avatar: "",
      notification_enabled: true,
      daily_reminder_time: "21:00",
      theme_preference: "auto",
      analytics_consent: true
    });
    const isSaving = common_vendor.ref(false);
    const genderOptions = common_vendor.ref([
      { value: "M", label: "男", icon: "👨" },
      { value: "F", label: "女", icon: "👩" },
      { value: "O", label: "其他", icon: "🧑" },
      { value: "N", label: "保密", icon: "🤐" }
    ]);
    const themeOptions = common_vendor.ref(["跟随系统", "浅色主题", "深色主题"]);
    const themeIndex = common_vendor.ref(0);
    const currentTheme = common_vendor.computed(() => {
      const themeMap = {
        "auto": "跟随系统",
        "light": "浅色主题",
        "dark": "深色主题"
      };
      return themeMap[userInfo.value.theme_preference] || "跟随系统";
    });
    const loadUserInfo = async () => {
      try {
        const user = utils_api.getUser();
        if (user) {
          userInfo.value = {
            nickname: user.nickname || "",
            bio: user.bio || "",
            gender: user.gender || "N",
            birth_date: user.birth_date || "",
            avatar: user.avatar || "",
            notification_enabled: user.notification_enabled !== false,
            daily_reminder_time: user.daily_reminder_time || "21:00",
            theme_preference: user.theme_preference || "auto",
            analytics_consent: user.analytics_consent !== false
          };
          const themeMap = {
            "auto": 0,
            "light": 1,
            "dark": 2
          };
          themeIndex.value = themeMap[userInfo.value.theme_preference] || 0;
        }
      } catch (error) {
        console.error("加载用户信息失败:", error);
        common_vendor.index.showToast({
          title: "加载失败，请重试",
          icon: "none"
        });
      }
    };
    const changeAvatar = () => {
      common_vendor.index.chooseImage({
        count: 1,
        sizeType: ["compressed"],
        sourceType: ["album", "camera"],
        success: (res) => {
          userInfo.value.avatar = res.tempFilePaths[0];
          common_vendor.index.showToast({
            title: "头像已选择",
            icon: "success"
          });
        },
        fail: () => {
          common_vendor.index.showToast({
            title: "选择头像失败",
            icon: "none"
          });
        }
      });
    };
    const selectGender = (value) => {
      userInfo.value.gender = value;
    };
    const onDateChange = (e) => {
      userInfo.value.birth_date = e.detail.value;
    };
    const onThemeChange = (e) => {
      const index = e.detail.value;
      themeIndex.value = index;
      const themeMap = ["auto", "light", "dark"];
      userInfo.value.theme_preference = themeMap[index];
    };
    const onNotificationChange = (e) => {
      userInfo.value.notification_enabled = e.detail.value;
    };
    const onTimeChange = (e) => {
      userInfo.value.daily_reminder_time = e.detail.value;
    };
    const onAnalyticsChange = (e) => {
      userInfo.value.analytics_consent = e.detail.value;
    };
    const saveProfile = async () => {
      var _a, _b;
      if (isSaving.value)
        return;
      try {
        isSaving.value = true;
        if (!userInfo.value.nickname.trim()) {
          common_vendor.index.showToast({
            title: "请输入昵称",
            icon: "none"
          });
          return;
        }
        common_vendor.index.showLoading({
          title: "保存中..."
        });
        const response = await utils_api.authAPI.updateProfile(userInfo.value);
        const currentUser = utils_api.getUser();
        if (currentUser) {
          const updatedUser = { ...currentUser, ...userInfo.value };
          utils_api.setUser(updatedUser);
        }
        common_vendor.index.hideLoading();
        common_vendor.index.showToast({
          title: "保存成功",
          icon: "success"
        });
        setTimeout(() => {
          common_vendor.index.navigateBack();
        }, 1500);
      } catch (error) {
        common_vendor.index.hideLoading();
        console.error("保存失败:", error);
        const errorMessage = ((_b = (_a = error == null ? void 0 : error.response) == null ? void 0 : _a.data) == null ? void 0 : _b.message) || "保存失败，请重试";
        common_vendor.index.showToast({
          title: errorMessage,
          icon: "none"
        });
      } finally {
        isSaving.value = false;
      }
    };
    common_vendor.onMounted(() => {
      loadUserInfo();
    });
    return (_ctx, _cache) => {
      var _a;
      return common_vendor.e({
        a: userInfo.value.avatar || "/static/default-avatar.png",
        b: common_vendor.o(changeAvatar),
        c: userInfo.value.nickname,
        d: common_vendor.o(($event) => userInfo.value.nickname = $event.detail.value),
        e: userInfo.value.bio,
        f: common_vendor.o(($event) => userInfo.value.bio = $event.detail.value),
        g: common_vendor.t(((_a = userInfo.value.bio) == null ? void 0 : _a.length) || 0),
        h: common_vendor.f(genderOptions.value, (option, k0, i0) => {
          return {
            a: common_vendor.t(option.icon),
            b: common_vendor.t(option.label),
            c: option.value,
            d: userInfo.value.gender === option.value ? 1 : "",
            e: common_vendor.o(($event) => selectGender(option.value), option.value)
          };
        }),
        i: common_vendor.t(userInfo.value.birth_date || "请选择出生日期"),
        j: userInfo.value.birth_date,
        k: common_vendor.o(onDateChange),
        l: common_vendor.t(common_vendor.unref(currentTheme)),
        m: themeOptions.value,
        n: themeIndex.value,
        o: common_vendor.o(onThemeChange),
        p: userInfo.value.notification_enabled,
        q: common_vendor.o(onNotificationChange),
        r: userInfo.value.notification_enabled
      }, userInfo.value.notification_enabled ? {
        s: common_vendor.t(userInfo.value.daily_reminder_time || "21:00"),
        t: userInfo.value.daily_reminder_time,
        v: common_vendor.o(onTimeChange)
      } : {}, {
        w: userInfo.value.analytics_consent,
        x: common_vendor.o(onAnalyticsChange),
        y: !isSaving.value
      }, !isSaving.value ? {} : {}, {
        z: isSaving.value
      }, isSaving.value ? {} : {}, {
        A: common_vendor.t(isSaving.value ? "保存中..." : "保存修改"),
        B: common_vendor.o(saveProfile),
        C: isSaving.value
      });
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-7e5a80f3"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/profile/edit.vue"]]);
wx.createPage(MiniProgramPage);
