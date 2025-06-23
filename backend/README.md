# AI情绪日记 - 后端API

基于Django + DRF的AI情绪日记应用后端服务。

## 🚀 快速开始

### 环境要求

- Python 3.8+
- Django 4.2.7
- Django REST Framework 3.14.0

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd emotion-diary/backend
```

2. **创建虚拟环境**
```bash
python3 -m venv emotion_diary_env
source emotion_diary_env/bin/activate  # macOS/Linux
# 或
emotion_diary_env\Scripts\activate  # Windows
```

3. **安装依赖**
```bash
pip install -r requirements.txt
```

4. **配置环境变量**
```bash
cp env.example .env
# 编辑 .env 文件，配置必要的环境变量
```

5. **数据库迁移**
```bash
python manage.py makemigrations
python manage.py migrate
```

6. **创建超级用户**
```bash
python manage.py createsuperuser
```

7. **启动服务器**
```bash
python manage.py runserver 0.0.0.0:8000
```

## 📁 项目结构

```
backend/
├── emotion_diary_api/          # Django项目主目录
│   ├── __init__.py
│   ├── settings.py            # 项目设置
│   ├── urls.py               # 主URL配置
│   ├── wsgi.py
│   └── asgi.py
├── accounts/                  # 用户账户管理
│   ├── models.py             # 用户模型
│   ├── views.py              # 认证视图
│   ├── serializers.py        # 序列化器
│   ├── urls.py              # 路由配置
│   └── admin.py             # 管理后台
├── emotions/                  # 情绪记录管理
│   ├── models.py             # 情绪模型
│   ├── views.py              # 情绪视图
│   ├── serializers.py        # 序列化器
│   ├── urls.py              # 路由配置
│   └── admin.py             # 管理后台
├── ai_analysis/               # AI分析服务
│   ├── models.py             # AI分析模型
│   ├── views.py              # AI分析视图
│   ├── serializers.py        # 序列化器
│   ├── urls.py              # 路由配置
│   └── admin.py             # 管理后台
├── logs/                      # 日志文件
├── media/                     # 媒体文件
├── staticfiles/               # 静态文件
├── requirements.txt           # 依赖列表
├── manage.py                 # Django管理脚本
└── env.example               # 环境变量示例
```

## 🔌 API接口

### 认证相关

- `POST /api/v1/auth/register/` - 用户注册
- `POST /api/v1/auth/login/` - 用户登录
- `POST /api/v1/auth/logout/` - 用户登出
- `GET /api/v1/auth/profile/` - 获取个人资料
- `PUT /api/v1/auth/profile/` - 更新个人资料
- `POST /api/v1/auth/change-password/` - 修改密码

### 情绪记录

- `GET /api/v1/emotions/records/` - 获取情绪记录列表
- `POST /api/v1/emotions/records/` - 创建情绪记录
- `GET /api/v1/emotions/records/{id}/` - 获取单个记录
- `PUT /api/v1/emotions/records/{id}/` - 更新记录
- `DELETE /api/v1/emotions/records/{id}/` - 删除记录
- `GET /api/v1/emotions/records/today/` - 获取今日记录
- `GET /api/v1/emotions/records/this_week/` - 获取本周记录
- `POST /api/v1/emotions/quick-record/` - 快速记录
- `GET /api/v1/emotions/recent/` - 最近记录

### 统计分析

- `GET /api/v1/emotions/statistics/` - 情绪统计
- `GET /api/v1/emotions/trends/` - 情绪趋势
- `GET /api/v1/emotions/export/` - 导出数据

### AI分析

- `POST /api/v1/ai/analyze/` - 分析情绪
- `POST /api/v1/ai/batch-analyze/` - 批量分析
- `POST /api/v1/ai/generate-insights/` - 生成洞察
- `POST /api/v1/ai/get-recommendations/` - 获取建议
- `POST /api/v1/ai/create-plan/` - 创建行动计划
- `GET /api/v1/ai/usage-stats/` - 使用统计

## 📚 API文档

启动服务器后，可以访问以下地址查看API文档：

- **Swagger UI**: http://localhost:8000/api/docs/
- **ReDoc**: http://localhost:8000/api/redoc/
- **OpenAPI Schema**: http://localhost:8000/api/schema/

## 🛠️ 开发工具

### Django管理后台

访问 http://localhost:8000/admin/ 使用超级用户账号登录管理后台。

### 数据库

开发环境使用SQLite数据库，数据文件位于 `db.sqlite3`。

### 日志

日志文件保存在 `logs/django.log`。

## 🔧 配置说明

### 环境变量

在 `.env` 文件中配置以下变量：

```env
# Django配置
SECRET_KEY=your-secret-key
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# 百度千帆AI配置
QIANFAN_ACCESS_KEY=your-access-key
QIANFAN_SECRET_KEY=your-secret-key
```

### CORS设置

已配置CORS允许前端访问，默认允许：
- http://localhost:5173
- http://127.0.0.1:5173
- http://192.168.3.115:5173

## 🧪 测试

```bash
# 运行测试
python manage.py test

# 运行特定应用的测试
python manage.py test accounts
python manage.py test emotions
python manage.py test ai_analysis
```

## 📦 部署

### 生产环境设置

1. 设置 `DEBUG=False`
2. 配置正确的 `ALLOWED_HOSTS`
3. 使用生产数据库（MySQL/PostgreSQL）
4. 配置静态文件服务
5. 使用WSGI服务器（如Gunicorn）

### Docker部署

```bash
# 构建镜像
docker build -t emotion-diary-api .

# 运行容器
docker run -p 8000:8000 emotion-diary-api
```

## 🤝 贡献

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 支持

如有问题或建议，请提交 Issue 或联系开发团队。

---

**AI情绪日记** - 用AI技术帮助用户更好地理解和管理情绪 💙 