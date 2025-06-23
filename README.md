# 心晴日记 - AI情绪记录应用

一款基于AI技术的轻量化情绪管理工具，帮助用户记录、分析和管理情绪状态。

## 项目概述

- **目标用户**: 18-35岁大学生/职场新人
- **核心功能**: 情绪记录 + AI分析的闭环
- **开发周期**: 8周MVP
- **技术栈**: Uniapp + Vue3 + Django + 百度千帆ERNIE-Bot

## 技术架构

### 前端
- **框架**: Uniapp + Vue3 + TypeScript
- **构建工具**: Vite
- **UI组件**: 原生Uniapp组件
- **状态管理**: Vue3 Composition API

### 后端
- **框架**: Django + Django REST Framework
- **数据库**: MySQL + MongoDB
- **AI服务**: 百度千帆ERNIE-Bot
- **部署**: 云服务器

## 项目结构

```
├── frontend/                 # 前端项目
│   ├── src/
│   │   ├── pages/           # 页面文件
│   │   │   ├── index/       # 首页
│   │   │   ├── record/      # 情绪记录页
│   │   │   ├── analysis/    # AI分析页
│   │   │   ├── statistics/  # 统计页面
│   │   │   └── profile/     # 个人中心
│   │   ├── components/      # 公共组件
│   │   │   └── SimpleChart.vue  # 图表组件
│   │   ├── utils/           # 工具函数
│   │   │   └── api.ts       # API接口
│   │   ├── App.vue          # 根组件
│   │   ├── main.js          # 入口文件
│   │   ├── pages.json       # 页面配置
│   │   └── manifest.json    # 应用配置
│   ├── package.json         # 依赖配置
│   ├── vite.config.ts       # Vite配置
│   └── index.html           # HTML模板
├── backend/                 # 后端项目
│   ├── emotion_diary_api/   # Django项目配置
│   ├── accounts/            # 用户认证模块
│   ├── emotions/            # 情绪记录模块
│   ├── ai_analysis/         # AI分析模块
│   ├── manage.py            # Django管理脚本
│   └── requirements.txt     # Python依赖
├── docs/                    # 项目文档
│   ├── reports/             # 开发报告
│   │   ├── 图表显示问题最终修复报告.md
│   │   ├── 统计页面图表集成完成报告.md
│   │   ├── AI分析页面完善总结报告.md
│   │   ├── 情绪记录页面完善总结报告.md
│   │   └── 前后端联调成功报告.md
│   ├── guides/              # 使用指南
│   │   ├── 服务启动脚本使用指南.md
│   │   ├── 千帆AI服务接入指南.md
│   │   ├── 情绪记录页面功能说明.md
│   │   └── AI分析页面功能说明.md
│   ├── tests/               # 测试脚本
│   │   ├── test_statistics_charts.sh
│   │   ├── test_ai_analysis.sh
│   │   ├── test_integration.sh
│   │   └── test_ai_realtime.sh
│   ├── next_steps_plan.md   # 下一步计划
│   ├── AI情绪日记APP MVP需求说明书.md
│   ├── AI情绪日记APP产品设计方案.md
│   ├── AI情绪日记APP Figma文件搭建指南.md
│   ├── 《AI 情绪日记 APP 全流程设计与交互解析》.md
│   └── 《个人开发者 AI 情绪日记 APP 开发计划》.md
├── scripts/                 # 脚本文件
│   ├── start_services.sh    # Linux/macOS启动脚本
│   ├── start_services.bat   # Windows启动脚本
│   ├── dev                  # 快捷命令脚本
│   └── verify_qianfan_config.py  # 千帆配置验证
├── logs/                    # 日志文件目录
│   ├── backend.log          # 后端日志
│   ├── frontend.log         # 前端日志
│   └── services.log         # 脚本日志
├── dev                      # 快捷启动命令
├── *.pid                    # 进程ID文件
└── README.md               # 项目说明
```

## 功能模块

### 已完成的前端页面

1. **首页 (index)**
   - 欢迎界面
   - 今日情绪概览
   - 快捷记录入口
   - 数据统计展示

2. **情绪记录页 (record)**
   - 分步式记录流程
   - 文本输入（支持语音）
   - 情绪标签选择（6种基础情绪）
   - 场景标签选择
   - 情绪强度调节
   - 深度分析开关

3. **AI分析页 (analysis)**
   - 情绪分析结果
   - AI洞察和建议
   - 个性化建议（即时缓解、长期改善等）
   - 情绪趋势图表
   - 深度分析报告
   - 行动计划制定

4. **统计页面 (statistics)**
   - 时间范围选择
   - 情绪趋势图表
   - 情绪分布饼图
   - 场景分析
   - 时间模式分析
   - 情绪词云
   - 成就系统
   - 数据导出功能

5. **个人中心 (profile)**
   - 用户信息管理
   - 数据概览
   - 设置选项（主题、提醒、隐私等）
   - AI功能配置
   - 数据管理（导出、备份、导入）
   - 帮助与支持

## 快速开始

### 🚀 一键启动（推荐）

使用我们提供的服务管理脚本，可以一键启动前后端服务：

```bash
# Linux/macOS - 首次使用需要添加执行权限
chmod +x scripts/start_services.sh

# 启动所有服务
./scripts/start_services.sh start
# 或使用快捷命令
./dev start

# Windows
scripts/start_services.bat start
```

### 📊 服务管理

```bash
# 查看服务状态
./dev status

# 重启服务
./dev restart

# 停止服务  
./dev stop

# 查看日志
./dev logs backend
./dev logs frontend

# 显示帮助
./dev help
```

### 📱 访问应用

启动服务后，可通过以下地址访问：
- **前端应用**: http://localhost:5173
- **后端API**: http://127.0.0.1:8000
- **测试账号**: `testuser` / `testpass123`

### 🔧 传统启动方式

如果需要单独启动服务：

#### 前端开发

1. 安装依赖
```bash
cd frontend
npm install
```

2. 启动开发服务器
```bash
npm run dev:h5
```

#### 后端开发

1. 进入后端目录
```bash
cd backend
```

2. 激活虚拟环境（如果有）
```bash
source emotion_diary_env/bin/activate  # Linux/macOS
# 或
emotion_diary_env\Scripts\activate     # Windows
```

3. 启动Django服务
```bash
python manage.py runserver
```

### 构建命令

```bash
# H5版本开发
npm run dev:h5

# 微信小程序开发
npm run dev:mp-weixin

# H5版本构建
npm run build:h5

# 微信小程序构建
npm run build:mp-weixin
```

## 设计特色

### UI/UX设计
- **现代化界面**: 采用渐变色彩和圆角设计
- **响应式布局**: 适配不同屏幕尺寸
- **交互动画**: 流畅的过渡效果和微交互
- **无障碍设计**: 考虑视觉和操作便利性

### 功能特色
- **分步式记录**: 降低用户记录门槛
- **智能分析**: AI驱动的情绪洞察
- **可视化展示**: 丰富的图表和统计
- **个性化建议**: 针对性的改善方案
- **成就系统**: 激励用户持续使用

## 开发状态

### ✅ 已完成
- [x] 前端项目搭建
- [x] 页面结构设计
- [x] 所有主要页面开发
- [x] 响应式布局
- [x] 基础交互功能
- [x] 开发服务器配置
- [x] 后端API开发
- [x] 数据库设计
- [x] AI服务集成（百度千帆）
- [x] 用户认证系统
- [x] 情绪记录功能
- [x] 统计分析功能
- [x] 图表可视化
- [x] 前后端联调
- [x] 服务管理脚本
- [x] 测试用例

### 🚧 进行中
- [ ] 个人中心功能完善
- [ ] AI分析页面优化
- [ ] 智能提醒系统

### 📋 待开发
- [ ] 实时同步
- [ ] 消息推送
- [ ] 性能优化
- [ ] 部署配置
- [ ] 移动端适配
- [ ] 小程序版本

## 技术特点

1. **跨平台兼容**: 支持H5、微信小程序等多平台
2. **组件化开发**: 模块化的页面和组件结构
3. **TypeScript支持**: 类型安全的开发体验
4. **现代化构建**: 基于Vite的快速构建
5. **响应式设计**: 适配移动端和桌面端

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License

## 联系方式

如有问题或建议，请提交Issue或联系开发团队。

---

**注意**: 这是一个MVP版本，主要用于验证"用户是否愿意用AI记录情绪"的核心假设。 