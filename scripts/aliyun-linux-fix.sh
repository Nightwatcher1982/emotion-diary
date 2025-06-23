#!/bin/bash

# 阿里云Linux服务器修复脚本

set -e

echo "🔧 阿里云Linux服务器修复脚本"
echo "================================"

# 配置
SERVER_HOST="47.239.83.46"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"

echo "📋 修复配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo ""

# 创建阿里云Linux专用修复脚本
cat > /tmp/aliyun-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 开始修复阿里云Linux环境..."

# 修复阿里云Linux yum源
echo "🔧 修复阿里云Linux yum源..."

# 备份原有源
mkdir -p /etc/yum.repos.d/backup
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ 2>/dev/null || true

# 配置阿里云Linux 3源
cat > /etc/yum.repos.d/alinux.repo << 'ALINUX_EOF'
[alinux3-os]
name=Alibaba Cloud Linux 3 - Os
baseurl=http://mirrors.aliyun.com/alinux/3/os/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/alinux/RPM-GPG-KEY-ALINUX-3

[alinux3-updates]
name=Alibaba Cloud Linux 3 - Updates
baseurl=http://mirrors.aliyun.com/alinux/3/updates/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/alinux/RPM-GPG-KEY-ALINUX-3

[alinux3-extras]
name=Alibaba Cloud Linux 3 - Extras
baseurl=http://mirrors.aliyun.com/alinux/3/extras/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/alinux/RPM-GPG-KEY-ALINUX-3

[epel]
name=Extra Packages for Enterprise Linux 8 - x86_64
baseurl=http://mirrors.aliyun.com/epel/8/Everything/x86_64
enabled=1
gpgcheck=0
ALINUX_EOF

# 清理缓存
yum clean all
yum makecache

echo "📦 安装基础包..."
yum install -y wget curl vim git gcc gcc-c++ make openssl-devel libffi-devel sqlite-devel

echo "🐍 安装Python 3..."
yum install -y python3 python3-pip python3-devel

# 检查Python版本
python3 --version

# 升级pip
echo "⬆️ 升级pip..."
python3 -m pip install --upgrade pip --user || {
    echo "使用备用方法升级pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py --user
    rm get-pip.py
}

# 进入项目目录
cd /home/root/emotion-diary/backend

# 创建虚拟环境
echo "🏗️ 创建Python虚拟环境..."
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

# 启动服务
echo "🚀 启动服务..."
systemctl daemon-reload
systemctl enable emotion-diary
systemctl restart emotion-diary

# 等待服务启动
sleep 5

echo "✅ 阿里云Linux环境修复完成！"
echo ""
echo "📊 服务状态:"
systemctl status emotion-diary --no-pager || true
echo ""
echo "🌐 访问地址:"
echo "  前端: http://47.239.83.46/"
echo "  后端API: http://47.239.83.46:8000/"
echo "  管理后台: http://47.239.83.46:8000/admin/"
echo "  管理员账号: admin/admin123"
echo ""
echo "🔍 最近日志:"
journalctl -u emotion-diary --no-pager -n 15 || true

# 测试API是否可访问
echo ""
echo "🧪 测试API连接..."
curl -s http://localhost:8000/api/ || echo "API测试失败，请检查服务状态"
EOF

# 上传并执行修复脚本
echo "📤 上传修复脚本到服务器..."
scp -i "$SSH_KEY_PATH" /tmp/aliyun-fix.sh "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔧 执行阿里云Linux修复..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "chmod +x /tmp/aliyun-fix.sh && /tmp/aliyun-fix.sh"

echo ""
echo "🎉 阿里云Linux部署修复完成！"
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
echo ""
echo "🔍 查看日志:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'journalctl -u emotion-diary -f'" 