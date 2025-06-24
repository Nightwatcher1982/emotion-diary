# AI情绪日记应用 - 服务器Docker部署指南

## 📋 部署概述

本指南将帮助您在生产服务器上部署AI情绪日记应用的v1.0.0版本。该版本已经完全修复了所有已知问题，包括API错误、MIME类型问题等，可以直接进行生产部署。

## 🎯 部署架构

```
[用户] → [nginx:80/443] → [Django:8000] ← [Redis:6379]
                ↓
        [静态文件服务]
```

### 核心组件
- **nginx**: 反向代理 + 静态文件服务
- **Django**: API服务 + 前端应用服务
- **Redis**: 缓存服务
- **SQLite**: 数据库（可升级为PostgreSQL）

## 🚀 快速部署

### 1. 服务器准备

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker和Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 将用户添加到docker组
sudo usermod -aG docker $USER
# 重新登录或执行：newgrp docker
```

### 2. 获取代码

```bash
# 克隆项目
git clone https://github.com/Nightwatcher1982/emotion-diary.git
cd emotion-diary

# 切换到稳定版本
git checkout v1.0.0
```

### 3. 环境配置

```bash
# 创建环境变量文件
cp docker.env .env

# 编辑环境变量（重要！）
nano .env
```

**关键环境变量配置**：
```bash
# 数据库配置
DATABASE_URL=sqlite:///app/backend/db.sqlite3

# Django配置
SECRET_KEY=your-very-secure-secret-key-here
DEBUG=False
ALLOWED_HOSTS=your-domain.com,your-server-ip

# 千帆AI配置（可选，用于AI分析功能）
QIANFAN_API_KEY=your-qianfan-api-key

# 微信小程序配置（可选）
WECHAT_APPID=your-wechat-appid
WECHAT_SECRET=your-wechat-secret

# 短信服务配置（可选）
SMS_ACCESS_KEY_ID=your-sms-access-key
SMS_ACCESS_KEY_SECRET=your-sms-secret
```

### 4. 一键部署

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

## 🔧 详细配置

### nginx配置优化

如果需要自定义nginx配置，编辑 `nginx.conf`：

```nginx
# SSL配置（推荐）
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /path/to/your/cert.pem;
    ssl_certificate_key /path/to/your/key.pem;
    
    # 其他配置保持不变...
}

# HTTP重定向到HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### 数据库升级（可选）

如需使用PostgreSQL替代SQLite：

1. **修改docker-compose.yml**：
```yaml
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: emotion_diary
      POSTGRES_USER: emotion_user
      POSTGRES_PASSWORD: your-db-password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - emotion-network

volumes:
  postgres_data:
```

2. **更新环境变量**：
```bash
DATABASE_URL=postgresql://emotion_user:your-db-password@db:5432/emotion_diary
```

## 📊 健康检查

### 服务状态检查

```bash
# 检查所有容器状态
docker-compose ps

# 检查应用健康状态
curl http://your-server-ip/health/

# 预期响应
{
  "status": "healthy",
  "message": "AI情绪日记API服务运行正常",
  "version": "1.0.0"
}
```

### API功能测试

```bash
# 测试短信API
curl -X POST http://your-server-ip/api/v1/auth/sms/send/ \
  -H "Content-Type: application/json" \
  -d '{"phone": "13800138000"}'

# 测试微信登录API
curl -X POST http://your-server-ip/api/v1/auth/wechat/login/ \
  -H "Content-Type: application/json" \
  -d '{"code": "test_code", "nickname": "测试用户"}'
```

### 前端访问测试

```bash
# 检查前端页面
curl -s http://your-server-ip/ | grep "<title>"
# 预期输出：<title>心晴日记</title>

# 检查静态资源
curl -I http://your-server-ip/assets/index-ed4fe727.js
# 预期：Content-Type: application/javascript
```

## 🔒 安全配置

### 1. 防火墙设置

```bash
# 安装ufw
sudo apt install ufw

# 配置防火墙规则
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 启用防火墙
sudo ufw enable
```

### 2. SSL证书配置

**使用Let's Encrypt免费证书**：

```bash
# 安装certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

### 3. 安全头配置

在nginx.conf中添加安全头：

```nginx
# 安全头
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

## 📈 监控和维护

### 日志管理

```bash
# 查看应用日志
docker-compose logs app

# 查看nginx日志
docker-compose logs nginx

# 查看Redis日志
docker-compose logs redis

# 实时监控所有日志
docker-compose logs -f
```

### 数据备份

```bash
# 创建备份脚本
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
docker-compose exec app python /app/backend/manage.py dumpdata > $BACKUP_DIR/db_backup_$DATE.json

# 备份静态文件
tar -czf $BACKUP_DIR/static_backup_$DATE.tar.gz backend/static/

echo "备份完成: $DATE"
EOF

chmod +x backup.sh

# 设置定时备份
crontab -e
# 添加：0 2 * * * /path/to/backup.sh
```

### 性能优化

```bash
# 查看资源使用情况
docker stats

# 优化Docker容器资源限制
# 在docker-compose.yml中添加：
services:
  app:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
```

## 🚨 故障排除

### 常见问题

1. **容器启动失败**
```bash
# 查看详细错误
docker-compose logs app
docker-compose logs nginx
```

2. **静态文件404错误**
```bash
# 检查静态文件是否存在
docker-compose exec app ls -la /app/backend/static/frontend/

# 重新收集静态文件
docker-compose exec app python /app/backend/manage.py collectstatic --noinput
```

3. **API返回500错误**
```bash
# 检查Django日志
docker-compose exec app tail -f /app/backend/logs/django.log

# 检查数据库连接
docker-compose exec app python /app/backend/manage.py dbshell
```

4. **内存不足**
```bash
# 检查系统资源
free -h
df -h

# 清理Docker资源
docker system prune -a
```

### 重启服务

```bash
# 重启所有服务
docker-compose restart

# 重启单个服务
docker-compose restart app
docker-compose restart nginx
docker-compose restart redis

# 完全重新部署
docker-compose down
docker-compose up -d
```

## 📋 部署检查清单

部署完成后，请检查以下项目：

### ✅ 基础功能
- [ ] 前端页面正常访问：http://your-server-ip/
- [ ] 健康检查通过：http://your-server-ip/health/
- [ ] API接口正常：http://your-server-ip/api/v1/
- [ ] 静态资源加载正常（CSS、JS文件）

### ✅ 认证功能
- [ ] 短信验证码发送正常
- [ ] 微信登录功能正常（如已配置）
- [ ] 用户注册和登录流程完整

### ✅ 核心功能
- [ ] 情绪记录功能正常
- [ ] AI分析功能正常（如已配置千帆API）
- [ ] 统计页面数据显示正常
- [ ] 个人中心功能完整

### ✅ 安全配置
- [ ] 防火墙规则正确配置
- [ ] SSL证书正常工作（如已配置）
- [ ] 敏感信息已正确配置在环境变量中
- [ ] DEBUG模式已关闭

### ✅ 性能监控
- [ ] 容器资源使用正常
- [ ] 日志正常输出
- [ ] 备份策略已设置
- [ ] 监控告警已配置

## 🎯 下一步

部署完成后，您可以：

1. **配置域名**: 将域名指向服务器IP
2. **设置SSL**: 配置HTTPS加密访问
3. **监控配置**: 设置服务监控和告警
4. **性能优化**: 根据实际使用情况优化配置
5. **功能扩展**: 添加更多AI分析功能

## 📞 技术支持

如果在部署过程中遇到问题：

1. 查看本指南的故障排除部分
2. 检查GitHub Issues: https://github.com/Nightwatcher1982/emotion-diary/issues
3. 查看详细的技术文档和API文档

---

**部署成功！** 🎉

您的AI情绪日记应用现在已经在服务器上运行，用户可以通过浏览器访问并使用所有功能。

**访问地址**: http://your-server-ip/ 或 https://your-domain.com/ 