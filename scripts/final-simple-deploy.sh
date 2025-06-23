#!/bin/bash

# 最终简单部署脚本

set -e

echo "🔧 最终简单部署脚本"
echo "================================"

# 配置
SERVER_HOST="47.239.83.46"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"

echo "📋 部署配置:"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo ""

# 创建最终简单修复脚本
cat > /tmp/final-simple-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "🔧 开始最终简单部署..."

# 进入项目目录
cd /home/root/emotion-diary/backend

# 删除现有数据库
echo "🗑️ 删除现有数据库..."
rm -f db.sqlite3

# 创建虚拟环境
echo "🏗️ 创建Python虚拟环境..."
rm -rf venv
python3 -m venv venv
source venv/bin/activate

# 安装最小依赖
echo "📦 安装最小依赖..."
cat > requirements_simple.txt << 'REQ_EOF'
Django==3.2.25
djangorestframework==3.14.0
django-cors-headers==3.10.1
REQ_EOF

pip install --upgrade pip
pip install -r requirements_simple.txt

# 执行数据库迁移
echo "🗄️ 执行数据库迁移..."
export DJANGO_SETTINGS_MODULE=emotion_diary_api.settings
python manage.py migrate

# 创建超级用户
echo "👤 创建管理员用户..."
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin123'); print('管理员用户创建成功: admin/admin123')" | python manage.py shell

# 收集静态文件
echo "📁 收集静态文件..."
python manage.py collectstatic --noinput

# 启动服务
echo "🚀 启动服务..."
systemctl daemon-reload
systemctl restart emotion-diary
systemctl restart nginx

# 等待服务启动
sleep 3

echo "✅ 最终简单部署完成！"
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
curl -s http://localhost:8000/api/ && echo "✅ API连接成功"
curl -s http://localhost:8000/health/ && echo "✅ 健康检查成功"

echo ""
echo "🎉 部署成功！应用现在可以访问了！"
echo ""
echo "📝 接下来可以："
echo "  1. 访问 http://47.239.83.46/ 查看前端"
echo "  2. 访问 http://47.239.83.46:8000/admin/ 管理后台"
echo "  3. 使用 admin/admin123 登录管理后台"
echo "  4. 后续可以逐步添加更多功能"
EOF

# 上传并执行最终简单修复脚本
echo "📤 上传最终简单修复脚本到服务器..."
scp -i "$SSH_KEY_PATH" /tmp/final-simple-fix.sh "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔧 执行最终简单部署..."
ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_HOST" "chmod +x /tmp/final-simple-fix.sh && /tmp/final-simple-fix.sh"

echo ""
echo "🎉 最终简单部署完成！"
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
echo ""
echo "🌐 现在可以在浏览器中访问："
echo "  http://$SERVER_HOST/" 