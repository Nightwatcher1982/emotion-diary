#!/bin/bash

# AI情绪日记 - 快速部署脚本
# 直接配置服务器信息，无需环境变量

# ================================
# 🔧 服务器配置 - 请修改这里
# ================================

SERVER_HOST="47.239.83.46"  # 您的ECS服务器IP
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"

# ================================
# 🚀 开始部署
# ================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🚀 AI情绪日记 - 快速部署${NC}"
echo "=================================="
echo ""

# 检查配置
if [ "$SERVER_HOST" = "YOUR_SERVER_IP_HERE" ]; then
    echo -e "${RED}❌ 请先修改脚本中的服务器IP地址${NC}"
    echo -e "${YELLOW}编辑文件: scripts/quick-deploy.sh${NC}"
    echo -e "${YELLOW}修改第8行: SERVER_HOST=\"您的服务器IP\"${NC}"
    exit 1
fi

PROJECT_DIR="emotion-diary"
REMOTE_PATH="/home/$SERVER_USER/$PROJECT_DIR"

echo -e "${GREEN}📋 部署配置:${NC}"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo "  SSH密钥: $SSH_KEY_PATH"
echo "  远程路径: $REMOTE_PATH"
echo ""

# 检查SSH密钥
if [ ! -f "$SSH_KEY_PATH" ]; then
    SSH_KEY_PATH="$HOME/.ssh/id_rsa"
    if [ ! -f "$SSH_KEY_PATH" ]; then
        echo -e "${RED}❌ SSH私钥未找到${NC}"
        echo "请检查以下路径:"
        echo "  - $HOME/.ssh/emotion-diary-deploy"
        echo "  - $HOME/.ssh/id_rsa"
        exit 1
    fi
    echo -e "${YELLOW}使用SSH密钥: $SSH_KEY_PATH${NC}"
fi

# 测试SSH连接
echo -e "${YELLOW}🧪 测试SSH连接...${NC}"
if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "echo '✅ SSH连接成功'" 2>/dev/null; then
    echo -e "${GREEN}✅ SSH连接正常${NC}"
else
    echo -e "${RED}❌ SSH连接失败${NC}"
    echo "请检查:"
    echo "  1. 服务器IP地址: $SERVER_HOST"
    echo "  2. SSH密钥路径: $SSH_KEY_PATH"
    echo "  3. 服务器SSH服务是否启动"
    echo "  4. 防火墙是否开放22端口"
    exit 1
fi

# 确保在项目根目录
cd "$(dirname "$0")/.."

# 检查并构建前端
echo -e "${YELLOW}🏗️  构建前端...${NC}"
if [ -d "frontend" ]; then
    cd frontend
    if [ -f "package.json" ]; then
        if [ ! -d "node_modules" ]; then
            echo "安装前端依赖..."
            npm install
        fi
        
        echo "构建前端应用..."
        npm run build:h5 || {
            echo -e "${RED}❌ 前端构建失败${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ 前端构建完成${NC}"
    fi
    cd ..
fi

# 创建部署包
echo -e "${YELLOW}📦 创建部署包...${NC}"
TEMP_DIR="/tmp/emotion-diary-deploy-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEMP_DIR"

# 打包文件
tar -cf "$TEMP_DIR.tar" \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='frontend/dist' \
    --exclude='backend/__pycache__' \
    --exclude='backend/*/migrations/__pycache__' \
    --exclude='backend/logs/*.log' \
    --exclude='*.pyc' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    --exclude='._*' \
    --exclude='backend/venv' \
    --exclude='backend/emotion_diary_env' \
    --exclude='test_*.sh' \
    --exclude='*_test.sh' \
    .

# 解压到临时目录
tar -xf "$TEMP_DIR.tar" -C "$TEMP_DIR"
rm "$TEMP_DIR.tar"

# 复制前端构建文件
if [ -d "frontend/dist/build/h5" ]; then
    echo "复制前端构建文件..."
    mkdir -p "$TEMP_DIR/frontend/dist/build"
    cp -r frontend/dist/build/h5 "$TEMP_DIR/frontend/dist/build/"
fi

echo -e "${GREEN}✅ 部署包准备完成${NC}"

# 上传到服务器
echo -e "${YELLOW}📤 上传到服务器...${NC}"

# 创建项目目录并备份
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    if [ ! -d '$REMOTE_PATH' ]; then
        echo '📁 创建项目目录: $REMOTE_PATH'
        mkdir -p '$REMOTE_PATH'
    fi
    
    if [ -d '$REMOTE_PATH/backend' ]; then
        echo '💾 备份现有版本...'
        cp -r '$REMOTE_PATH' '$REMOTE_PATH.backup.$(date +%Y%m%d_%H%M%S)' || true
    fi
"

# 使用scp上传
cd "$TEMP_DIR"
tar -czf "../emotion-diary-deploy.tar.gz" .
cd ..
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
    "emotion-diary-deploy.tar.gz" "$SERVER_USER@$SERVER_HOST:/tmp/"

# 在服务器上解压
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    find . -mindepth 1 -maxdepth 1 ! -name '*.backup.*' -exec rm -rf {} + 2>/dev/null || true
    tar -xzf /tmp/emotion-diary-deploy.tar.gz
    rm -f /tmp/emotion-diary-deploy.tar.gz
"

rm -f "emotion-diary-deploy.tar.gz"
echo -e "${GREEN}✅ 文件上传完成${NC}"

# 服务器端配置
echo -e "${YELLOW}🔧 服务器端配置...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH/backend'
    
    # 创建虚拟环境
    if [ ! -d 'venv' ]; then
        echo '创建Python虚拟环境...'
        python3 -m venv venv
    fi
    
    # 安装依赖
    source venv/bin/activate
    if [ -f 'requirements.txt' ]; then
        echo '安装Python依赖...'
        pip install -r requirements.txt
    fi
    
    # 数据库迁移
    if [ -f 'manage.py' ]; then
        echo '执行数据库迁移...'
        python manage.py migrate || echo '⚠️  数据库迁移失败'
        python manage.py collectstatic --noinput || echo '⚠️  静态文件收集失败'
    fi
"

# 启动服务
echo -e "${YELLOW}🚀 启动服务...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    
    # 停止现有服务
    pkill -f 'python.*manage.py' || true
    pkill -f 'gunicorn' || true
    sleep 2
    
    # 启动新服务
    cd backend
    source venv/bin/activate
    nohup python manage.py runserver 0.0.0.0:8000 > ../logs/backend.log 2>&1 &
    
    sleep 3
    if pgrep -f 'python.*manage.py' > /dev/null; then
        echo '✅ 服务启动成功'
    else
        echo '❌ 服务启动失败'
    fi
"

# 清理
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}🎉 部署完成！${NC}"
echo ""
echo -e "${BLUE}🌐 访问地址:${NC}"
echo "  前端应用: http://$SERVER_HOST:8000/static/h5/"
echo "  后端API: http://$SERVER_HOST:8000/api/"
echo ""
echo -e "${GREEN}✨ 请在浏览器中体验完善的AI分析页面功能！${NC}" 