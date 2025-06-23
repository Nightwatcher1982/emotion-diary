"use strict";
const common_vendor = require("../../common/vendor.js");
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "reminder",
  setup(__props) {
    const reminderSettings = common_vendor.reactive({
      enabled: true,
      timeSlots: [
        {
          name: "早安提醒",
          time: "09:00",
          enabled: true,
          repeatDays: [1, 2, 3, 4, 5, 6, 0]
          // 周一到周日
        },
        {
          name: "午间提醒",
          time: "14:00",
          enabled: false,
          repeatDays: [1, 2, 3, 4, 5]
        },
        {
          name: "晚间提醒",
          time: "21:00",
          enabled: true,
          repeatDays: [1, 2, 3, 4, 5, 6, 0]
        }
      ],
      selectedContent: 0,
      customContent: "",
      smartReminders: {
        lowMood: true,
        longAbsence: true,
        achievement: true
      },
      methods: [0, 1]
      // 通知和震动
    });
    const weekDays = ["日", "一", "二", "三", "四", "五", "六"];
    const reminderContents = common_vendor.ref([
      {
        title: "温馨关怀",
        preview: "记录今天的心情，让每一份情感都被珍视 💝"
      },
      {
        title: "积极鼓励",
        preview: "每一次记录都是成长的脚印，加油！✨"
      },
      {
        title: "简约提醒",
        preview: "该记录情绪了 📝"
      },
      {
        title: "诗意表达",
        preview: "时光荏苒，让我们记录下此刻的心境 🌸"
      }
    ]);
    const reminderMethods = common_vendor.ref([
      {
        icon: "🔔",
        title: "通知提醒",
        description: "发送系统通知消息"
      },
      {
        icon: "📳",
        title: "震动提醒",
        description: "设备轻微震动提醒"
      },
      {
        icon: "🔊",
        title: "声音提醒",
        description: "播放提醒铃声"
      },
      {
        icon: "🌟",
        title: "应用角标",
        description: "在应用图标上显示提醒数字"
      }
    ]);
    const toggleMainReminder = (e) => {
      reminderSettings.enabled = e.detail.value;
      const message = reminderSettings.enabled ? "已开启每日提醒" : "已关闭每日提醒";
      common_vendor.index.showToast({
        title: message,
        icon: "success"
      });
    };
    const toggleTimeSlot = (index, e) => {
      reminderSettings.timeSlots[index].enabled = e.detail.value;
    };
    const updateTime = (index, e) => {
      reminderSettings.timeSlots[index].time = e.detail.value;
    };
    const toggleRepeatDay = (slotIndex, dayIndex) => {
      const slot = reminderSettings.timeSlots[slotIndex];
      const index = slot.repeatDays.indexOf(dayIndex);
      if (index > -1) {
        slot.repeatDays.splice(index, 1);
      } else {
        slot.repeatDays.push(dayIndex);
      }
    };
    const addNewReminder = () => {
      const newSlot = {
        name: `提醒 ${reminderSettings.timeSlots.length + 1}`,
        time: "12:00",
        enabled: true,
        repeatDays: [1, 2, 3, 4, 5, 6, 0]
      };
      reminderSettings.timeSlots.push(newSlot);
    };
    const selectReminderContent = (index) => {
      reminderSettings.selectedContent = index;
    };
    const toggleSmartReminder = (type) => {
      reminderSettings.smartReminders[type] = !reminderSettings.smartReminders[type];
    };
    const toggleReminderMethod = (index) => {
      const methodIndex = reminderSettings.methods.indexOf(index);
      if (methodIndex > -1) {
        reminderSettings.methods.splice(methodIndex, 1);
      } else {
        reminderSettings.methods.push(index);
      }
    };
    const previewReminder = () => {
      const selectedContent = reminderContents.value[reminderSettings.selectedContent];
      const content = reminderSettings.customContent || selectedContent.preview;
      common_vendor.index.showModal({
        title: "提醒预览",
        content,
        showCancel: false,
        confirmText: "知道了"
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
      return common_vendor.e({
        a: reminderSettings.enabled,
        b: common_vendor.o(toggleMainReminder),
        c: reminderSettings.enabled
      }, reminderSettings.enabled ? {
        d: common_vendor.f(reminderSettings.timeSlots, (slot, index, i0) => {
          return common_vendor.e({
            a: common_vendor.t(slot.name),
            b: common_vendor.t(slot.time),
            c: slot.enabled,
            d: common_vendor.o((e) => toggleTimeSlot(index, e), index),
            e: slot.enabled
          }, slot.enabled ? {
            f: common_vendor.t(slot.time),
            g: slot.time,
            h: common_vendor.o((e) => updateTime(index, e), index),
            i: common_vendor.f(weekDays, (day, dayIndex, i1) => {
              return {
                a: common_vendor.t(day),
                b: dayIndex,
                c: slot.repeatDays.includes(dayIndex) ? 1 : "",
                d: common_vendor.o(($event) => toggleRepeatDay(index, dayIndex), dayIndex)
              };
            })
          } : {}, {
            j: index,
            k: slot.enabled ? 1 : ""
          });
        }),
        e: common_vendor.o(addNewReminder)
      } : {}, {
        f: reminderSettings.enabled
      }, reminderSettings.enabled ? {
        g: common_vendor.f(reminderContents.value, (content, index, i0) => {
          return common_vendor.e({
            a: common_vendor.t(content.title),
            b: common_vendor.t(content.preview),
            c: reminderSettings.selectedContent === index
          }, reminderSettings.selectedContent === index ? {} : {}, {
            d: index,
            e: reminderSettings.selectedContent === index ? 1 : "",
            f: common_vendor.o(($event) => selectReminderContent(index), index)
          });
        }),
        h: reminderSettings.customContent,
        i: common_vendor.o(($event) => reminderSettings.customContent = $event.detail.value),
        j: common_vendor.t(reminderSettings.customContent.length)
      } : {}, {
        k: reminderSettings.enabled
      }, reminderSettings.enabled ? {
        l: reminderSettings.smartReminders.lowMood,
        m: common_vendor.o(($event) => toggleSmartReminder("lowMood")),
        n: reminderSettings.smartReminders.longAbsence,
        o: common_vendor.o(($event) => toggleSmartReminder("longAbsence")),
        p: reminderSettings.smartReminders.achievement,
        q: common_vendor.o(($event) => toggleSmartReminder("achievement"))
      } : {}, {
        r: reminderSettings.enabled
      }, reminderSettings.enabled ? {
        s: common_vendor.f(reminderMethods.value, (method, index, i0) => {
          return common_vendor.e({
            a: common_vendor.t(method.icon),
            b: common_vendor.t(method.title),
            c: common_vendor.t(method.description),
            d: reminderSettings.methods.includes(index)
          }, reminderSettings.methods.includes(index) ? {} : {}, {
            e: index,
            f: reminderSettings.methods.includes(index) ? 1 : "",
            g: common_vendor.o(($event) => toggleReminderMethod(index), index)
          });
        })
      } : {}, {
        t: reminderSettings.enabled
      }, reminderSettings.enabled ? {
        v: common_vendor.o(previewReminder)
      } : {}, {
        w: common_vendor.o(saveSettings)
      });
    };
  }
});
const MiniProgramPage = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-495add41"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/pages/settings/reminder.vue"]]);
wx.createPage(MiniProgramPage);
