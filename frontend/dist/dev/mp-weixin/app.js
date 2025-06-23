"use strict";
Object.defineProperty(exports, Symbol.toStringTag, { value: "Module" });
const common_vendor = require("./common/vendor.js");
if (!Math) {
  "./pages/login/index.js";
  "./pages/index/index.js";
  "./pages/record/index.js";
  "./pages/analysis/index.js";
  "./pages/statistics/index.js";
  "./pages/profile/index.js";
  "./pages/profile/edit.js";
  "./pages/analysis/history.js";
  "./pages/settings/reminder.js";
  "./pages/settings/privacy.js";
  "./pages/achievements/index.js";
  "./pages/help/feedback.js";
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "App",
  setup(__props) {
    common_vendor.onLaunch(() => {
      console.log("AI情绪日记APP启动");
    });
    common_vendor.onShow(() => {
      console.log("APP显示");
    });
    common_vendor.onHide(() => {
      console.log("APP隐藏");
    });
    return () => {
    };
  }
});
const App = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__file", "/Volumes/PSSD/情绪日记/frontend/src/App.vue"]]);
function createApp() {
  const app = common_vendor.createSSRApp(App);
  return {
    app
  };
}
createApp().app.mount("#app");
exports.createApp = createApp;
