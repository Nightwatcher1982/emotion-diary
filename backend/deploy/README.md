# 🚀 AI情绪日记 - 阿里云部署指南

## 📋 概述

本指南将帮助你将AI情绪日记后端服务部署到阿里云ECS服务器上，使用Nginx + Gunicorn + Django + MySQL + Redis的生产环境架构。

## 🛠️ 技术栈

- **Web服务器**: Nginx
- **应用服务器**: Gunicorn
- **Web框架**: Django 4.2.7
- **数据库**: MySQL 8.0
- **缓存**: Redis
- **操作系统**: Ubuntu 20.04 LTS
- **进程管理**: systemd
- **SSL证书**: Let's Encrypt

## 📦 阿里云资源准备

### 1. ECS实例配置
```
实例规格: ecs.c6.large (2核4GB) 或更高
操作系统: Ubuntu 20.04 LTS 64位
存储: 40GB系统盘 + 100GB数据盘（可选）
网络: 专有网络VPC
公网IP: 弹性公网IP
安全组: 开放22(SSH)、80(HTTP)、443(HTTPS)端口
```

### 2. 域名配置
- 在阿里云域名控制台添加A记录
- 将域名指向ECS实例的公网IP
- 建议同时配置www和@记录

### 3. 安全组配置
```bash
# 入方向规则
22/22    SSH        0.0.0.0/0
80/80    HTTP       0.0.0.0/0  
443/443  HTTPS      0.0.0.0/0

# 出方向规则
全部端口   全部协议    0.0.0.0/0
```

## 🚀 自动化部署

### 1. 连接服务器
```bash
ssh root@your-server-ip
```

### 2. 下载部署脚本
```bash
# 上传项目代码到服务器
scp -r ./backend root@your-server-ip:/tmp/emotion-diary

# 或者使用Git克隆
git clone https://github.com/your-username/emotion-diary.git /tmp/emotion-diary
```

### 3. 运行自动化部署
```bash
cd /tmp/emotion-diary/backend/deploy
chmod +x deploy.sh
./deploy.sh
```

部署脚本将自动完成：
- ✅ 系统依赖安装
- ✅ 数据库配置
- ✅ Redis配置
- ✅ Python环境设置
- ✅ Django应用配置
- ✅ Nginx配置
- ✅ systemd服务配置
- ✅ 防火墙配置
- ✅ 健康检查

## 🔧 手动部署步骤

如果需要手动部署，请按以下步骤操作：

### 1. 系统更新和依赖安装
```bash
# 更新系统
apt update && apt upgrade -y

# 安装基础依赖
apt install -y python3 python3-pip python3-venv python3-dev \
    nginx mysql-server redis-server git curl wget unzip \
    supervisor certbot python3-certbot-nginx build-essential \
    libmysqlclient-dev pkg-config
```

### 2. 创建项目用户和目录
```bash
# 创建项目用户
useradd -r -s /bin/false www-data

# 创建项目目录
mkdir -p /var/www/emotion-diary
mkdir -p /var/log/emotion-diary
mkdir -p /var/run/emotion-diary
mkdir -p /var/backups/emotion-diary

# 设置权限
chown -R www-data:www-data /var/www/emotion-diary
chown -R www-data:www-data /var/log/emotion-diary
chown -R www-data:www-data /var/run/emotion-diary
```

### 3. 配置MySQL数据库
```bash
# 启动MySQL服务
systemctl start mysql
systemctl enable mysql

# 配置数据库
mysql -u root -p <<EOF
CREATE DATABASE emotion_diary CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'emotion_user'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON emotion_diary.* TO 'emotion_user'@'localhost';
FLUSH PRIVILEGES;
EOF
```

### 4. 配置Redis
```bash
systemctl start redis-server
systemctl enable redis-server
```

### 5. 部署Django应用
```bash
# 进入项目目录
cd /var/www/emotion-diary

# 上传代码
# (通过Git、SCP或其他方式)

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install --upgrade pip
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑.env文件，配置数据库等信息

# 数据库迁移
python manage.py migrate

# 收集静态文件
python manage.py collectstatic --noinput

# 创建超级用户
python manage.py createsuperuser

# 设置权限
chown -R www-data:www-data .
```

### 6. 配置Nginx
```bash
# 复制Nginx配置
cp deploy/nginx.conf /etc/nginx/sites-available/emotion-diary

# 启用站点
ln -s /etc/nginx/sites-available/emotion-diary /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试配置
nginx -t

# 重启Nginx
systemctl restart nginx
systemctl enable nginx
```

### 7. 配置systemd服务
```bash
# 复制服务文件
cp deploy/systemd_service.conf /etc/systemd/system/emotion-diary.service

# 启动服务
systemctl daemon-reload
systemctl start emotion-diary
systemctl enable emotion-diary
```

### 8. 配置SSL证书
```bash
# 使用Let's Encrypt获取SSL证书
certbot --nginx -d your-domain.com -d www.your-domain.com
```

## 🔍 部署验证

### 1. 服务状态检查
```bash
# 检查所有服务状态
systemctl status emotion-diary
systemctl status nginx
systemctl status mysql
systemctl status redis-server

# 检查端口监听
netstat -tlnp | grep -E ':(80|443|8000|3306|6379)'
```

### 2. API测试
```bash
# 测试API响应
curl http://your-domain.com/api/docs/
curl https://your-domain.com/api/docs/

# 测试健康检查
curl http://your-domain.com/health/
```

### 3. 日志查看
```bash
# Django应用日志
journalctl -u emotion-diary -f

# Nginx日志
tail -f /var/log/nginx/emotion-diary-access.log
tail -f /var/log/nginx/emotion-diary-error.log

# Gunicorn日志
tail -f /var/log/emotion-diary/gunicorn-access.log
tail -f /var/log/emotion-diary/gunicorn-error.log
```

## 🔧 配置文件说明

### 1. 生产环境设置 (`settings_production.py`)
```python
# 主要配置项
DEBUG = False
ALLOWED_HOSTS = ['your-domain.com', 'www.your-domain.com']
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'emotion_diary',
        # ... MySQL配置
    }
}
```

### 2. Nginx配置 (`nginx.conf`)
- HTTP到HTTPS重定向
- SSL证书配置
- 静态文件服务
- API代理配置
- 安全头设置

### 3. Gunicorn配置 (`gunicorn_config.py`)
- 工作进程配置
- 日志配置
- 性能优化设置

### 4. systemd服务配置 (`systemd_service.conf`)
- 服务依赖关系
- 自动重启配置
- 环境变量设置

## 📊 性能优化

### 1. 数据库优化
```sql
-- MySQL配置优化
[mysqld]
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
max_connections = 200
query_cache_size = 64M
```

### 2. Redis配置
```conf
# Redis配置优化
maxmemory 512mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

### 3. Nginx缓存
```nginx
# 静态文件缓存
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 🔒 安全配置

### 1. 防火墙配置
```bash
# 使用ufw配置防火墙
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
```

### 2. 定期备份
```bash
# 创建备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u emotion_user -p emotion_diary > /var/backups/emotion-diary/db_$DATE.sql
tar -czf /var/backups/emotion-diary/media_$DATE.tar.gz /var/www/emotion-diary/media/
```

### 3. SSL安全配置
- 使用Let's Encrypt证书
- 配置HSTS头
- 禁用不安全的SSL协议

## 🚨 故障排除

### 常见问题

#### 1. Django服务无法启动
```bash
# 查看详细错误信息
journalctl -u emotion-diary -n 50

# 检查配置文件
python manage.py check --deploy
```

#### 2. 数据库连接失败
```bash
# 检查MySQL服务状态
systemctl status mysql

# 测试数据库连接
mysql -u emotion_user -p emotion_diary
```

#### 3. 静态文件404错误
```bash
# 重新收集静态文件
python manage.py collectstatic --noinput

# 检查Nginx配置
nginx -t
```

#### 4. SSL证书问题
```bash
# 检查证书状态
certbot certificates

# 续期证书
certbot renew --dry-run
```

## 📱 前端配置更新

部署完成后，需要更新前端配置：

```typescript
// frontend/src/utils/api.ts
const API_BASE_URL = 'https://your-domain.com/api/v1'
```

## 🔄 持续部署

### 1. 创建更新脚本
```bash
#!/bin/bash
# update.sh
cd /var/www/emotion-diary
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
systemctl restart emotion-diary
```

### 2. 设置Webhook（可选）
配置Git仓库Webhook，实现代码推送自动部署。

## 📞 支持和维护

### 监控指标
- 服务器CPU、内存使用率
- API响应时间
- 数据库连接数
- 错误日志频率

### 定期维护
- 系统更新
- 证书续期
- 数据库备份
- 日志清理

---

**部署完成后，你的AI情绪日记API将运行在：**
- 🌐 API文档: `https://your-domain.com/api/docs/`
- 🔧 管理后台: `https://your-domain.com/admin/`
- 📊 健康检查: `https://your-domain.com/health/`

如有问题，请查看日志文件或联系技术支持。 