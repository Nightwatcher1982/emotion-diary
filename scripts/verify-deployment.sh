#!/bin/bash

# AI情绪日记 - 部署验证脚本
# 验证部署是否成功

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 AI情绪日记 - 部署验证${NC}"
echo "=========================="
echo ""

# 配置参数 - 从环境变量或参数获取
if [ -z "$1" ]; then
    if [ -z "$SERVER_HOST" ]; then
        echo -e "${RED}❌ 错误: 请设置环境变量 SERVER_HOST 或传入参数${NC}"
        echo "用法: $0 [服务器IP] [用户名] [SSH密钥路径]"
        echo "或设置环境变量: export SERVER_HOST=your_server_ip"
        exit 1
    fi
else
    SERVER_HOST=$1
fi

if [ -z "$2" ]; then
    if [ -z "$SERVER_USER" ]; then
        SERVER_USER="root"
    fi
else
    SERVER_USER=$2
fi

if [ -z "$3" ]; then
    if [ -z "$SSH_KEY_PATH" ]; then
        SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
        if [ ! -f "$SSH_KEY_PATH" ]; then
            SSH_KEY_PATH="$HOME/.ssh/id_rsa"
        fi
    fi
else
    SSH_KEY_PATH=$3
fi

PROJECT_DIR="emotion-diary"
REMOTE_PATH="/home/$SERVER_USER/$PROJECT_DIR"

echo -e "${YELLOW}📋 验证配置:${NC}"
echo "  服务器: $SERVER_HOST"
echo "  用户: $SERVER_USER"
echo "  项目路径: $REMOTE_PATH"
echo ""

# 1. SSH连接测试
echo -e "${YELLOW}1. 🔗 SSH连接测试...${NC}"
if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "echo 'SSH连接成功'" 2>/dev/null; then
    echo -e "${GREEN}✅ SSH连接正常${NC}"
else
    echo -e "${RED}❌ SSH连接失败${NC}"
    exit 1
fi

# 2. 项目文件检查
echo -e "${YELLOW}2. 📁 项目文件检查...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    if [ -d '$REMOTE_PATH' ]; then
        echo '✅ 项目目录存在'
        cd '$REMOTE_PATH'
        
        if [ -d 'backend' ]; then
            echo '✅ 后端目录存在'
        else
            echo '❌ 后端目录缺失'
            exit 1
        fi
        
        if [ -d 'frontend' ]; then
            echo '✅ 前端目录存在'
        else
            echo '❌ 前端目录缺失'
            exit 1
        fi
        
        if [ -f 'backend/manage.py' ]; then
            echo '✅ Django管理文件存在'
        else
            echo '❌ Django管理文件缺失'
            exit 1
        fi
        
    else
        echo '❌ 项目目录不存在'
        exit 1
    fi
"

# 3. Python环境检查
echo -e "${YELLOW}3. 🐍 Python环境检查...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH/backend'
    
    if [ -d 'venv' ]; then
        echo '✅ Python虚拟环境存在'
        source venv/bin/activate
        
        if python --version > /dev/null 2>&1; then
            echo '✅ Python可执行:' \$(python --version)
        else
            echo '❌ Python无法执行'
            exit 1
        fi
        
        if pip list | grep -q Django; then
            echo '✅ Django已安装:' \$(pip show Django | grep Version)
        else
            echo '❌ Django未安装'
            exit 1
        fi
        
    else
        echo '❌ Python虚拟环境不存在'
        exit 1
    fi
"

# 4. 服务状态检查
echo -e "${YELLOW}4. 🔄 服务状态检查...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    if pgrep -f 'python.*manage.py\|gunicorn' > /dev/null; then
        echo '✅ 后端服务运行中'
        echo '进程ID:' \$(pgrep -f 'python.*manage.py\|gunicorn')
    else
        echo '⚠️  后端服务未运行'
    fi
"

# 5. 端口检查
echo -e "${YELLOW}5. 🌐 端口检查...${NC}"
if nc -z "$SERVER_HOST" 8000 2>/dev/null; then
    echo -e "${GREEN}✅ 端口8000可访问${NC}"
else
    echo -e "${YELLOW}⚠️  端口8000不可访问${NC}"
fi

# 6. HTTP响应测试
echo -e "${YELLOW}6. 📡 HTTP响应测试...${NC}"
if curl -s --connect-timeout 10 "http://$SERVER_HOST:8000" > /dev/null; then
    echo -e "${GREEN}✅ HTTP服务响应正常${NC}"
else
    echo -e "${YELLOW}⚠️  HTTP服务无响应${NC}"
fi

# 7. API端点测试
echo -e "${YELLOW}7. 🔌 API端点测试...${NC}"
API_RESPONSE=$(curl -s --connect-timeout 10 "http://$SERVER_HOST:8000/api/emotions/" 2>/dev/null || echo "")
if [ ! -z "$API_RESPONSE" ]; then
    echo -e "${GREEN}✅ API端点响应正常${NC}"
else
    echo -e "${YELLOW}⚠️  API端点无响应${NC}"
fi

# 8. 前端文件检查
echo -e "${YELLOW}8. 📱 前端文件检查...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    
    if [ -d 'frontend/dist/build/h5' ]; then
        echo '✅ 前端构建文件存在'
        file_count=\$(find frontend/dist/build/h5 -type f | wc -l)
        echo '文件数量:' \$file_count
        
        if [ -f 'frontend/dist/build/h5/index.html' ]; then
            echo '✅ 前端入口文件存在'
        else
            echo '❌ 前端入口文件缺失'
        fi
    else
        echo '❌ 前端构建文件缺失'
    fi
"

# 9. 日志检查
echo -e "${YELLOW}9. 📝 日志检查...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH'
    
    if [ -f 'logs/backend.log' ]; then
        echo '✅ 后端日志文件存在'
        log_size=\$(du -h logs/backend.log | cut -f1)
        echo '日志大小:' \$log_size
        
        # 检查最近的错误
        error_count=\$(tail -n 100 logs/backend.log | grep -i error | wc -l)
        if [ \$error_count -gt 0 ]; then
            echo '⚠️  发现' \$error_count '个错误日志'
            echo '最近的错误:'
            tail -n 100 logs/backend.log | grep -i error | tail -n 3
        else
            echo '✅ 无错误日志'
        fi
    else
        echo '⚠️  后端日志文件不存在'
    fi
"

# 10. 数据库检查
echo -e "${YELLOW}10. 🗄️  数据库检查...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$REMOTE_PATH/backend'
    source venv/bin/activate
    
    if python manage.py check > /dev/null 2>&1; then
        echo '✅ Django配置检查通过'
    else
        echo '❌ Django配置检查失败'
    fi
    
    if [ -f 'db.sqlite3' ]; then
        echo '✅ SQLite数据库文件存在'
        db_size=\$(du -h db.sqlite3 | cut -f1)
        echo '数据库大小:' \$db_size
    else
        echo '⚠️  数据库文件不存在'
    fi
"

# 总结
echo ""
echo -e "${BLUE}📊 验证总结${NC}"
echo "===================="

# 访问地址
echo -e "${YELLOW}🌐 访问地址:${NC}"
echo "  后端API: http://$SERVER_HOST:8000"
echo "  前端应用: http://$SERVER_HOST:8000/static/h5/"
echo "  API文档: http://$SERVER_HOST:8000/api/docs/"

# 功能测试建议
echo ""
echo -e "${YELLOW}🧪 功能测试建议:${NC}"
echo "1. 访问前端应用，检查页面加载"
echo "2. 进入AI分析页面，测试新功能:"
echo "   - 点击'查看详情'展开核心洞察"
echo "   - 点击'展开详情'查看情绪光谱"
echo "   - 点击情绪项查看详细信息"
echo "   - 体验雷达图可视化"
echo "   - 测试AI建议功能"

# 管理命令
echo ""
echo -e "${YELLOW}🔧 管理命令:${NC}"
echo "重启服务:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'cd $REMOTE_PATH && pkill -f python && cd backend && source venv/bin/activate && nohup python manage.py runserver 0.0.0.0:8000 > ../logs/backend.log 2>&1 &'"
echo ""
echo "查看日志:"
echo "  ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'tail -f $REMOTE_PATH/logs/backend.log'"

echo ""
echo -e "${GREEN}✅ 验证完成！${NC}" 