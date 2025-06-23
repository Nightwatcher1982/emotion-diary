# 项目目录结构说明

## 目录整理原则

为了提高项目的可维护性和可读性，我们对项目目录进行了重新整理，遵循以下原则：

1. **按功能分类**：将相关文件归类到对应目录
2. **清晰的层次结构**：避免根目录文件过多
3. **便于维护**：文档、脚本、测试分离
4. **国际化友好**：支持中英文文档并存

## 目录结构

### 📁 根目录
```
├── frontend/           # 前端源码
├── backend/           # 后端源码
├── docs/              # 项目文档
├── scripts/           # 脚本文件
├── logs/              # 日志文件
├── dev                # 快捷启动命令
├── *.pid              # 进程ID文件
└── README.md          # 项目说明
```

### 📁 docs/ - 项目文档
```
docs/
├── reports/           # 开发报告
│   ├── 图表显示问题最终修复报告.md
│   ├── 统计页面图表集成完成报告.md
│   ├── AI分析页面完善总结报告.md
│   ├── 情绪记录页面完善总结报告.md
│   ├── 图表组件修复完成报告.md
│   └── 前后端联调成功报告.md
├── guides/            # 使用指南
│   ├── 服务启动脚本使用指南.md
│   ├── 千帆AI服务接入指南.md
│   ├── 情绪记录页面功能说明.md
│   └── AI分析页面功能说明.md
├── tests/             # 测试脚本
│   ├── test_statistics_charts.sh
│   ├── test_ai_analysis.sh
│   ├── test_integration.sh
│   ├── test_ai_realtime.sh
│   └── test_emotion_record.sh
├── next_steps_plan.md # 下一步计划
├── AI情绪日记APP MVP需求说明书.md
├── AI情绪日记APP产品设计方案.md
├── AI情绪日记APP Figma文件搭建指南.md
├── 《AI 情绪日记 APP 全流程设计与交互解析》.md
└── 《个人开发者 AI 情绪日记 APP 开发计划》.md
```

### 📁 scripts/ - 脚本文件
```
scripts/
├── start_services.sh          # Linux/macOS服务启动脚本
├── start_services.bat         # Windows服务启动脚本
├── dev                        # 快捷命令脚本（内部使用）
└── verify_qianfan_config.py   # 千帆配置验证脚本
```

## 文档分类说明

### 📊 reports/ - 开发报告
存放项目开发过程中的各种报告文档，记录问题解决过程和技术总结。

### 📖 guides/ - 使用指南
存放各种使用指南和操作说明，帮助开发者快速上手。

### 🧪 tests/ - 测试脚本
存放各种测试脚本，用于验证功能和API接口。

## 使用建议

1. **查找文档**：
   - 开发报告 → `docs/reports/`
   - 使用指南 → `docs/guides/`
   - 产品设计 → `docs/` 根目录

2. **运行脚本**：
   - 服务管理 → `./dev [command]`
   - 测试验证 → `docs/tests/test_*.sh`
   - 配置验证 → `scripts/verify_qianfan_config.py`

3. **添加新文档**：
   - 开发报告 → 放入 `docs/reports/`
   - 使用指南 → 放入 `docs/guides/`
   - 测试脚本 → 放入 `docs/tests/`

## 维护说明

- 定期清理不需要的临时文件
- 保持文档更新和同步
- 遵循命名规范
- 及时更新README中的目录结构

## 历史变更

- **2024-01-XX**: 初始目录整理，创建docs、scripts分类
- 移动所有报告文件到 `docs/reports/`
- 移动所有指南文件到 `docs/guides/`
- 移动所有测试脚本到 `docs/tests/`
- 移动所有服务脚本到 `scripts/`
- 清理macOS系统生成的隐藏文件 