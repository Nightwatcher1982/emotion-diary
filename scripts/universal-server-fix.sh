#!/bin/bash

# 通用服务器部署修复脚本
# 适配不同Linux发行版

set -e

echo "🔧 通用服务器部署修复脚本"
echo "================================"

# 配置
SERVER_HOST="47.239.83.46"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
REMOTE_PATH="/home/root/emotion-diary"

echo "📋 修复配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo "  远程路径: $REMOTE_PATH"
echo ""

# 创建通用修复脚本
cat > /tmp/universal-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 开始修复服务器环境..."

# 检测Linux发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "无法检测操作系统版本"
    exit 1
fi

echo "📋 检测到系统: $OS $VER"

# 修复yum源（如果是CentOS）
if [[ "$OS" == *"CentOS"* ]]; then
    echo "🔧 修复CentOS yum源..."
    
    # 备份原有源
    mkdir -p /etc/yum.repos.d/backup
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ 2>/dev/null || true
    
    # 使用阿里云CentOS 7源
    cat > /etc/yum.repos.d/CentOS-Base.repo << 'YUM_EOF'
[base]
name=CentOS-7 - Base - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/7/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-7 - Updates - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/7/updates/x86_64/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-7 - Extras - mirrors.aliyun.com
baseurl=http://mirrors.aliyun.com/centos/7/extras/x86_64/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[epel]
name=Extra Packages for Enterprise Linux 7 - x86_64
baseurl=http://mirrors.aliyun.com/epel/7/x86_64
failovermethod=priority
enabled=1
gpgcheck=0
YUM_EOF

    # 清理缓存并更新
    yum clean all
    yum makecache
fi

# 安装基础包
echo "📦 安装基础包..."
if command -v yum &> /dev/null; then
    yum install -y wget curl vim git
elif command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y wget curl vim git
fi

# 安装Python 3
echo "🐍 安装Python 3..."
if command -v yum &> /dev/null; then
    # CentOS/RHEL
    yum install -y python3 python3-pip python3-devel gcc gcc-c++ make openssl-devel libffi-devel sqlite-devel
elif command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    apt-get install -y python3 python3-pip python3-dev python3-venv build-essential libssl-dev libffi-dev libsqlite3-dev
fi

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
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=8000/tcp || true
    firewall-cmd --permanent --add-port=80/tcp || true
    firewall-cmd --reload || true
elif command -v ufw &> /dev/null; then
    ufw allow 8000 || true
    ufw allow 80 || true
fi

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
sleep 3

echo "✅ 服务器环境修复完成！"
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
journalctl -u emotion-diary --no-pager -n 10 || true
EOF

# 上传并执行修复脚本
echo "📤 上传修复脚本到服务器..."
scp -i "$SSH_KEY_PATH" /tmp/universal-fix.sh "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔧 执行服务器修复..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "chmod +x /tmp/universal-fix.sh && /tmp/universal-fix.sh"

echo ""
echo "🎉 部署修复完成！"
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