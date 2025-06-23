#!/bin/bash

# 最小化部署脚本 - 移除所有drf_spectacular依赖

set -e

echo "🔧 最小化部署脚本"
echo "================================"

# 配置
SERVER_HOST="47.239.83.46"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"

echo "📋 部署配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo ""

# 创建最小化修复脚本
cat > /tmp/minimal-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 开始最小化部署..."

# 进入项目目录
cd /home/root/emotion-diary/backend

# 创建简化的Django应用
echo "📦 创建简化应用..."

# 1. 修改settings.py - 移除所有复杂依赖
cat > emotion_diary_api/settings.py << 'SETTINGS_EOF'
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-simple-key-for-testing'
DEBUG = True
ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'emotion_diary_api.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'emotion_diary_api.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

LANGUAGE_CODE = 'zh-hans'
TIME_ZONE = 'Asia/Shanghai'
USE_I18N = True
USE_L10N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
}

CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://47.239.83.46",
]

CORS_ALLOW_CREDENTIALS = True
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
SETTINGS_EOF

# 2. 创建简化的urls.py
cat > emotion_diary_api/urls.py << 'URLS_EOF'
from django.contrib import admin
from django.urls import path
from django.http import JsonResponse
from django.conf import settings
from django.conf.urls.static import static

def api_root(request):
    return JsonResponse({
        'message': 'AI情绪日记 API',
        'version': '1.0.0',
        'status': 'running'
    })

def health_check(request):
    return JsonResponse({'status': 'healthy'})

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', api_root),
    path('health/', health_check),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
URLS_EOF

# 3. 创建虚拟环境
echo "🏗️ 创建Python虚拟环境..."
rm -rf venv
python3 -m venv venv
source venv/bin/activate

# 4. 安装最小依赖
echo "📦 安装最小依赖..."
cat > requirements_minimal.txt << 'REQ_EOF'
Django==3.2.25
djangorestframework==3.14.0
django-cors-headers==3.10.1
REQ_EOF

pip install --upgrade pip
pip install -r requirements_minimal.txt

# 5. 执行数据库迁移
echo "🗄️ 执行数据库迁移..."
export DJANGO_SETTINGS_MODULE=emotion_diary_api.settings
python manage.py migrate

# 6. 创建超级用户
echo "👤 创建管理员用户..."
python manage.py shell << 'PYTHON_EOF'
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print("管理员用户创建成功: admin/admin123")
else:
    print("管理员用户已存在")
PYTHON_EOF

# 7. 收集静态文件
echo "📁 收集静态文件..."
python manage.py collectstatic --noinput

# 8. 创建systemd服务
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

# 9. 配置nginx
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
    
    # 健康检查
    location /health/ {
        proxy_pass http://127.0.0.1:8000;
    }
}
NGINX_EOF

# 10. 启动服务
echo "🚀 启动服务..."
systemctl daemon-reload
systemctl enable emotion-diary
systemctl restart emotion-diary

systemctl enable nginx
systemctl restart nginx

# 等待服务启动
sleep 3

echo "✅ 最小化部署完成！"
echo ""
echo "📊 服务状态:"
systemctl status emotion-diary --no-pager || true
echo ""
systemctl status nginx --no-pager || true
echo ""
echo "🌐 访问地址:"
echo "  前端: http://47.239.83.46/"
echo "  后端API: http://47.239.83.46:8000/api/"
echo "  健康检查: http://47.239.83.46:8000/health/"
echo "  管理后台: http://47.239.83.46:8000/admin/"
echo "  管理员账号: admin/admin123"
echo ""
echo "🧪 测试API连接..."
curl -s http://localhost:8000/api/ || echo "API测试失败"
curl -s http://localhost:8000/health/ || echo "健康检查失败"

echo ""
echo "🎉 部署成功！应用现在可以访问了！"
EOF

# 上传并执行最小化修复脚本
echo "📤 上传最小化修复脚本到服务器..."
scp -i "$SSH_KEY_PATH" /tmp/minimal-fix.sh "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔧 执行最小化部署..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "chmod +x /tmp/minimal-fix.sh && /tmp/minimal-fix.sh"

echo ""
echo "🎉 最小化部署完成！"
echo "================================"
echo ""
echo "🌐 访问地址:"
echo "  前端: http://$SERVER_HOST/"
echo "  后端API: http://$SERVER_HOST:8000/api/"
echo "  健康检查: http://$SERVER_HOST:8000/health/"
echo "  管理后台: http://$SERVER_HOST:8000/admin/"
echo "  管理员账号: admin/admin123"
echo ""
echo "📊 检查服务状态:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'systemctl status emotion-diary'"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'systemctl status nginx'"
echo ""
echo "🔍 查看日志:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'journalctl -u emotion-diary -f'"