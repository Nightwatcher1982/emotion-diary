#!/bin/bash

# AI情绪日记APP - 服务启动脚本
# 支持启动、重启、停止、状态检查等功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"
BACKEND_PORT=8000
FRONTEND_PORT=5173
BACKEND_PID_FILE="backend.pid"
FRONTEND_PID_FILE="frontend.pid"

# 日志文件
LOG_DIR="logs"
BACKEND_LOG="$LOG_DIR/backend.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"
SCRIPT_LOG="$LOG_DIR/services.log"

# 创建日志目录
mkdir -p $LOG_DIR

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $SCRIPT_LOG
    echo -e "$1"
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # 端口被占用
    else
        return 1  # 端口空闲
    fi
}

# 获取进程PID
get_pid_by_port() {
    local port=$1
    lsof -Pi :$port -sTCP:LISTEN -t 2>/dev/null | head -n1
}

# 检查服务状态
check_service_status() {
    local service_name=$1
    local port=$2
    local pid_file=$3
    
    if check_port $port; then
        local pid=$(get_pid_by_port $port)
        echo -e "${GREEN}✅ $service_name 正在运行${NC} (PID: $pid, Port: $port)"
        echo $pid > $pid_file
        return 0
    else
        echo -e "${RED}❌ $service_name 未运行${NC} (Port: $port)"
        [ -f $pid_file ] && rm -f $pid_file
        return 1
    fi
}

# 停止服务
stop_service() {
    local service_name=$1
    local port=$2
    local pid_file=$3
    
    log "正在停止 $service_name..."
    
    # 通过端口查找并杀死进程
    if check_port $port; then
        local pid=$(get_pid_by_port $port)
        if [ ! -z "$pid" ]; then
            log "发现 $service_name 进程 (PID: $pid)，正在终止..."
            kill -TERM $pid 2>/dev/null
            
            # 等待进程优雅退出
            local count=0
            while [ $count -lt 10 ] && kill -0 $pid 2>/dev/null; do
                sleep 1
                count=$((count + 1))
            done
            
            # 如果进程仍在运行，强制杀死
            if kill -0 $pid 2>/dev/null; then
                log "强制终止 $service_name 进程..."
                kill -KILL $pid 2>/dev/null
            fi
            
            echo -e "${GREEN}✅ $service_name 已停止${NC}"
        fi
    fi
    
    # 清理PID文件
    [ -f $pid_file ] && rm -f $pid_file
}

# 启动后端服务
start_backend() {
    log "正在启动后端服务..."
    
    # 检查后端目录
    if [ ! -d "$BACKEND_DIR" ]; then
        log "${RED}错误: 后端目录 $BACKEND_DIR 不存在${NC}"
        return 1
    fi
    
    # 检查Django项目
    if [ ! -f "$BACKEND_DIR/manage.py" ]; then
        log "${RED}错误: Django项目文件 manage.py 不存在${NC}"
        return 1
    fi
    
    # 检查虚拟环境
    if [ -d "$BACKEND_DIR/emotion_diary_env" ]; then
        log "激活虚拟环境..."
        source $BACKEND_DIR/emotion_diary_env/bin/activate
    fi
    
    # 启动Django服务
    cd $BACKEND_DIR
    nohup python manage.py runserver 127.0.0.1:$BACKEND_PORT > ../$BACKEND_LOG 2>&1 &
    local backend_pid=$!
    cd ..
    
    # 保存PID
    echo $backend_pid > $BACKEND_PID_FILE
    
    # 等待服务启动
    sleep 3
    
    # 验证启动状态
    if check_port $BACKEND_PORT; then
        echo -e "${GREEN}✅ 后端服务启动成功${NC} (PID: $backend_pid, Port: $BACKEND_PORT)"
        log "后端服务启动成功 - PID: $backend_pid"
        return 0
    else
        echo -e "${RED}❌ 后端服务启动失败${NC}"
        log "后端服务启动失败"
        return 1
    fi
}

# 启动前端服务
start_frontend() {
    log "正在启动前端服务..."
    
    # 检查前端目录
    if [ ! -d "$FRONTEND_DIR" ]; then
        log "${RED}错误: 前端目录 $FRONTEND_DIR 不存在${NC}"
        return 1
    fi
    
    # 检查package.json
    if [ ! -f "$FRONTEND_DIR/package.json" ]; then
        log "${RED}错误: 前端项目文件 package.json 不存在${NC}"
        return 1
    fi
    
    # 检查node_modules
    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        log "安装前端依赖..."
        cd $FRONTEND_DIR
        npm install
        cd ..
    fi
    
    # 启动前端服务
    cd $FRONTEND_DIR
    nohup npm run dev:h5 > ../$FRONTEND_LOG 2>&1 &
    local frontend_pid=$!
    cd ..
    
    # 保存PID
    echo $frontend_pid > $FRONTEND_PID_FILE
    
    # 等待服务启动
    sleep 5
    
    # 验证启动状态
    if check_port $FRONTEND_PORT; then
        echo -e "${GREEN}✅ 前端服务启动成功${NC} (PID: $frontend_pid, Port: $FRONTEND_PORT)"
        log "前端服务启动成功 - PID: $frontend_pid"
        return 0
    else
        echo -e "${RED}❌ 前端服务启动失败${NC}"
        log "前端服务启动失败"
        return 1
    fi
}

# 显示服务状态
show_status() {
    echo -e "${CYAN}📊 AI情绪日记APP - 服务状态${NC}"
    echo "================================"
    check_service_status "后端服务" $BACKEND_PORT $BACKEND_PID_FILE
    check_service_status "前端服务" $FRONTEND_PORT $FRONTEND_PID_FILE
    echo "================================"
    
    if check_port $BACKEND_PORT && check_port $FRONTEND_PORT; then
        echo -e "${GREEN}🎉 所有服务运行正常${NC}"
        echo ""
        echo -e "${YELLOW}📱 访问地址:${NC}"
        echo -e "   前端应用: ${BLUE}http://localhost:$FRONTEND_PORT${NC}"
        echo -e "   后端API:  ${BLUE}http://127.0.0.1:$BACKEND_PORT${NC}"
        echo -e "   测试账号: ${PURPLE}testuser / testpass123${NC}"
    else
        echo -e "${RED}⚠️  部分服务未运行${NC}"
    fi
}

# 启动所有服务
start_all() {
    echo -e "${CYAN}🚀 AI情绪日记APP - 启动所有服务${NC}"
    echo "================================"
    
    # 检查并停止已运行的服务
    if check_port $BACKEND_PORT; then
        echo -e "${YELLOW}⚠️  后端服务已在运行，正在重启...${NC}"
        stop_service "后端服务" $BACKEND_PORT $BACKEND_PID_FILE
        sleep 2
    fi
    
    if check_port $FRONTEND_PORT; then
        echo -e "${YELLOW}⚠️  前端服务已在运行，正在重启...${NC}"
        stop_service "前端服务" $FRONTEND_PORT $FRONTEND_PID_FILE
        sleep 2
    fi
    
    # 启动后端
    if start_backend; then
        sleep 2
        # 启动前端
        if start_frontend; then
            echo ""
            echo -e "${GREEN}🎉 所有服务启动完成！${NC}"
            echo ""
            show_status
        else
            echo -e "${RED}❌ 前端服务启动失败${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ 后端服务启动失败${NC}"
        return 1
    fi
}

# 停止所有服务
stop_all() {
    echo -e "${CYAN}🛑 AI情绪日记APP - 停止所有服务${NC}"
    echo "================================"
    
    stop_service "前端服务" $FRONTEND_PORT $FRONTEND_PID_FILE
    stop_service "后端服务" $BACKEND_PORT $BACKEND_PID_FILE
    
    echo -e "${GREEN}✅ 所有服务已停止${NC}"
}

# 重启所有服务
restart_all() {
    echo -e "${CYAN}🔄 AI情绪日记APP - 重启所有服务${NC}"
    echo "================================"
    
    stop_all
    sleep 3
    start_all
}

# 查看日志
show_logs() {
    local service=$1
    
    case $service in
        "backend"|"后端")
            echo -e "${CYAN}📋 后端服务日志 (最近50行):${NC}"
            echo "================================"
            if [ -f $BACKEND_LOG ]; then
                tail -n 50 $BACKEND_LOG
            else
                echo "日志文件不存在"
            fi
            ;;
        "frontend"|"前端")
            echo -e "${CYAN}📋 前端服务日志 (最近50行):${NC}"
            echo "================================"
            if [ -f $FRONTEND_LOG ]; then
                tail -n 50 $FRONTEND_LOG
            else
                echo "日志文件不存在"
            fi
            ;;
        "script"|"脚本")
            echo -e "${CYAN}📋 脚本运行日志 (最近50行):${NC}"
            echo "================================"
            if [ -f $SCRIPT_LOG ]; then
                tail -n 50 $SCRIPT_LOG
            else
                echo "日志文件不存在"
            fi
            ;;
        *)
            echo -e "${CYAN}📋 所有服务日志:${NC}"
            echo "================================"
            echo -e "${YELLOW}后端日志:${NC}"
            [ -f $BACKEND_LOG ] && tail -n 20 $BACKEND_LOG || echo "无日志文件"
            echo ""
            echo -e "${YELLOW}前端日志:${NC}"
            [ -f $FRONTEND_LOG ] && tail -n 20 $FRONTEND_LOG || echo "无日志文件"
            ;;
    esac
}

# 显示帮助信息
show_help() {
    echo -e "${CYAN}🔧 AI情绪日记APP - 服务管理脚本${NC}"
    echo "================================"
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo -e "${YELLOW}可用命令:${NC}"
    echo "  start, s       - 启动所有服务"
    echo "  stop           - 停止所有服务"
    echo "  restart, r     - 重启所有服务"
    echo "  status, st     - 查看服务状态"
    echo "  logs [service] - 查看日志 (backend/frontend/script/all)"
    echo "  help, h        - 显示帮助信息"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0 start       # 启动所有服务"
    echo "  $0 restart     # 重启所有服务"
    echo "  $0 status      # 查看状态"
    echo "  $0 logs backend # 查看后端日志"
    echo ""
    echo -e "${YELLOW}服务信息:${NC}"
    echo "  后端服务: Django (端口 $BACKEND_PORT)"
    echo "  前端服务: Vite/Uniapp (端口 $FRONTEND_PORT)"
    echo "  日志目录: $LOG_DIR/"
}

# 主程序
main() {
    # 记录脚本启动
    log "脚本启动 - 命令: $*"
    
    case "${1:-help}" in
        "start"|"s")
            start_all
            ;;
        "stop")
            stop_all
            ;;
        "restart"|"r")
            restart_all
            ;;
        "status"|"st")
            show_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "help"|"h"|*)
            show_help
            ;;
    esac
}

# 检查是否为root用户
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  不建议使用root用户运行此脚本${NC}"
fi

# 运行主程序
main "$@" 