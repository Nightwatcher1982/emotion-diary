#!/bin/bash

# AI情绪日记 - 手动部署脚本
# 用于将代码手动部署到阿里云ECS服务器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 AI情绪日记 - 手动部署脚本${NC}"
echo "=================================="
echo ""

# 检查必要的工具
echo -e "${YELLOW}🔍 检查本地环境...${NC}"

if ! command -v ssh &> /dev/null; then
    echo -e "${RED}❌ SSH未安装${NC}"
    exit 1
fi

if ! command -v rsync &> /dev/null; then
    echo -e "${YELLOW}⚠️  rsync未安装，将使用scp传输文件${NC}"
    USE_RSYNC=false
else
    echo -e "${GREEN}✅ rsync可用${NC}"
    USE_RSYNC=true
fi

echo -e "${GREEN}✅ 本地环境检查完成${NC}"
echo ""

# 配置参数
echo -e "${BLUE}📋 配置部署参数...${NC}"

# 从用户输入或环境变量获取配置
if [ -z "$SERVER_HOST" ]; then
    read -p "请输入ECS服务器IP地址: " SERVER_HOST
fi

if [ -z "$SERVER_USER" ]; then
    read -p "请输入ECS用户名 (默认: root): " SERVER_USER
    SERVER_USER=${SERVER_USER:-root}
fi

if [ -z "$SSH_KEY_PATH" ]; then
    SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
    if [ ! -f "$SSH_KEY_PATH" ]; then
        echo -e "${YELLOW}⚠️  SSH密钥未找到: $SSH_KEY_PATH${NC}"
        read -p "请输入SSH私钥路径 (默认: ~/.ssh/id_rsa): " SSH_KEY_PATH
        SSH_KEY_PATH=${SSH_KEY_PATH:-$HOME/.ssh/id_rsa}
    fi
fi

PROJECT_DIR="emotion-diary"
REMOTE_PATH="/home/$SERVER_USER/$PROJECT_DIR"

echo -e "${GREEN}配置完成:${NC}"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo "  SSH密钥: $SSH_KEY_PATH"
echo "  远程路径: $REMOTE_PATH"
echo ""

# 测试SSH连接
echo -e "${YELLOW}🧪 测试SSH连接...${NC}"
if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "echo '✅ SSH连接成功'" 2>/dev/null; then
    echo -e "${GREEN}✅ SSH连接正常${NC}"
else
    echo -e "${RED}❌ SSH连接失败${NC}"
    echo "请检查:"
    echo "  1. 服务器IP地址是否正确"
    echo "  2. SSH密钥是否正确"
    echo "  3. 服务器SSH服务是否启动"
    echo "  4. 防火墙是否开放22端口"
    exit 1
fi
echo ""

# 检查服务器环境
echo -e "${YELLOW}🔍 检查服务器环境...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    echo '服务器信息:'
    uname -a
    echo ''
    echo '当前用户:' \$(whoami)
    echo '家目录:' \$HOME
    echo ''
    
    # 检查必要工具
    if command -v git &> /dev/null; then
        echo '✅ Git已安装:' \$(git --version)
    else
        echo '❌ Git未安装，正在安装...'
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        else
            echo '❌ 无法自动安装Git，请手动安装'
            exit 1
        fi
    fi
    
    if command -v python3 &> /dev/null; then
        echo '✅ Python3已安装:' \$(python3 --version)
    else
        echo '❌ Python3未安装'
    fi
    
    if command -v node &> /dev/null; then
        echo '✅ Node.js已安装:' \$(node --version)
    else
        echo '⚠️  Node.js未安装 (前端构建需要)'
    fi
"
echo ""

# 准备本地代码
echo -e "${YELLOW}📦 准备本地代码...${NC}"

# 确保在项目根目录
cd "$(dirname "$0")/.."

# 检查Git状态
if [ -d ".git" ]; then
    echo "Git状态:"
    git status --porcelain || echo "无未提交更改"
    echo "当前分支: $(git branch --show-current)"
    echo "最新提交: $(git log --oneline -1)"
else
    echo -e "${YELLOW}⚠️  不是Git仓库${NC}"
fi

# 创建临时打包目录
TEMP_DIR="/tmp/emotion-diary-deploy-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEMP_DIR"

echo "创建部署包..."
# 排除不需要的文件
rsync -av --exclude='.git' \
          --exclude='node_modules' \
          --exclude='frontend/dist' \
          --exclude='backend/__pycache__' \
          --exclude='backend/*/migrations/__pycache__' \
          --exclude='backend/logs' \
          --exclude='*.pyc' \
          --exclude='*.log' \
          --exclude='.DS_Store' \
          --exclude='._*' \
          . "$TEMP_DIR/"

echo -e "${GREEN}✅ 部署包准备完成: $TEMP_DIR${NC}"
echo ""

# 上传代码到服务器
echo -e "${YELLOW}📤 上传代码到服务器...${NC}"

# 在服务器上创建项目目录
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    if [ ! -d '$REMOTE_PATH' ]; then
        echo '📁 创建项目目录: $REMOTE_PATH'
        mkdir -p '$REMOTE_PATH'
    fi
"

# 上传文件
if [ "$USE_RSYNC" = true ]; then
    echo "使用rsync上传文件..."
    rsync -avz --delete -e "ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no" \
          "$TEMP_DIR/" "$SERVER_USER@$SERVER_HOST:$REMOTE_PATH/"
else
    echo "使用scp上传文件..."
    scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -r "$TEMP_DIR/"* "$SERVER_USER@$SERVER_HOST:$REMOTE_PATH/"
fi

echo -e "${GREEN}✅ 文件上传完成${NC}"
echo ""

# 服务器端部署
echo -e "${YELLOW}🔧 在服务器上执行部署...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    
    echo '📂 当前目录内容:'
    ls -la | head -10
    echo ''
    
    # 后端部署
    if [ -d 'backend' ]; then
        echo '🐍 设置Python后端环境...'
        cd backend
        
        # 创建虚拟环境
        if [ ! -d 'venv' ]; then
            echo '创建Python虚拟环境...'
            python3 -m venv venv
        fi
        
        # 激活虚拟环境
        source venv/bin/activate
        
        # 安装依赖
        if [ -f 'requirements.txt' ]; then
            echo '安装Python依赖...'
            pip install -r requirements.txt
        fi
        
        # 数据库迁移
        if [ -f 'manage.py' ]; then
            echo '执行数据库迁移...'
            python manage.py migrate --settings=emotion_diary_api.settings_production || echo '迁移失败，可能需要配置数据库'
        fi
        
        cd ..
    fi
    
    # 前端构建 (如果有Node.js)
    if [ -d 'frontend' ] && command -v npm &> /dev/null; then
        echo '📱 构建前端...'
        cd frontend
        
        if [ -f 'package.json' ]; then
            echo '安装前端依赖...'
            npm install
            
            echo '构建微信小程序...'
            npm run build:mp-weixin || echo '前端构建失败'
        fi
        
        cd ..
    fi
    
    echo ''
    echo '✅ 服务器端部署完成！'
    echo ''
    echo '📊 部署结果:'
    echo '项目目录:' '$REMOTE_PATH'
    echo '文件数量:' \$(find . -type f | wc -l)
    echo '目录大小:' \$(du -sh . | cut -f1)
"

# 清理临时文件
echo -e "${YELLOW}🧹 清理临时文件...${NC}"
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}🎉 手动部署完成！${NC}"
echo ""
echo -e "${BLUE}📋 部署信息:${NC}"
echo "  服务器: $SERVER_HOST"
echo "  项目路径: $REMOTE_PATH"
echo "  部署时间: $(date)"
echo ""
echo -e "${BLUE}🔧 下一步操作:${NC}"
echo "1. SSH登录服务器检查部署结果:"
echo "   ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST"
echo ""
echo "2. 进入项目目录:"
echo "   cd $REMOTE_PATH"
echo ""
echo "3. 启动后端服务 (可选):"
echo "   cd backend && source venv/bin/activate && python manage.py runserver 0.0.0.0:8000"
echo ""
echo "4. 配置Web服务器 (Nginx等) 进行生产部署"
echo ""
echo -e "${GREEN}部署脚本执行完成！${NC}" 