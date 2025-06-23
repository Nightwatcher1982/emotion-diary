"use strict";
const common_vendor = require("../common/vendor.js");
if (!Array) {
  const _component_stop = common_vendor.resolveComponent("stop");
  const _component_linearGradient = common_vendor.resolveComponent("linearGradient");
  const _component_defs = common_vendor.resolveComponent("defs");
  const _component_polyline = common_vendor.resolveComponent("polyline");
  const _component_polygon = common_vendor.resolveComponent("polygon");
  const _component_circle = common_vendor.resolveComponent("circle");
  const _component_svg = common_vendor.resolveComponent("svg");
  const _component_path = common_vendor.resolveComponent("path");
  const _component_g = common_vendor.resolveComponent("g");
  (_component_stop + _component_linearGradient + _component_defs + _component_polyline + _component_polygon + _component_circle + _component_svg + _component_path + _component_g)();
}
const _sfc_main = /* @__PURE__ */ common_vendor.defineComponent({
  __name: "SimpleChart",
  props: {
    chartType: null,
    data: null,
    title: null,
    width: { default: "100%" },
    height: { default: "300rpx" }
  },
  emits: ["chartClick"],
  setup(__props, { emit }) {
    const props = __props;
    const hours = ["6-8", "8-10", "10-12", "12-14", "14-16", "16-18", "18-20", "20-22", "22-24"];
    const days = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"];
    const getLinePoints = () => {
      if (!props.data.length)
        return "";
      const width = 300;
      const height = 200;
      const stepX = width / (props.data.length - 1);
      return props.data.map((item, index) => {
        const x = index * stepX;
        const y = height - height * (item.value || item.mood) / 10;
        return `${x},${y}`;
      }).join(" ");
    };
    const getAreaPoints = () => {
      const linePoints = getLinePoints();
      if (!linePoints)
        return "";
      return `0,200 ${linePoints} 300,200`;
    };
    const getCirclePoints = () => {
      if (!props.data.length)
        return [];
      const width = 300;
      const height = 200;
      const stepX = width / (props.data.length - 1);
      return props.data.map((item, index) => ({
        x: index * stepX,
        y: height - height * (item.value || item.mood) / 10
      }));
    };
    const getBarHeight = (item) => {
      if (!props.data.length)
        return "0%";
      const values = props.data.map((d) => d.value || d.count || 0).filter((v) => v > 0);
      if (values.length === 0)
        return "0%";
      const maxValue = Math.max(...values);
      const itemValue = item.value || item.count || 0;
      if (maxValue === 0)
        return "0%";
      const percentage = itemValue / maxValue * 80;
      return `${Math.max(percentage, 2)}%`;
    };
    const getPieSegments = () => {
      if (!props.data.length)
        return [];
      const total = props.data.reduce((sum, item) => sum + (item.percentage || item.value || 0), 0);
      if (total === 0)
        return [];
      let currentAngle = -Math.PI / 2;
      return props.data.map((item, index) => {
        const value = item.percentage || item.value || 0;
        const percentage = value / total;
        const angle = percentage * 2 * Math.PI;
        if (angle === 0)
          return { path: "", color: item.color };
        const centerX = 100;
        const centerY = 100;
        const radius = 70;
        const x1 = centerX + radius * Math.cos(currentAngle);
        const y1 = centerY + radius * Math.sin(currentAngle);
        const x2 = centerX + radius * Math.cos(currentAngle + angle);
        const y2 = centerY + radius * Math.sin(currentAngle + angle);
        const largeArcFlag = angle > Math.PI ? 1 : 0;
        let path;
        if (percentage >= 0.999) {
          path = `M ${centerX} ${centerY - radius} A ${radius} ${radius} 0 1 1 ${centerX - 1} ${centerY - radius} Z`;
        } else {
          path = [
            `M ${centerX} ${centerY}`,
            `L ${x1} ${y1}`,
            `A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2}`,
            `Z`
          ].join(" ");
        }
        currentAngle += angle;
        return {
          path,
          color: item.color || "#4A90E2",
          percentage: Math.round(percentage * 100)
        };
      }).filter((segment) => segment.path !== "");
    };
    const getHeatmapData = () => {
      const grid = [];
      for (let day = 0; day < 7; day++) {
        const row = [];
        for (let hour = 0; hour < 9; hour++) {
          const dataPoint = props.data.find((d) => d.day === day && d.hour === hour);
          row.push({
            value: dataPoint ? dataPoint.intensity : Math.random()
          });
        }
        grid.push(row);
      }
      return grid;
    };
    const getHeatmapColor = (intensity) => {
      const alpha = Math.max(0.1, Math.min(1, intensity));
      return `rgba(74, 144, 226, ${alpha})`;
    };
    const onPointClick = (index) => {
      emit("chartClick", { type: "point", index, data: props.data[index] });
    };
    const onBarClick = (index) => {
      emit("chartClick", { type: "bar", index, data: props.data[index] });
    };
    const onPieClick = (index) => {
      emit("chartClick", { type: "pie", index, data: props.data[index] });
    };
    const onHeatmapClick = (row, col) => {
      emit("chartClick", { type: "heatmap", row, col, day: days[row], hour: hours[col] });
    };
    return (_ctx, _cache) => {
      return common_vendor.e({
        a: __props.chartType === "line"
      }, __props.chartType === "line" ? {
        b: common_vendor.t(__props.title || "情绪趋势"),
        c: common_vendor.f(11, (n, k0, i0) => {
          return {
            a: common_vendor.t(10 - (n - 1)),
            b: n
          };
        }),
        d: common_vendor.p({
          offset: "0%"
        }),
        e: common_vendor.p({
          offset: "100%"
        }),
        f: common_vendor.p({
          id: "gradient",
          x1: "0%",
          y1: "0%",
          x2: "0%",
          y2: "100%"
        }),
        g: common_vendor.p({
          points: getLinePoints(),
          fill: "none",
          stroke: "#4A90E2",
          ["stroke-width"]: "2"
        }),
        h: common_vendor.p({
          points: getAreaPoints(),
          fill: "url(#gradient)"
        }),
        i: common_vendor.f(getCirclePoints(), (point, index, i0) => {
          return {
            a: index,
            b: common_vendor.o(($event) => onPointClick(index), index),
            c: "376c3faa-7-" + i0 + ",376c3faa-0",
            d: common_vendor.p({
              cx: point.x,
              cy: point.y,
              r: "3",
              fill: "#4A90E2"
            })
          };
        }),
        j: common_vendor.p({
          viewBox: "0 0 300 200"
        }),
        k: common_vendor.f(__props.data, (item, index, i0) => {
          return {
            a: common_vendor.t(item.name || item.label),
            b: index
          };
        })
      } : __props.chartType === "bar" ? {
        m: common_vendor.t(__props.title || "数据统计"),
        n: common_vendor.f(__props.data, (item, index, i0) => {
          return {
            a: common_vendor.t(item.value || item.count),
            b: getBarHeight(item),
            c: item.color || "#4A90E2",
            d: common_vendor.t(item.name || item.label),
            e: index,
            f: common_vendor.o(($event) => onBarClick(index), index)
          };
        })
      } : __props.chartType === "pie" ? {
        p: common_vendor.t(__props.title || "分布统计"),
        q: common_vendor.f(getPieSegments(), (segment, index, i0) => {
          return {
            a: common_vendor.o(($event) => onPieClick(index), index),
            b: "376c3faa-10-" + i0 + "," + ("376c3faa-9-" + i0),
            c: common_vendor.p({
              d: segment.path,
              fill: segment.color
            }),
            d: index,
            e: "376c3faa-9-" + i0 + ",376c3faa-8"
          };
        }),
        r: common_vendor.p({
          viewBox: "0 0 200 200"
        }),
        s: common_vendor.f(__props.data, (item, index, i0) => {
          return {
            a: item.color,
            b: common_vendor.t(item.name),
            c: common_vendor.t(item.percentage || item.value),
            d: index
          };
        })
      } : __props.chartType === "heatmap" ? {
        v: common_vendor.t(__props.title || "活跃度热力图"),
        w: common_vendor.f(getHeatmapData(), (row, rowIndex, i0) => {
          return {
            a: common_vendor.f(row, (cell, colIndex, i1) => {
              return {
                a: common_vendor.t(cell.value.toFixed(1)),
                b: colIndex,
                c: getHeatmapColor(cell.value),
                d: common_vendor.o(($event) => onHeatmapClick(rowIndex, colIndex), colIndex)
              };
            }),
            b: rowIndex
          };
        }),
        x: common_vendor.f(hours, (hour, k0, i0) => {
          return {
            a: common_vendor.t(hour),
            b: hour
          };
        }),
        y: common_vendor.f(days, (day, k0, i0) => {
          return {
            a: common_vendor.t(day),
            b: day
          };
        })
      } : {}, {
        l: __props.chartType === "bar",
        o: __props.chartType === "pie",
        t: __props.chartType === "heatmap"
      });
    };
  }
});
const Component = /* @__PURE__ */ common_vendor._export_sfc(_sfc_main, [["__scopeId", "data-v-376c3faa"], ["__file", "/Volumes/PSSD/情绪日记/frontend/src/components/SimpleChart.vue"]]);
wx.createComponent(Component);
