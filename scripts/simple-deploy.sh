#!/bin/bash

# AI情绪日记 - 简化部署脚本
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
SERVER_HOST="47.239.83.46"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
PROJECT_DIR="/var/www/emotion-diary"

echo -e "${BLUE}🚀 AI情绪日记 - 简化部署脚本${NC}"
echo "=================================="
echo "服务器: $SERVER_HOST"
echo "用户: $SERVER_USER"
echo "项目目录: $PROJECT_DIR"
echo ""

# 检查SSH连接
echo -e "${YELLOW}📡 检查SSH连接...${NC}"
if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "echo 'SSH连接成功'" 2>/dev/null; then
    echo -e "${GREEN}✅ SSH连接正常${NC}"
else
    echo -e "${RED}❌ SSH连接失败${NC}"
    exit 1
fi

# 在服务器上直接运行阿里云部署脚本
echo -e "${YELLOW}🔧 在服务器上运行部署脚本...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    # 下载部署脚本
    cd /tmp
    curl -o deploy.sh https://raw.githubusercontent.com/Nightwatcher1982/emotion-diary/main/backend/deploy/deploy.sh
    
    # 给脚本执行权限
    chmod +x deploy.sh
    
    # 运行部署脚本
    ./deploy.sh
"

echo -e "${GREEN}✅ 部署完成！${NC}"
echo ""
echo -e "${BLUE}📋 验证部署状态:${NC}"
echo "  运行: ./scripts/check-deployment.sh"
echo ""
echo -e "${BLUE}📱 访问地址:${NC}"
echo "  API文档: http://$SERVER_HOST/api/docs/"
echo "  健康检查: http://$SERVER_HOST/health/"
echo "  管理后台: http://$SERVER_HOST/admin/" 