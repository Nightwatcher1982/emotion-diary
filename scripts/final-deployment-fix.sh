#!/bin/bash

# 最终部署修复脚本

set -e

echo "🔧 最终部署修复脚本"
echo "================================"

# 配置
SERVER_HOST="47.239.83.46"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"

echo "📋 修复配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo ""

# 创建最终修复脚本
cat > /tmp/final-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 开始最终部署修复..."

# 安装nginx
echo "📦 安装nginx..."
yum install -y nginx

# 进入项目目录
cd /home/root/emotion-diary/backend

# 备份原有requirements文件
cp requirements.txt requirements.txt.backup

# 使用简化的requirements
cat > requirements.txt << 'FINAL_REQ_EOF'
Django==3.2.25
djangorestframework==3.14.0
django-cors-headers==3.10.1
python-decouple==3.8
requests==2.25.1
Pillow==8.4.0
PyYAML==5.4.1
pytz==2021.3
sqlparse==0.4.4
FINAL_REQ_EOF

# 修改Django设置，移除drf_spectacular
echo "⚙️ 修改Django设置..."
cp emotion_diary_api/settings.py emotion_diary_api/settings.py.backup

cat > emotion_diary_api/settings.py << 'SETTINGS_EOF'
import os
from pathlib import Path
from decouple import config

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = config('SECRET_KEY', default='django-insecure-your-secret-key-here')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = config('DEBUG', default=True, cast=bool)

ALLOWED_HOSTS = ['*']

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'accounts',
    'emotions',
    'ai_analysis',
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

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'zh-hans'
TIME_ZONE = 'Asia/Shanghai'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

# CORS settings
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://47.239.83.46",
]

CORS_ALLOW_CREDENTIALS = True

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR, 'logs', 'django.log'),
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}

# 创建日志目录
os.makedirs(os.path.join(BASE_DIR, 'logs'), exist_ok=True)
SETTINGS_EOF

# 创建虚拟环境
echo "🏗️ 创建Python虚拟环境..."
rm -rf venv
python3 -m venv venv
source venv/bin/activate

# 升级虚拟环境中的pip
echo "⬆️ 升级虚拟环境pip..."
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

echo "✅ 最终部署修复完成！"
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
EOF

# 上传并执行修复脚本
echo "📤 上传修复脚本到服务器..."
scp -i "$SSH_KEY_PATH" /tmp/final-fix.sh "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔧 执行最终修复..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "chmod +x /tmp/final-fix.sh && /tmp/final-fix.sh"

echo ""
echo "🎉 最终部署修复完成！"
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