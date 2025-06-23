#!/bin/bash

# AI情绪日记 - 部署状态检查脚本
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
SERVER_USER="root"
PROJECT_DIR="/var/www/emotion-diary"

# 从环境变量或参数获取服务器地址
SERVER_HOST="${1:-$SERVER_HOST}"

if [ -z "$SERVER_HOST" ]; then
    echo -e "${RED}❌ 请提供服务器地址${NC}"
    echo "用法: $0 <服务器IP地址>"
    echo "或设置环境变量: export SERVER_HOST=your-server-ip"
    exit 1
fi

echo -e "${CYAN}🔍 AI情绪日记 - 部署状态检查${NC}"
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
    echo "请检查:"
    echo "  1. 服务器IP地址: $SERVER_HOST"
    echo "  2. SSH密钥路径: $SSH_KEY_PATH"
    echo "  3. 服务器SSH服务状态"
    echo "  4. 防火墙设置"
    exit 1
fi
echo ""

# 检查服务器基本信息
echo -e "${YELLOW}🖥️  服务器基本信息...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    echo '操作系统:' \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2)
    echo '内核版本:' \$(uname -r)
    echo '系统负载:' \$(uptime | awk -F'load average:' '{print \$2}')
    echo '内存使用:' \$(free -h | grep Mem | awk '{print \$3\"/\"\$2}')
    echo '磁盘使用:' \$(df -h / | tail -1 | awk '{print \$3\"/\"\$2\" (\"\$5\")\"}')
"
echo ""

# 检查项目目录
echo -e "${YELLOW}📁 检查项目目录...${NC}"
PROJECT_STATUS=$(ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    if [ -d '$PROJECT_DIR' ]; then
        echo 'exists'
        cd '$PROJECT_DIR'
        if [ -d '.git' ]; then
            echo 'git_repo'
            echo 'branch:' \$(git branch --show-current 2>/dev/null || echo 'unknown')
            echo 'commit:' \$(git log --oneline -1 2>/dev/null || echo 'unknown')
        fi
        echo 'files:'
        ls -la | head -10
    else
        echo 'not_exists'
    fi
" 2>/dev/null)

if echo "$PROJECT_STATUS" | grep -q "exists"; then
    echo -e "${GREEN}✅ 项目目录存在${NC}: $PROJECT_DIR"
    if echo "$PROJECT_STATUS" | grep -q "git_repo"; then
        echo -e "${GREEN}✅ Git仓库已初始化${NC}"
        echo "$PROJECT_STATUS" | grep -E "(branch:|commit:)"
    else
        echo -e "${YELLOW}⚠️  不是Git仓库${NC}"
    fi
else
    echo -e "${RED}❌ 项目目录不存在${NC}: $PROJECT_DIR"
    echo "请先运行部署脚本"
    exit 1
fi
echo ""

# 检查Python环境
echo -e "${YELLOW}🐍 检查Python环境...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    cd '$PROJECT_DIR'
    
    if command -v python3 &> /dev/null; then
        echo '✅ Python3:' \$(python3 --version)
    else
        echo '❌ Python3未安装'
    fi
    
    if [ -f 'backend/manage.py' ]; then
        echo '✅ Django项目文件存在'
    else
        echo '❌ Django项目文件不存在'
    fi
    
    if [ -d 'backend/venv' ] || [ -d 'backend/emotion_diary_env' ]; then
        echo '✅ Python虚拟环境存在'
        
        # 尝试激活虚拟环境并检查Django
        if [ -d 'backend/venv' ]; then
            source backend/venv/bin/activate
        elif [ -d 'backend/emotion_diary_env' ]; then
            source backend/emotion_diary_env/bin/activate
        fi
        
        cd backend
        if python -c 'import django; print(\"Django版本:\", django.VERSION)' 2>/dev/null; then
            echo '✅ Django已安装'
            
            # 检查Django配置
            if python manage.py check --deploy 2>/dev/null; then
                echo '✅ Django配置检查通过'
            else
                echo '⚠️  Django配置可能有问题'
            fi
        else
            echo '❌ Django未安装或配置错误'
        fi
    else
        echo '❌ Python虚拟环境不存在'
    fi
"
echo ""

# 检查服务状态
echo -e "${YELLOW}⚙️  检查系统服务...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    # 检查常见服务
    services=('nginx' 'mysql' 'redis-server' 'emotion-diary')
    
    for service in \${services[@]}; do
        if systemctl is-active --quiet \$service 2>/dev/null; then
            echo \"✅ \$service: 运行中\"
        elif systemctl list-unit-files | grep -q \$service 2>/dev/null; then
            echo \"❌ \$service: 已安装但未运行\"
        else
            echo \"⚠️  \$service: 未安装\"
        fi
    done
"
echo ""

# 检查端口监听
echo -e "${YELLOW}🔌 检查端口监听...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    ports=('22:SSH' '80:HTTP' '443:HTTPS' '8000:Django' '3306:MySQL' '6379:Redis')
    
    for port_info in \${ports[@]}; do
        port=\${port_info%%:*}
        name=\${port_info##*:}
        
        if netstat -tlnp 2>/dev/null | grep -q \":\$port \"; then
            pid=\$(netstat -tlnp 2>/dev/null | grep \":\$port \" | awk '{print \$7}' | cut -d'/' -f1 | head -1)
            echo \"✅ \$name (端口\$port): 监听中 [PID: \$pid]\"
        else
            echo \"❌ \$name (端口\$port): 未监听\"
        fi
    done
"
echo ""

# 检查防火墙状态
echo -e "${YELLOW}🔥 检查防火墙状态...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    if command -v ufw &> /dev/null; then
        echo 'UFW防火墙状态:'
        ufw status 2>/dev/null || echo '未配置'
    elif command -v firewall-cmd &> /dev/null; then
        echo 'Firewalld防火墙状态:'
        firewall-cmd --state 2>/dev/null || echo '未运行'
        firewall-cmd --list-all 2>/dev/null || echo '无法获取规则'
    else
        echo '⚠️  未检测到防火墙管理工具'
    fi
"
echo ""

# API健康检查
echo -e "${YELLOW}🏥 API健康检查...${NC}"

# 检查本地API（如果Django直接运行在8000端口）
API_CHECKS=(
    "http://$SERVER_HOST:8000/health/:直接Django"
    "http://$SERVER_HOST/health/:通过Nginx"
    "http://$SERVER_HOST/api/docs/:API文档"
    "https://$SERVER_HOST/health/:HTTPS健康检查"
    "https://$SERVER_HOST/api/docs/:HTTPS API文档"
)

for check in "${API_CHECKS[@]}"; do
    url=${check%%:*}
    name=${check##*:}
    
    echo -n "检查 $name ($url)... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url" 2>/dev/null || echo "000")
    
    case $response in
        200)
            echo -e "${GREEN}✅ 正常${NC} (HTTP $response)"
            ;;
        000)
            echo -e "${RED}❌ 连接失败${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠️  异常${NC} (HTTP $response)"
            ;;
    esac
done
echo ""

# 检查日志文件
echo -e "${YELLOW}📋 检查日志文件...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    log_paths=(
        '/var/log/emotion-diary/gunicorn-error.log'
        '/var/log/emotion-diary/gunicorn-access.log'
        '/var/log/nginx/emotion-diary-error.log'
        '/var/log/nginx/emotion-diary-access.log'
        '$PROJECT_DIR/logs/django.log'
    )
    
    for log_path in \${log_paths[@]}; do
        if [ -f \"\$log_path\" ]; then
            size=\$(du -h \"\$log_path\" | cut -f1)
            echo \"✅ \$log_path (大小: \$size)\"
            
            # 显示最近的错误
            if echo \"\$log_path\" | grep -q error; then
                error_count=\$(tail -100 \"\$log_path\" 2>/dev/null | grep -i error | wc -l)
                if [ \$error_count -gt 0 ]; then
                    echo \"   ⚠️  最近100行中有 \$error_count 个错误\"
                fi
            fi
        else
            echo \"❌ \$log_path: 不存在\"
        fi
    done
"
echo ""

# 性能检查
echo -e "${YELLOW}⚡ 性能检查...${NC}"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "
    echo '系统负载:'
    uptime
    echo ''
    echo '内存使用:'
    free -h
    echo ''
    echo '磁盘使用:'
    df -h
    echo ''
    echo '网络连接:'
    netstat -an | grep ESTABLISHED | wc -l | xargs echo '活跃连接数:'
"
echo ""

# 总结报告
echo -e "${CYAN}📊 部署状态总结${NC}"
echo "=================================="

# 基于检查结果给出总体评估
OVERALL_STATUS="unknown"

# 简单的状态评估逻辑
if ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "[ -d '$PROJECT_DIR' ] && [ -f '$PROJECT_DIR/backend/manage.py' ]" 2>/dev/null; then
    if curl -s --connect-timeout 5 "http://$SERVER_HOST:8000/health/" >/dev/null 2>&1 || curl -s --connect-timeout 5 "http://$SERVER_HOST/health/" >/dev/null 2>&1; then
        OVERALL_STATUS="healthy"
    else
        OVERALL_STATUS="deployed_not_running"
    fi
else
    OVERALL_STATUS="not_deployed"
fi

case $OVERALL_STATUS in
    "healthy")
        echo -e "${GREEN}🎉 部署状态: 健康运行${NC}"
        echo "✅ 项目已成功部署并正常运行"
        echo ""
        echo -e "${BLUE}📱 访问地址:${NC}"
        echo "  API文档: http://$SERVER_HOST/api/docs/"
        echo "  健康检查: http://$SERVER_HOST/health/"
        echo "  管理后台: http://$SERVER_HOST/admin/"
        if curl -s --connect-timeout 5 "https://$SERVER_HOST/health/" >/dev/null 2>&1; then
            echo "  HTTPS访问: https://$SERVER_HOST/"
        fi
        ;;
    "deployed_not_running")
        echo -e "${YELLOW}⚠️  部署状态: 已部署但服务未运行${NC}"
        echo "项目文件已部署，但API服务无法访问"
        echo ""
        echo -e "${BLUE}🔧 建议操作:${NC}"
        echo "1. 检查Django服务状态"
        echo "2. 查看错误日志"
        echo "3. 重启相关服务"
        ;;
    "not_deployed")
        echo -e "${RED}❌ 部署状态: 未部署${NC}"
        echo "项目尚未部署到服务器"
        echo ""
        echo -e "${BLUE}🚀 下一步操作:${NC}"
        echo "1. 运行部署脚本: ./scripts/manual-deploy.sh $SERVER_HOST"
        echo "2. 或触发GitHub Actions自动部署"
        ;;
    *)
        echo -e "${YELLOW}❓ 部署状态: 无法确定${NC}"
        echo "请手动检查服务器状态"
        ;;
esac

echo ""
echo -e "${BLUE}🔧 常用运维命令:${NC}"
echo "  查看Django日志: ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'journalctl -u emotion-diary -f'"
echo "  重启Django服务: ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'systemctl restart emotion-diary'"
echo "  查看Nginx状态: ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'systemctl status nginx'"
echo "  查看系统资源: ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_HOST 'htop'"

echo ""
echo -e "${GREEN}✅ 部署检查完成！${NC}" 