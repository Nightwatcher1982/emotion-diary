#!/bin/bash

# AI情绪日记 - 阿里云自动化部署脚本
# 使用方法: ./deploy.sh [production|staging]

set -e

# 配置变量
PROJECT_NAME="emotion-diary"
DEPLOY_USER="www-data"
DEPLOY_GROUP="www-data"
PROJECT_ROOT="/var/www/$PROJECT_NAME"
BACKUP_DIR="/var/backups/$PROJECT_NAME"
LOG_DIR="/var/log/$PROJECT_NAME"
RUN_DIR="/var/run/$PROJECT_NAME"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# 检查运行环境
check_environment() {
    log "检查部署环境..."
    
    # 检查是否为root用户
    if [ "$EUID" -ne 0 ]; then
        error "请使用root用户运行此脚本"
    fi
    
    # 检查必要的命令
    for cmd in git python3 pip3 nginx mysql systemctl; do
        if ! command -v $cmd &> /dev/null; then
            error "缺少必要命令: $cmd"
        fi
    done
    
    log "环境检查通过"
}

# 创建必要的目录和用户
setup_directories() {
    log "创建项目目录结构..."
    
    # 创建用户和组（如果不存在）
    if ! id "$DEPLOY_USER" &>/dev/null; then
        useradd -r -s /bin/false $DEPLOY_USER
    fi
    
    # 创建目录
    mkdir -p $PROJECT_ROOT
    mkdir -p $BACKUP_DIR
    mkdir -p $LOG_DIR
    mkdir -p $RUN_DIR
    mkdir -p /etc/ssl/certs
    mkdir -p /etc/ssl/private
    
    # 设置权限
    chown -R $DEPLOY_USER:$DEPLOY_GROUP $PROJECT_ROOT
    chown -R $DEPLOY_USER:$DEPLOY_GROUP $LOG_DIR
    chown -R $DEPLOY_USER:$DEPLOY_GROUP $RUN_DIR
    chmod 755 $PROJECT_ROOT
    chmod 755 $LOG_DIR
    chmod 755 $RUN_DIR
}

# 安装系统依赖
install_system_dependencies() {
    log "安装系统依赖..."
    
    # 更新包管理器
    apt update
    
    # 安装基础依赖
    apt install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        nginx \
        mysql-server \
        redis-server \
        git \
        curl \
        wget \
        unzip \
        supervisor \
        certbot \
        python3-certbot-nginx \
        build-essential \
        libmysqlclient-dev \
        pkg-config
    
    log "系统依赖安装完成"
}

# 配置MySQL数据库
setup_database() {
    log "配置MySQL数据库..."
    
    # 启动MySQL服务
    systemctl start mysql
    systemctl enable mysql
    
    # 创建数据库和用户
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS emotion_diary CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'emotion_user'@'localhost' IDENTIFIED BY 'emotion_password_2024';
GRANT ALL PRIVILEGES ON emotion_diary.* TO 'emotion_user'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    log "数据库配置完成"
}

# 配置Redis
setup_redis() {
    log "配置Redis..."
    
    # 启动Redis服务
    systemctl start redis-server
    systemctl enable redis-server
    
    # 配置Redis（可选：设置密码等）
    log "Redis配置完成"
}

# 部署代码
deploy_code() {
    log "部署应用代码..."
    
    # 备份现有代码（如果存在）
    if [ -d "$PROJECT_ROOT/.git" ]; then
        log "备份现有代码..."
        tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz" -C $PROJECT_ROOT .
    fi
    
    # 克隆或更新代码
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        log "克隆代码仓库..."
        # 这里需要替换为你的实际Git仓库地址
        # git clone https://github.com/your-username/emotion-diary.git $PROJECT_ROOT
        # 临时方案：复制当前目录的代码
        cp -r ../backend/* $PROJECT_ROOT/
    else
        log "更新代码..."
        cd $PROJECT_ROOT
        git pull origin main
    fi
    
    # 设置权限
    chown -R $DEPLOY_USER:$DEPLOY_GROUP $PROJECT_ROOT
}

# 配置Python环境
setup_python_environment() {
    log "配置Python虚拟环境..."
    
    cd $PROJECT_ROOT
    
    # 创建虚拟环境
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    # 激活虚拟环境并安装依赖
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    
    # 设置权限
    chown -R $DEPLOY_USER:$DEPLOY_GROUP venv
}

# 配置Django应用
setup_django() {
    log "配置Django应用..."
    
    cd $PROJECT_ROOT
    source venv/bin/activate
    
    # 设置环境变量
    export DJANGO_SETTINGS_MODULE=emotion_diary_api.settings_production
    
    # 创建.env文件
    cat > .env <<EOF
SECRET_KEY=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
DEBUG=False
ALLOWED_HOSTS=your-domain.com,www.your-domain.com,$(curl -s ifconfig.me)

# 数据库配置
DB_NAME=emotion_diary
DB_USER=emotion_user
DB_PASSWORD=emotion_password_2024
DB_HOST=localhost
DB_PORT=3306

# Redis配置
REDIS_URL=redis://127.0.0.1:6379/1

# 邮件配置
EMAIL_HOST=smtp.aliyun.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@aliyun.com
EMAIL_HOST_PASSWORD=your-email-password
DEFAULT_FROM_EMAIL=noreply@your-domain.com
ADMIN_EMAIL=admin@your-domain.com

# 百度千帆API配置
QIANFAN_API_KEY=your-qianfan-api-key
EOF
    
    # 数据库迁移
    python manage.py makemigrations
    python manage.py migrate
    
    # 收集静态文件
    python manage.py collectstatic --noinput
    
    # 创建超级用户（可选）
    # python manage.py createsuperuser --noinput --username admin --email admin@your-domain.com
    
    # 设置权限
    chown -R $DEPLOY_USER:$DEPLOY_GROUP .
}

# 配置Nginx
setup_nginx() {
    log "配置Nginx..."
    
    # 复制Nginx配置
    cp $PROJECT_ROOT/deploy/nginx.conf /etc/nginx/sites-available/$PROJECT_NAME
    
    # 启用站点
    ln -sf /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/
    
    # 删除默认站点
    rm -f /etc/nginx/sites-enabled/default
    
    # 测试Nginx配置
    nginx -t
    
    # 重启Nginx
    systemctl restart nginx
    systemctl enable nginx
    
    log "Nginx配置完成"
}

# 配置SSL证书
setup_ssl() {
    log "配置SSL证书..."
    
    # 使用Let's Encrypt获取SSL证书
    # 注意：需要先确保域名已经指向服务器
    # certbot --nginx -d your-domain.com -d www.your-domain.com --non-interactive --agree-tos --email admin@your-domain.com
    
    warn "请手动配置SSL证书：certbot --nginx -d your-domain.com"
}

# 配置systemd服务
setup_systemd() {
    log "配置systemd服务..."
    
    # 复制服务文件
    cp $PROJECT_ROOT/deploy/systemd_service.conf /etc/systemd/system/$PROJECT_NAME.service
    
    # 重新加载systemd配置
    systemctl daemon-reload
    
    # 启动并启用服务
    systemctl start $PROJECT_NAME
    systemctl enable $PROJECT_NAME
    
    log "systemd服务配置完成"
}

# 配置防火墙
setup_firewall() {
    log "配置防火墙..."
    
    # 安装ufw
    apt install -y ufw
    
    # 配置防火墙规则
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    
    log "防火墙配置完成"
}

# 健康检查
health_check() {
    log "执行健康检查..."
    
    # 检查服务状态
    systemctl is-active --quiet $PROJECT_NAME || error "Django服务未运行"
    systemctl is-active --quiet nginx || error "Nginx服务未运行"
    systemctl is-active --quiet mysql || error "MySQL服务未运行"
    systemctl is-active --quiet redis-server || error "Redis服务未运行"
    
    # 检查端口
    netstat -tlnp | grep :80 > /dev/null || warn "端口80未监听"
    netstat -tlnp | grep :443 > /dev/null || warn "端口443未监听"
    netstat -tlnp | grep :8000 > /dev/null || error "Django端口8000未监听"
    
    # 检查API响应
    sleep 5
    if curl -f http://localhost/api/docs/ > /dev/null 2>&1; then
        log "API健康检查通过"
    else
        warn "API响应检查失败，请检查配置"
    fi
    
    log "健康检查完成"
}

# 显示部署信息
show_deployment_info() {
    log "部署完成！"
    echo ""
    echo "==================================="
    echo "  AI情绪日记 - 部署信息"
    echo "==================================="
    echo "项目目录: $PROJECT_ROOT"
    echo "日志目录: $LOG_DIR"
    echo "备份目录: $BACKUP_DIR"
    echo ""
    echo "服务状态:"
    echo "  Django: $(systemctl is-active $PROJECT_NAME)"
    echo "  Nginx:  $(systemctl is-active nginx)"
    echo "  MySQL:  $(systemctl is-active mysql)"
    echo "  Redis:  $(systemctl is-active redis-server)"
    echo ""
    echo "访问地址:"
    echo "  API文档: http://$(curl -s ifconfig.me)/api/docs/"
    echo "  管理后台: http://$(curl -s ifconfig.me)/admin/"
    echo ""
    echo "常用命令:"
    echo "  查看日志: journalctl -u $PROJECT_NAME -f"
    echo "  重启服务: systemctl restart $PROJECT_NAME"
    echo "  查看状态: systemctl status $PROJECT_NAME"
    echo ""
    echo "下一步："
    echo "1. 配置域名DNS指向服务器IP"
    echo "2. 运行SSL证书配置: certbot --nginx -d your-domain.com"
    echo "3. 更新前端API地址为生产环境地址"
    echo "4. 配置短信服务和微信登录"
    echo "==================================="
}

# 主函数
main() {
    log "开始部署AI情绪日记到阿里云..."
    
    check_environment
    setup_directories
    install_system_dependencies
    setup_database
    setup_redis
    deploy_code
    setup_python_environment
    setup_django
    setup_nginx
    # setup_ssl  # 需要域名配置后手动执行
    setup_systemd
    setup_firewall
    health_check
    show_deployment_info
    
    log "部署完成！"
}

# 运行主函数
main "$@" 