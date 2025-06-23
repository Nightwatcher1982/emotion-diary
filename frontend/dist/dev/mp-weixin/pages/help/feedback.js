"use strict";
const common_vendor = require("../../common/vendor.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "feedback",
  setup(__props) {
    const selectedType = common_vendor.ref("bug");
    const selectedPriority = common_vendor.ref("medium");
    const showSystemInfo = common_vendor.ref(false);
    const feedbackForm = common_vendor.reactive({
      description: "",
      steps: [""],
      attachments: [],
      email: "",
      phone: ""
    });
    const feedbackTypes = [
      {
        key: "bug",
        name: "问题反馈",
        description: "应用出现错误或异常",
        icon: "🐛"
      },
      {
        key: "feature",
        name: "功能建议",
        description: "希望添加新功能",
        icon: "💡"
      },
      {
        key: "improvement",
        name: "改进建议",
        description: "现有功能的改进意见",
        icon: "⚡"
      },
      {
        key: "ui",
        name: "界面问题",
        description: "界面显示或交互问题",
        icon: "🎨"
      },
      {
        key: "performance",
        name: "性能问题",
        description: "应用运行缓慢或卡顿",
        icon: "🚀"
      },
      {
        key: "other",
        name: "其他",
        description: "其他类型的反馈",
        icon: "📝"
      }
    ];
    const priorities = [
      { key: "low", name: "低", icon: "🟢" },
      { key: "medium", name: "中", icon: "🟡" },
      { key: "high", name: "高", icon: "🟠" },
      { key: "urgent", name: "紧急", icon: "🔴" }
    ];
    const systemInfo = common_vendor.ref({
      appVersion: "v1.0.0",
      systemVersion: "iOS 17.5",
      deviceModel: "iPhone 15 Pro",
      userId: "user_123456"
    });
    const recentFeedbacks = common_vendor.ref([
      {
        id: 1,
        type: "bug",
        title: "登录页面无法正常显示",
        status: "resolved",
        createdAt: "2024-06-20T10:30:00Z"
      },
      {
        id: 2,
        type: "feature",
        title: "希望添加夜间模式",
        status: "processing",
        createdAt: "2024-06-18T14:20:00Z"
      },
      {
        id: 3,
        type: "improvement",
        title: "情绪记录页面加载优化",
        status: "pending",
        createdAt: "2024-06-15T09:15:00Z"
      }
    ]);
    const quickTemplates = common_vendor.computed(() => {
      const templates = {
        bug: [
          "应用崩溃",
          "功能无法使用",
          "数据显示错误",
          "页面加载失败"
        ],
        feature: [
          "希望添加...",
          "建议增加...",
          "期望支持..."
        ],
        improvement: [
          "建议优化...",
          "希望改进...",
          "可以更好..."
        ],
        ui: [
          "界面显示异常",
          "按钮无法点击",
          "文字显示不全",
          "颜色搭配问题"
        ],
        performance: [
          "启动速度慢",
          "页面卡顿",
          "内存占用高",
          "电池消耗快"
        ]
      };
      return templates[selectedType.value] || [];
    });
    const canSubmit = common_vendor.computed(() => {
      return feedbackForm.description.trim().length >= 10;
    });
    const selectType = (type) => {
      selectedType.value = type;
    };
    const selectPriority = (priority) => {
      selectedPriority.value = priority;
    };
    const useTemplate = (template) => {
      feedbackForm.description = template;
    };
    const addStep = () => {
      feedbackForm.steps.push("");
    };
    const removeStep = (index) => {
      if (feedbackForm.steps.length > 1) {
        feedbackForm.steps.splice(index, 1);
      }
    };
    const addAttachment = () => {
      common_vendor.index.chooseImage({
        count: 3,
        sizeType: ["compressed"],
        sourceType: ["album", "camera"],
        success: (res) => {
          res.tempFilePaths.forEach((path) => {
            feedbackForm.attachments.push({
              name: `image_${Date.now()}.jpg`,
              url: path,
              type: "image"
            });
          });
        }
      });
    };
    const removeAttachment = (index) => {
      feedbackForm.attachments.splice(index, 1);
    };
    const toggleSystemInfo = () => {
      showSystemInfo.value = !showSystemInfo.value;
    };
    const getTypeIcon = (type) => {
      const typeObj = feedbackTypes.find((t) => t.key === type);
      return typeObj ? typeObj.icon : "📝";
    };
    const getStatusText = (status) => {
      const statusMap = {
        pending: "待处理",
        processing: "处理中",
        resolved: "已解决",
        closed: "已关闭"
      };
      return statusMap[status] || "未知";
    };
    const formatTime = (timeStr) => {
      const date = new Date(timeStr);
      const now = /* @__PURE__ */ new Date();
      const diff = now.getTime() - date.getTime();
      const days = Math.floor(diff / (1e3 * 60 * 60 * 24));
      if (days === 0) {
        return "今天";
      } else if (days === 1) {
        return "昨天";
      } else if (days < 7) {
        return `${days}天前`;
      } else {
        return date.toLocaleDateString("zh-CN");
      }
    };
    const viewFeedbackDetail = (item) => {
      common_vendor.index.showModal({
        title: item.title,
        content: `状态：${getStatusText(item.status)}
提交时间：${formatTime(item.createdAt)}`,
        showCancel: false
      });
    };
    const viewAllHistory = () => {
      common_vendor.index.navigateTo({
        url: "/pages/help/feedback-history"
      });
    };
    const submitFeedback = () => {
      if (!canSubmit.value) {
        common_vendor.index.showToast({
          title: "请完善反馈内容",
          icon: "none"
        });
        return;
      }
      common_vendor.index.showLoading({
        title: "提交中..."
      });
      setTimeout(() => {
        common_vendor.index.hideLoading();
        common_vendor.index.showModal({
          title: "提交成功",
          content: "感谢您的反馈！我们会尽快处理您的问题。",
          showCancel: false,
          success: () => {
            feedbackForm.description = "";
            feedbackForm.steps = [""];
            feedbackForm.attachments = [];
            feedbackForm.email = "";
            feedbackForm.phone = "";
            selectedType.value = "bug";
            selectedPriority.value = "medium";
            setTimeout(() => {
              common_vendor.index.navigateBack();
            }, 1e3);
          }
        });
      }, 2e3);
    };
    common_vendor.onMounted(() => {
      common_vendor.index.getSystemInfo({
        success: (res) => {
          systemInfo.value = {
            appVersion: "v1.0.0",
            systemVersion: `${res.platform} ${res.system}`,
            deviceModel: res.model,
            userId: "user_123456"
          };
        }
      });
    });
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: common_vendor.f(feedbackTypes, (type, k0, i0) => {
          return common_vendor.e({
            a: common_vendor.t(type.icon),
            b: common_vendor.t(type.name),
            c: common_vendor.t(type.description),
            d: selectedType.value === type.key
          }, selectedType.value === type.key ? {} : {}, {
            e: type.key,
            f: selectedType.value === type.key ? 1 : "",
            g: common_vendor.o(($event) => selectType(type.key), type.key)
          });
        }),
        b: feedbackForm.description,
        c: common_vendor.o(($event) => feedbackForm.description = $event.detail.value),
        d: common_vendor.t(feedbackForm.description.length),
        e: common_vendor.unref(quickTemplates).length > 0
      }, common_vendor.unref(quickTemplates).length > 0 ? {
        f: common_vendor.f(common_vendor.unref(quickTemplates), (template, k0, i0) => {
          return {
            a: common_vendor.t(template),
            b: template,
            c: common_vendor.o(($event) => useTemplate(template), template)
          };
        })
      } : {}, {
        g: selectedType.value === "bug"
      }, selectedType.value === "bug" ? {
        h: common_vendor.f(feedbackForm.steps, (step, index, i0) => {
          return {
            a: common_vendor.t(index + 1),
            b: feedbackForm.steps[index],
            c: common_vendor.o(($event) => feedbackForm.steps[index] = $event.detail.value, index),
            d: common_vendor.o(($event) => removeStep(index), index),
            e: index
          };
        }),
        i: common_vendor.o(addStep)
      } : {}, {
        j: common_vendor.f(priorities, (priority, k0, i0) => {
          return {
            a: common_vendor.t(priority.icon),
            b: common_vendor.t(priority.name),
            c: priority.key,
            d: selectedPriority.value === priority.key ? 1 : "",
            e: priority.key,
            f: common_vendor.o(($event) => selectPriority(priority.key), priority.key)
          };
        }),
        k: common_vendor.f(feedbackForm.attachments, (attachment, index, i0) => {
          return common_vendor.e({
            a: attachment.type === "image"
          }, attachment.type === "image" ? {
            b: attachment.url
          } : {
            c: common_vendor.t(attachment.name)
          }, {
            d: common_vendor.o(($event) => removeAttachment(index), index),
            e: index
          });
        }),
        l: common_vendor.o(addAttachment),
        m: feedbackForm.email,
        n: common_vendor.o(($event) => feedbackForm.email = $event.detail.value),
        o: feedbackForm.phone,
        p: common_vendor.o(($event) => feedbackForm.phone = $event.detail.value),
        q: showSystemInfo.value ? 1 : "",
        r: common_vendor.o(toggleSystemInfo),
        s: showSystemInfo.value
      }, showSystemInfo.value ? {
        t: common_vendor.t(systemInfo.value.appVersion),
        v: common_vendor.t(systemInfo.value.systemVersion),
        w: common_vendor.t(systemInfo.value.deviceModel),
        x: common_vendor.t(systemInfo.value.userId)
      } : {}, {
        y: common_vendor.o(viewAllHistory),
        z: common_vendor.f(recentFeedbacks.value, (item, k0, i0) => {
          return {
            a: common_vendor.t(getTypeIcon(item.type)),
            b: common_vendor.t(item.title),
            c: common_vendor.t(formatTime(item.createdAt)),
            d: common_vendor.t(getStatusText(item.status)),
            e: common_vendor.n(item.status),
            f: item.id,
            g: common_vendor.o(($event) => viewFeedbackDetail(item), item.id)
          };
        }),
        A: !common_vendor.unref(canSubmit) ? 1 : "",
        B: common_vendor.o(submitFeedback),
        C: !common_vendor.unref(canSubmit)
      });
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-e6e07e3b"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/help/feedback.vue"]]);
wx.createPage(MiniProgramPage);
