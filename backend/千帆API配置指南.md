# 百度千帆API Key配置指南

## 📋 重要更新

⚠️ **千帆平台已升级**：平台不再支持传统的AK/SK、IAM认证、应用ID等方式，现在只支持**API Key Bearer Token认证**。

## 🚀 快速配置步骤

### 1. 获取API Key

根据[官方文档](https://cloud.baidu.com/doc/qianfan-api/s/ym9chdsy5)，获取API Key的步骤如下：

1. **登录百度智能云控制台**
   - 访问：https://console.bce.baidu.com/
   - 使用百度账号登录

2. **进入安全认证页面**
   - 在控制台中找到"安全认证"
   - 点击"API Key"选项

3. **创建API Key**
   - 点击"创建API Key"
   - 选择"千帆ModelBuilder"
   - 如果已有API Key，可跳过此步骤

4. **配置资源**
   - 选择"所有资源"（推荐）或"特定资源"
   - 所有资源：应用ID对应的应用都可以使用该API Key
   - 特定资源：只有特定应用可以使用该API Key

5. **获取API Key值**
   - 点击确定后，在API Key列表中查看API Key值
   - **重要**：API Key值永久有效，请妥善保管

### 2. 配置项目

#### 步骤1：复制配置文件
```bash
cd backend
cp env.example .env
```

#### 步骤2：编辑配置文件
打开 `backend/.env` 文件，找到千帆配置部分：

```env
# 百度千帆AI配置 (使用API Key Bearer Token认证)
QIANFAN_API_KEY=your-api-key
```

将 `your-api-key` 替换为您从千帆平台获取的实际API Key。

#### 步骤3：验证配置
```bash
python verify_qianfan_config.py
```

#### 步骤4：重启服务
```bash
cd backend
python manage.py runserver
```

## 🔍 配置验证

### 成功配置的输出示例：
```
🚀 千帆AI服务配置验证
==================================================
🔍 检查环境变量配置...

✅ 找到 1 种有效认证配置:
   ✅ API Key Bearer Token认证 (当前支持)

🔍 检查千帆SDK...
✅ 千帆服务已配置

🔍 测试AI服务初始化...
✅ AI服务初始化成功

🔍 测试API调用...
✅ API调用成功

🎯 总体状态: 4/4 项检查通过
🎉 恭喜！千帆AI服务配置完全正常
```

## 📍 配置文件位置

您需要在以下位置输入配置信息：

### 主要配置文件：`backend/.env`
```env
# Django配置
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.3.115

# 数据库配置
DB_ENGINE=django.db.backends.sqlite3
DB_NAME=db.sqlite3

# 百度千帆AI配置 (在这里输入您的API Key)
QIANFAN_API_KEY=在这里输入您的API Key

# 其他配置...
```

## 🔧 技术实现

### API调用方式
根据官方文档，现在使用以下方式调用API：

```bash
curl -X POST 'https://qianfan.baidubce.com/v2/chat/completions' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer your-api-key' \
  -d '{
    "model": "ernie-3.5-8k",
    "messages": [
        {
            "role": "user",
            "content": "你好"
        }
    ]
  }'
```

### 代码实现
项目已更新为直接调用HTTP API，使用Bearer Token认证：

- **认证方式**：`Authorization: Bearer {API_KEY}`
- **API端点**：`https://qianfan.baidubce.com/v2/chat/completions`
- **模型**：`ernie-3.5-8k`

## ⚠️ 重要提醒

1. **平台升级**：
   - 千帆平台已不支持AK/SK、IAM认证、应用ID等旧方式
   - 只支持API Key Bearer Token认证

2. **密钥安全**：
   - API Key值永久有效，请妥善保管
   - 不要将真实的API Key提交到代码仓库
   - `.env` 文件已添加到 `.gitignore` 中

3. **重启服务**：
   - 修改 `.env` 文件后，必须重启Django服务才能生效

4. **测试验证**：
   - 配置完成后，务必运行验证脚本确认配置正确

## 🆘 常见问题

### Q: 在哪里找到API Key？
A: 百度智能云控制台 → 安全认证 → API Key → 创建API Key

### Q: 配置后显示"未找到有效的认证配置"？
A: 检查以下几点：
- `.env` 文件是否在 `backend` 目录下
- API Key是否正确复制（注意前后不要有空格）
- 是否重启了Django服务

### Q: API调用失败怎么办？
A: 
1. 检查网络连接是否正常
2. 确认API Key是否有效和正确
3. 查看Django日志文件：`backend/logs/django.log`
4. 确认API Key已配置对应的资源权限

### Q: 旧的AK/SK配置还能用吗？
A: 不能。千帆平台已升级，不再支持AK/SK等旧的认证方式，必须使用API Key。

## 🎯 验证成功后

配置成功后，您的AI情绪日记APP将：

- ✅ 使用真实的ERNIE-Bot进行情绪分析
- ✅ 提供AI驱动的个性化建议
- ✅ 生成深度的情绪洞察报告
- ✅ 前端显示"ERNIE-Bot驱动"状态

如果API暂时不可用，系统会自动降级到基础分析模式，确保功能正常使用。

## 📚 参考资料

- [千帆API认证鉴权官方文档](https://cloud.baidu.com/doc/qianfan-api/s/ym9chdsy5)
- [百度智能云控制台](https://console.bce.baidu.com/)
- [千帆大模型平台](https://cloud.baidu.com/product/wenxinworkshop) 