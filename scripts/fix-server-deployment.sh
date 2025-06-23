#!/bin/bash

# 服务器部署修复脚本
# 解决Python版本和依赖安装问题

set -e

echo "🔧 服务器部署修复脚本"
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

# 创建修复脚本
cat > /tmp/server-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 开始修复服务器环境..."

# 更新系统包
echo "📦 更新系统包..."
yum update -y

# 安装Python 3.8或更高版本
echo "🐍 检查Python版本..."
python3 --version || {
    echo "安装Python 3.8..."
    yum install -y python38 python38-pip python38-devel
    alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
}

# 升级pip
echo "⬆️ 升级pip..."
python3 -m pip install --upgrade pip

# 安装必要的系统依赖
echo "📦 安装系统依赖..."
yum install -y gcc gcc-c++ make openssl-devel libffi-devel sqlite-devel

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

# 执行数据库迁移
echo "🗄️ 执行数据库迁移..."
python manage.py makemigrations
python manage.py migrate

# 收集静态文件
echo "📁 收集静态文件..."
python manage.py collectstatic --noinput

# 创建超级用户（如果不存在）
echo "👤 创建管理员用户..."
python manage.py shell << 'PYTHON_EOF'
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print("管理员用户创建成功: admin/admin123")
else:
    print("管理员用户已存在")
PYTHON_EOF

# 配置防火墙
echo "🔥 配置防火墙..."
firewall-cmd --permanent --add-port=8000/tcp || true
firewall-cmd --permanent --add-port=80/tcp || true
firewall-cmd --permanent --add-port=443/tcp || true
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
systemctl start emotion-diary

echo "✅ 服务器环境修复完成！"
echo ""
echo "📊 服务状态:"
systemctl status emotion-diary --no-pager
echo ""
echo "🌐 访问地址:"
echo "  前端: http://47.239.83.46/"
echo "  后端API: http://47.239.83.46:8000/"
echo "  管理后台: http://47.239.83.46:8000/admin/"
echo "  管理员账号: admin/admin123"
EOF

# 上传并执行修复脚本
echo "📤 上传修复脚本到服务器..."
scp -i "$SSH_KEY_PATH" /tmp/server-fix.sh "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔧 执行服务器修复..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "chmod +x /tmp/server-fix.sh && /tmp/server-fix.sh"

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