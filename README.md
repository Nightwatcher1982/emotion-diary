# 🌟 AI情绪日记应用 v1.0.0

> 基于AI的智能情绪记录与分析应用，帮助用户更好地了解和管理自己的情绪状态。

[![版本](https://img.shields.io/badge/版本-v1.0.0-blue.svg)](https://github.com/Nightwatcher1982/emotion-diary/releases/tag/v1.0.0)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-支持-blue.svg)](docker-compose.yml)

## 📱 应用截图

| 首页 | 记录 | 分析 | 统计 | 个人中心 |
|------|------|------|------|----------|
| ![首页](img/首页.png) | ![记录](img/记录.png) | ![分析](img/分析.png) | ![统计](img/统计.png) | ![我的](img/我的.png) |

## ✨ 核心功能

### 🎯 用户认证
- **手机验证码登录** - 快速安全的手机号验证
- **微信小程序登录** - 一键授权登录
- **用户资料管理** - 个性化设置和隐私控制

### 📝 情绪记录
- **智能情绪识别** - 支持多种情绪类型和强度
- **快速记录模式** - 简化操作，一键记录
- **富文本编辑** - 支持详细的情绪描述
- **标签分类** - 灵活的情绪标签系统

### 🤖 AI分析
- **智能情绪分析** - 基于百度千帆大模型的深度分析
- **个性化建议** - 针对性的情绪管理建议
- **趋势预测** - 基于历史数据的情绪趋势分析
- **测试模式** - 开发环境下的模拟分析功能

### 📊 数据统计
- **可视化图表** - 直观的情绪数据展示
- **多维度分析** - 时间、类型、强度等多角度统计
- **历史回顾** - 完整的情绪历史记录
- **数据导出** - 支持数据备份和导出

## 🚀 快速开始

### 🖥️ 服务器部署（推荐）

**一键部署脚本**：
```bash
# 下载并运行部署脚本
curl -fsSL https://raw.githubusercontent.com/Nightwatcher1982/emotion-diary/main/scripts/server-deploy.sh | bash
```

**手动部署**：
```bash
# 1. 克隆项目
git clone https://github.com/Nightwatcher1982/emotion-diary.git
cd emotion-diary

# 2. 切换到稳定版本
git checkout v1.0.0

# 3. 配置环境变量
cp docker.env .env
nano .env  # 编辑配置

# 4. 启动服务
docker-compose up -d

# 5. 查看状态
docker-compose ps
```

**访问地址**：
- 应用首页：http://your-server-ip/
- 健康检查：http://your-server-ip/health/
- API接口：http://your-server-ip/api/v1/

### 💻 本地开发

```bash
# 1. 克隆项目
git clone https://github.com/Nightwatcher1982/emotion-diary.git
cd emotion-diary

# 2. 后端设置
cd backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver

# 3. 前端设置
cd frontend
npm install
npm run dev:h5
```

## 🔧 技术架构

### 前端技术栈
- **uni-app** - 跨平台开发框架
- **Vue 3** - 渐进式JavaScript框架
- **TypeScript** - 类型安全的JavaScript
- **uni-ui** - 统一的UI组件库

### 后端技术栈
- **Django** - Python Web框架
- **Django REST Framework** - RESTful API框架
- **SQLite/PostgreSQL** - 数据库支持
- **Redis** - 缓存和会话存储

### AI服务
- **百度千帆大模型** - 智能情绪分析
- **自然语言处理** - 文本情感识别
- **机器学习** - 个性化推荐算法

### 部署架构
- **Docker** - 容器化部署
- **nginx** - 反向代理和静态文件服务
- **Docker Compose** - 多容器编排
- **GitHub Actions** - CI/CD自动化

## 📋 环境配置

### 必需配置
```bash
# Django基础配置
SECRET_KEY=your-secret-key
DEBUG=False
ALLOWED_HOSTS=your-domain.com,your-ip

# 数据库配置
DATABASE_URL=sqlite:///app/backend/db.sqlite3
```

### 可选配置
```bash
# 千帆AI配置（启用AI分析功能）
QIANFAN_API_KEY=your-qianfan-api-key

# 微信小程序配置（启用微信登录）
WECHAT_APPID=your-wechat-appid
WECHAT_SECRET=your-wechat-secret

# 短信服务配置（启用短信验证）
SMS_ACCESS_KEY_ID=your-sms-access-key
SMS_ACCESS_KEY_SECRET=your-sms-secret
```

## 📊 系统要求

### 服务器要求
- **操作系统**: Ubuntu 18.04+ / Debian 10+ / CentOS 7+
- **内存**: 最低1GB，推荐2GB+
- **存储**: 最低5GB可用空间
- **网络**: 稳定的互联网连接

### 开发环境
- **Node.js**: 16.0+
- **Python**: 3.8+
- **Docker**: 20.0+
- **Docker Compose**: 2.0+

## 🔒 安全特性

- **数据加密** - 敏感数据加密存储
- **API限流** - 防止接口滥用
- **CSRF保护** - 跨站请求伪造防护
- **输入验证** - 严格的数据验证
- **安全头** - 完整的HTTP安全头配置

## 📈 性能优化

- **静态文件CDN** - 前端资源加速
- **数据库索引** - 查询性能优化
- **缓存策略** - Redis缓存加速
- **图片压缩** - 自动图片优化
- **代码分割** - 按需加载减少包体积

## 🧪 测试功能

### 开发环境特性
- **模拟登录** - 无需真实手机号验证
- **AI测试模式** - 模拟AI分析结果
- **详细日志** - 完整的调试信息
- **热重载** - 代码修改实时生效

### 测试脚本
```bash
# API功能测试
./scripts/test_api.sh

# 前端功能测试
./scripts/test_frontend.sh

# 完整集成测试
./scripts/test_integration.sh
```

## 📚 文档

- [📖 部署指南](docs/服务器Docker部署指南.md)
- [🔧 开发指南](docs/开发环境搭建指南.md)
- [📋 API文档](docs/API接口文档.md)
- [🎨 UI设计规范](docs/UI设计规范.md)
- [🚀 版本更新日志](CHANGELOG.md)

## 🤝 贡献指南

欢迎贡献代码！请阅读 [贡献指南](CONTRIBUTING.md) 了解详细信息。

### 开发流程
1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [uni-app](https://uniapp.dcloud.io/) - 跨平台开发框架
- [Django](https://www.djangoproject.com/) - Web开发框架
- [百度千帆](https://cloud.baidu.com/product/wenxinworkshop) - AI大模型服务
- [Docker](https://www.docker.com/) - 容器化平台

## 📞 联系方式

- **GitHub Issues**: [提交问题](https://github.com/Nightwatcher1982/emotion-diary/issues)
- **项目主页**: https://github.com/Nightwatcher1982/emotion-diary
- **作者**: Nightwatcher1982

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给它一个星标！**

Made with ❤️ by [Nightwatcher1982](https://github.com/Nightwatcher1982)

</div> 