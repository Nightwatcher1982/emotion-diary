#!/bin/bash

# 完整修复脚本 - 修改所有Django配置

set -e

echo "🔧 完整修复脚本"
echo "================================"

# 配置
SERVER_HOST="47.239.83.46"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"

echo "📋 修复配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo ""

# 创建完整修复脚本
cat > /tmp/complete-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 开始完整修复..."

# 进入项目目录
cd /home/root/emotion-diary/backend

# 修改urls.py文件，移除drf_spectacular引用
echo "⚙️ 修改urls.py文件..."
cp emotion_diary_api/urls.py emotion_diary_api/urls.py.backup

cat > emotion_diary_api/urls.py << 'URLS_EOF'
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/accounts/', include('accounts.urls')),
    path('api/emotions/', include('emotions.urls')),
    path('api/ai-analysis/', include('ai_analysis.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
URLS_EOF

# 创建虚拟环境
echo "🏗️ 创建Python虚拟环境..."
rm -rf venv
python3 -m venv venv
source venv/bin/activate

# 升级pip
echo "⬆️ 升级pip..."
pip install --upgrade pip

# 安装依赖
echo "📦 安装Python依赖..."
pip install -r requirements.txt

# 设置Django设置
export DJANGO_SETTINGS_MODULE=emotion_diary_api.settings

# 执行数据库迁移
echo "🗄️ 执行数据库迁移..."
python manage.py makemigrations accounts || true
python manage.py makemigrations emotions || true
python manage.py makemigrations ai_analysis || true
python manage.py migrate

# 收集静态文件
echo "📁 收集静态文件..."
python manage.py collectstatic --noinput || true

# 创建超级用户（如果不存在）
echo "👤 创建管理员用户..."
python manage.py shell << 'PYTHON_EOF'
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emotion_diary_api.settings')
django.setup()

from django.contrib.auth.models import User
try:
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
        print("管理员用户创建成功: admin/admin123")
    else:
        print("管理员用户已存在")
except Exception as e:
    print(f"创建用户时出错: {e}")
PYTHON_EOF

# 配置防火墙
echo "🔥 配置防火墙..."
firewall-cmd --permanent --add-port=8000/tcp || true
firewall-cmd --permanent --add-port=80/tcp || true
firewall-cmd --reload || true

# 创建systemd服务文件
echo "⚙️ 创建系统服务..."
cat > /etc/systemd/system/emotion-diary.service << 'SERVICE_EOF'
[Unit]
Description=Emotion Diary Django Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/root/emotion-diary/backend
Environment=PATH=/home/root/emotion-diary/backend/venv/bin
Environment=DJANGO_SETTINGS_MODULE=emotion_diary_api.settings
ExecStart=/home/root/emotion-diary/backend/venv/bin/python manage.py runserver 0.0.0.0:8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# 配置nginx
echo "🌐 配置nginx..."
cat > /etc/nginx/conf.d/emotion-diary.conf << 'NGINX_EOF'
server {
    listen 80;
    server_name 47.239.83.46;
    
    # 前端静态文件
    location / {
        root /home/root/emotion-diary/frontend/dist/build/h5;
        try_files $uri $uri/ /index.html;
        index index.html;
    }
    
    # API代理
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 管理后台代理
    location /admin/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 静态文件代理
    location /static/ {
        proxy_pass http://127.0.0.1:8000;
    }
    
    # 媒体文件代理
    location /media/ {
        proxy_pass http://127.0.0.1:8000;
    }
}
NGINX_EOF

# 启动服务
echo "🚀 启动服务..."
systemctl daemon-reload
systemctl enable emotion-diary
systemctl restart emotion-diary

systemctl enable nginx
systemctl restart nginx

# 等待服务启动
sleep 5

echo "✅ 完整修复完成！"
echo ""
echo "📊 服务状态:"
systemctl status emotion-diary --no-pager || true
echo ""
systemctl status nginx --no-pager || true
echo ""
echo "🌐 访问地址:"
echo "  前端: http://47.239.83.46/"
echo "  后端API: http://47.239.83.46:8000/"
echo "  管理后台: http://47.239.83.46:8000/admin/"
echo "  管理员账号: admin/admin123"
echo ""
echo "🔍 最近日志:"
journalctl -u emotion-diary --no-pager -n 10 || true

# 测试API是否可访问
echo ""
echo "🧪 测试API连接..."
curl -s http://localhost:8000/api/ || echo "API测试失败，请检查服务状态"
curl -s http://localhost:8000/admin/ || echo "管理后台测试失败"

echo ""
echo "🎉 部署完成！现在可以访问应用了！"
EOF

# 上传并执行修复脚本
echo "📤 上传修复脚本到服务器..."
scp -i "$SSH_KEY_PATH" /tmp/complete-fix.sh "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔧 执行完整修复..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "chmod +x /tmp/complete-fix.sh && /tmp/complete-fix.sh"

echo ""
echo "🎉 完整部署修复完成！"
echo "================================"
echo ""
echo "🌐 访问地址:"
echo "  前端: http://$SERVER_HOST/"
echo "  后端API: http://$SERVER_HOST:8000/"
echo "  管理后台: http://$SERVER_HOST:8000/admin/"
echo "  管理员账号: admin/admin123"
echo ""
echo "📊 检查服务状态:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'systemctl status emotion-diary'"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'systemctl status nginx'"
echo ""
echo "🔍 查看日志:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'journalctl -u emotion-diary -f'"
EOF 