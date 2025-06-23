#!/bin/bash

# AI情绪日记 - 快速部署脚本
# 用于快速更新代码到服务器 (假设服务器环境已配置)

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⚡ 快速部署 - AI情绪日记${NC}"
echo "========================="
echo ""

# 配置 (可以通过环境变量设置)
SERVER_HOST=${SERVER_HOST:-""}
SERVER_USER=${SERVER_USER:-"root"}
SSH_KEY_PATH=${SSH_KEY_PATH:-"$HOME/.ssh/emotion-diary-deploy"}
PROJECT_DIR="emotion-diary"

# 如果没有配置，询问用户
if [ -z "$SERVER_HOST" ]; then
    read -p "请输入ECS服务器IP: " SERVER_HOST
fi

echo -e "${YELLOW}📤 同步代码到服务器...${NC}"
echo "目标: $SERVER_USER@$SERVER_HOST"
echo ""

# 确保在项目根目录
cd "$(dirname "$0")/.."

# 同步代码 (排除不需要的文件)
rsync -avz --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='frontend/dist' \
    --exclude='backend/__pycache__' \
    --exclude='backend/*/migrations/__pycache__' \
    --exclude='backend/logs' \
    --exclude='*.pyc' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    --exclude='._*' \
    --exclude='backend/venv' \
    -e "ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no" \
    . "$SERVER_USER@$SERVER_HOST:/home/$SERVER_USER/$PROJECT_DIR/"

echo -e "${GREEN}✅ 代码同步完成${NC}"

# 在服务器上重启服务 (如果需要)
echo -e "${YELLOW}🔄 重启服务...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd /home/$SERVER_USER/$PROJECT_DIR
    
    # 如果有Python服务在运行，重启它
    if pgrep -f 'python.*manage.py' > /dev/null; then
        echo '停止Python服务...'
        pkill -f 'python.*manage.py' || true
        sleep 2
    fi
    
    # 如果有虚拟环境，激活并重启服务
    if [ -d 'backend/venv' ]; then
        echo '重启后端服务...'
        cd backend
        source venv/bin/activate
        nohup python manage.py runserver 0.0.0.0:8000 > ../logs/backend.log 2>&1 &
        echo '后端服务已启动'
    fi
"

echo ""
echo -e "${GREEN}🎉 快速部署完成！${NC}"
echo ""
echo "服务状态检查:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'ps aux | grep python'"
echo "" 