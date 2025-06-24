#!/bin/bash

# AI情绪日记应用 - 服务器一键部署脚本
# 版本: v1.0.0
# 作者: Nightwatcher1982

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "请不要使用root用户运行此脚本！"
        log_info "建议创建普通用户：sudo adduser emotion && sudo usermod -aG sudo emotion"
        exit 1
    fi
}

# 检查系统要求
check_system() {
    log_info "检查系统要求..."
    
    # 检查操作系统
    if ! command -v lsb_release &> /dev/null; then
        log_error "不支持的操作系统，请使用Ubuntu 18.04+或Debian 10+"
        exit 1
    fi
    
    OS=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    
    log_info "检测到系统: $OS $VERSION"
    
    # 检查内存
    MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$MEMORY_GB" -lt 1 ]; then
        log_warning "系统内存少于1GB，可能影响性能"
    fi
    
    # 检查磁盘空间
    DISK_GB=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
    if [ "$DISK_GB" -lt 5 ]; then
        log_error "磁盘空间不足，至少需要5GB"
        exit 1
    fi
    
    log_success "系统检查通过"
}

# 安装Docker
install_docker() {
    if command -v docker &> /dev/null; then
        log_info "Docker已安装，版本: $(docker --version)"
        return
    fi
    
    log_info "安装Docker..."
    
    # 更新包索引
    sudo apt update
    
    # 安装依赖
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # 添加Docker官方GPG密钥
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # 添加Docker仓库
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装Docker Engine
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    
    # 将当前用户添加到docker组
    sudo usermod -aG docker $USER
    
    log_success "Docker安装完成"
}

# 安装Docker Compose
install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        log_info "Docker Compose已安装，版本: $(docker-compose --version)"
        return
    fi
    
    log_info "安装Docker Compose..."
    
    # 获取最新版本
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    
    # 下载并安装
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    log_success "Docker Compose安装完成"
}

# 克隆项目
clone_project() {
    REPO_URL="https://github.com/Nightwatcher1982/emotion-diary.git"
    PROJECT_DIR="emotion-diary"
    
    if [ -d "$PROJECT_DIR" ]; then
        log_info "项目目录已存在，更新代码..."
        cd $PROJECT_DIR
        git pull origin main
        git checkout v1.0.0
    else
        log_info "克隆项目代码..."
        git clone $REPO_URL
        cd $PROJECT_DIR
        git checkout v1.0.0
    fi
    
    log_success "项目代码准备完成"
}

# 配置环境变量
configure_environment() {
    log_info "配置环境变量..."
    
    if [ ! -f ".env" ]; then
        cp docker.env .env
        log_info "已创建.env文件，请根据需要修改配置"
    fi
    
    # 生成随机SECRET_KEY
    SECRET_KEY=$(openssl rand -base64 32)
    sed -i "s/your-secret-key-here/$SECRET_KEY/" .env
    
    # 获取服务器IP
    SERVER_IP=$(curl -s http://checkip.amazonaws.com/ || echo "127.0.0.1")
    sed -i "s/localhost,127.0.0.1/$SERVER_IP,localhost,127.0.0.1/" .env
    
    log_info "服务器IP: $SERVER_IP"
    log_success "环境变量配置完成"
}

# 构建和启动服务
deploy_services() {
    log_info "构建并启动服务..."
    
    # 构建镜像
    docker-compose build
    
    # 启动服务
    docker-compose up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 30
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        log_success "服务启动成功"
    else
        log_error "服务启动失败，请检查日志: docker-compose logs"
        exit 1
    fi
}

# 健康检查
health_check() {
    log_info "执行健康检查..."
    
    # 检查健康端点
    if curl -f -s http://localhost/health/ > /dev/null; then
        log_success "健康检查通过"
    else
        log_warning "健康检查失败，但服务可能仍在启动中"
    fi
    
    # 检查前端页面
    if curl -f -s http://localhost/ | grep -q "心晴日记"; then
        log_success "前端页面正常"
    else
        log_warning "前端页面检查失败"
    fi
    
    # 显示服务状态
    echo
    log_info "服务状态:"
    docker-compose ps
}

# 配置防火墙
configure_firewall() {
    log_info "配置防火墙..."
    
    if command -v ufw &> /dev/null; then
        # 配置ufw规则
        sudo ufw --force enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        
        log_success "防火墙配置完成"
    else
        log_warning "未检测到ufw，请手动配置防火墙"
    fi
}

# 显示部署信息
show_deployment_info() {
    echo
    echo "=========================================="
    log_success "🎉 部署完成！"
    echo "=========================================="
    echo
    
    SERVER_IP=$(curl -s http://checkip.amazonaws.com/ || echo "your-server-ip")
    
    echo "📱 应用访问地址:"
    echo "   http://$SERVER_IP/"
    echo
    
    echo "🔍 健康检查:"
    echo "   http://$SERVER_IP/health/"
    echo
    
    echo "📊 API接口:"
    echo "   http://$SERVER_IP/api/v1/"
    echo
    
    echo "🔧 管理命令:"
    echo "   查看日志: docker-compose logs -f"
    echo "   重启服务: docker-compose restart"
    echo "   停止服务: docker-compose down"
    echo "   更新代码: git pull && docker-compose up -d --build"
    echo
    
    echo "📋 后续配置:"
    echo "   1. 配置域名解析到: $SERVER_IP"
    echo "   2. 设置SSL证书 (推荐使用Let's Encrypt)"
    echo "   3. 配置千帆AI API密钥 (编辑.env文件)"
    echo "   4. 配置微信小程序参数 (编辑.env文件)"
    echo "   5. 设置数据备份策略"
    echo
    
    echo "📞 技术支持:"
    echo "   GitHub: https://github.com/Nightwatcher1982/emotion-diary"
    echo "   文档: docs/服务器Docker部署指南.md"
    echo
}

# 主函数
main() {
    echo "=========================================="
    echo "🚀 AI情绪日记应用 - 服务器部署脚本"
    echo "=========================================="
    echo
    
    # 检查用户权限
    check_root
    
    # 系统检查
    check_system
    
    # 安装依赖
    install_docker
    install_docker_compose
    
    # 项目部署
    clone_project
    configure_environment
    deploy_services
    
    # 健康检查
    health_check
    
    # 安全配置
    configure_firewall
    
    # 显示部署信息
    show_deployment_info
    
    log_info "如果这是第一次安装Docker，请重新登录以应用用户组更改"
    log_info "或者执行: newgrp docker"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 