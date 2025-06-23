#!/bin/bash

# AI情绪日记 - 当前版本部署脚本
# 部署完善的AI分析页面版本到服务器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🚀 AI情绪日记 - 完善版本部署${NC}"
echo "=================================="
echo -e "${PURPLE}✨ 本次部署包含AI分析页面详情展开功能完善${NC}"
echo ""

# 显示版本信息
echo -e "${YELLOW}📋 版本信息:${NC}"
if [ -d ".git" ]; then
    echo "  当前分支: $(git branch --show-current)"
    echo "  最新提交: $(git log --oneline -1)"
    echo "  提交时间: $(git log -1 --format=%cd)"
else
    echo "  版本: 本地开发版本"
fi
echo ""

# 显示主要更新内容
echo -e "${YELLOW}🎯 主要更新内容:${NC}"
echo "  ✨ 核心洞察详情展开功能"
echo "  ✨ 情绪光谱详情展开和交互"
echo "  ✨ 情绪分布雷达图可视化"
echo "  ✨ AI个性化建议系统"
echo "  ✨ 流畅的动画和交互效果"
echo "  ✨ 统一的毛玻璃设计风格"
echo ""

# 配置参数
echo -e "${BLUE}🔧 配置部署参数...${NC}"

# 直接配置服务器信息（请修改为您的服务器IP）
if [ -z "$SERVER_HOST" ]; then
    SERVER_HOST="YOUR_SERVER_IP_HERE"  # 请修改为您的实际服务器IP
    echo -e "${YELLOW}使用配置的服务器: $SERVER_HOST${NC}"
    echo -e "${YELLOW}💡 提示: 如需修改服务器IP，请编辑脚本中的 SERVER_HOST 变量${NC}"
fi

if [ -z "$SERVER_USER" ]; then
    SERVER_USER="root"
    echo -e "${YELLOW}使用默认用户: $SERVER_USER${NC}"
fi

if [ -z "$SSH_KEY_PATH" ]; then
    SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
    if [ ! -f "$SSH_KEY_PATH" ]; then
        SSH_KEY_PATH="$HOME/.ssh/id_rsa"
        if [ ! -f "$SSH_KEY_PATH" ]; then
            echo -e "${RED}❌ 错误: SSH私钥未找到${NC}"
            echo "请检查以下路径:"
            echo "  - $HOME/.ssh/emotion-diary-deploy"
            echo "  - $HOME/.ssh/id_rsa"
            echo "或设置环境变量: export SSH_KEY_PATH=/path/to/your/key"
            exit 1
        fi
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
    echo "  1. 服务器IP地址是否正确: $SERVER_HOST"
    echo "  2. SSH密钥是否正确: $SSH_KEY_PATH"
    echo "  3. 服务器SSH服务是否启动"
    echo "  4. 防火墙是否开放22端口"
    exit 1
fi
echo ""

# 检查本地构建
echo -e "${YELLOW}🏗️  检查本地构建...${NC}"
cd "$(dirname "$0")/.."

# 检查前端构建
if [ -d "frontend" ]; then
    cd frontend
    if [ -f "package.json" ]; then
        echo "检查前端依赖..."
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

echo "打包项目文件..."
# 使用tar打包，排除不需要的文件
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

# 复制构建后的前端文件
if [ -d "frontend/dist/build/h5" ]; then
    echo "复制前端构建文件..."
    mkdir -p "$TEMP_DIR/frontend/dist/build"
    cp -r frontend/dist/build/h5 "$TEMP_DIR/frontend/dist/build/"
fi

echo -e "${GREEN}✅ 部署包准备完成${NC}"
echo ""

# 上传到服务器
echo -e "${YELLOW}📤 上传到服务器...${NC}"

# 在服务器上创建项目目录
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    if [ ! -d '$REMOTE_PATH' ]; then
        echo '📁 创建项目目录: $REMOTE_PATH'
        mkdir -p '$REMOTE_PATH'
    fi
    
    # 备份现有版本
    if [ -d '$REMOTE_PATH/backend' ]; then
        echo '💾 备份现有版本...'
        cp -r '$REMOTE_PATH' '$REMOTE_PATH.backup.$(date +%Y%m%d_%H%M%S)' || true
    fi
"

# 上传文件
echo "使用scp上传文件..."
# 创建tar包进行上传
cd "$TEMP_DIR"
tar -czf "../emotion-diary-deploy.tar.gz" .
cd ..
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
    "emotion-diary-deploy.tar.gz" "$SERVER_USER@$SERVER_HOST:/tmp/"

# 在服务器上解压
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    # 清空目录（保留备份）
    find . -mindepth 1 -maxdepth 1 ! -name '*.backup.*' -exec rm -rf {} + 2>/dev/null || true
    # 解压新文件
    tar -xzf /tmp/emotion-diary-deploy.tar.gz
    rm -f /tmp/emotion-diary-deploy.tar.gz
"

# 清理本地tar包
rm -f "emotion-diary-deploy.tar.gz"

echo -e "${GREEN}✅ 文件上传完成${NC}"
echo ""

# 服务器端部署
echo -e "${YELLOW}🔧 服务器端部署...${NC}"
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
        
        # 激活虚拟环境并安装依赖
        source venv/bin/activate
        
        if [ -f 'requirements.txt' ]; then
            echo '安装Python依赖...'
            pip install -r requirements.txt
        fi
        
        # 数据库迁移
        if [ -f 'manage.py' ]; then
            echo '执行数据库迁移...'
            python manage.py migrate || echo '⚠️  数据库迁移失败，请检查配置'
            
            echo '收集静态文件...'
            python manage.py collectstatic --noinput || echo '⚠️  静态文件收集失败'
        fi
        
        cd ..
        echo '✅ 后端部署完成'
    fi
    
    # 前端部署
    if [ -d 'frontend/dist/build/h5' ]; then
        echo '📱 前端文件已就绪'
        echo '前端文件数量:' \$(find frontend/dist/build/h5 -type f | wc -l)
    fi
    
    echo ''
    echo '✅ 服务器端部署完成！'
"

# 启动服务
echo -e "${YELLOW}🚀 启动服务...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    
    # 停止现有服务
    echo '停止现有服务...'
    pkill -f 'python.*manage.py' || true
    pkill -f 'gunicorn' || true
    sleep 2
    
    # 启动后端服务
    if [ -d 'backend' ]; then
        echo '启动后端服务...'
        cd backend
        source venv/bin/activate
        
        # 检查是否有gunicorn配置
        if [ -f '../deploy/gunicorn_config.py' ]; then
            echo '使用Gunicorn启动生产服务...'
            nohup gunicorn emotion_diary_api.wsgi:application -c ../deploy/gunicorn_config.py > ../logs/backend.log 2>&1 &
        else
            echo '使用Django开发服务器启动...'
            nohup python manage.py runserver 0.0.0.0:8000 > ../logs/backend.log 2>&1 &
        fi
        
        sleep 3
        
        # 检查服务状态
        if pgrep -f 'python.*manage.py\|gunicorn' > /dev/null; then
            echo '✅ 后端服务启动成功'
        else
            echo '❌ 后端服务启动失败'
            echo '错误日志:'
            tail -n 10 ../logs/backend.log || echo '无法读取日志'
        fi
        
        cd ..
    fi
"

# 清理临时文件
echo -e "${YELLOW}🧹 清理临时文件...${NC}"
rm -rf "$TEMP_DIR"

# 验证部署
echo -e "${YELLOW}🔍 验证部署...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    
    echo '📊 部署结果:'
    echo '项目目录:' '$REMOTE_PATH'
    echo '文件数量:' \$(find . -type f | wc -l)
    echo '目录大小:' \$(du -sh . | cut -f1)
    echo ''
    
    echo '🔄 服务状态:'
    if pgrep -f 'python.*manage.py\|gunicorn' > /dev/null; then
        echo '✅ 后端服务运行中 (PID:' \$(pgrep -f 'python.*manage.py\|gunicorn') ')'
    else
        echo '❌ 后端服务未运行'
    fi
    
    echo ''
    echo '📱 前端文件:'
    if [ -d 'frontend/dist/build/h5' ]; then
        echo '✅ 前端构建文件存在'
        echo '入口文件:' \$(ls frontend/dist/build/h5/index.html 2>/dev/null && echo '存在' || echo '缺失')
    else
        echo '❌ 前端构建文件缺失'
    fi
"

echo ""
echo -e "${GREEN}🎉 部署完成！${NC}"
echo ""
echo -e "${BLUE}📋 部署信息:${NC}"
echo "  服务器: $SERVER_HOST"
echo "  项目路径: $REMOTE_PATH"
echo "  部署时间: $(date)"
echo ""
echo -e "${BLUE}🌐 访问地址:${NC}"
echo "  后端API: http://$SERVER_HOST:8000"
echo "  前端应用: http://$SERVER_HOST:8000/static/h5/"
echo ""
echo -e "${BLUE}🔧 管理命令:${NC}"
echo "1. SSH登录服务器:"
echo "   ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST"
echo ""
echo "2. 查看服务状态:"
echo "   ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'cd $REMOTE_PATH && ps aux | grep python'"
echo ""
echo "3. 查看服务日志:"
echo "   ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'cd $REMOTE_PATH && tail -f logs/backend.log'"
echo ""
echo "4. 重启服务:"
echo "   ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'cd $REMOTE_PATH && pkill -f python && cd backend && source venv/bin/activate && nohup python manage.py runserver 0.0.0.0:8000 > ../logs/backend.log 2>&1 &'"
echo ""
echo -e "${GREEN}✨ 新功能已部署！请在浏览器中体验完善的AI分析页面${NC}" 