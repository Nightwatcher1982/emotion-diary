#!/bin/bash

# AI情绪日记 - 服务器环境配置脚本
# 用于在阿里云ECS上配置运行环境

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 AI情绪日记 - 服务器环境配置${NC}"
echo "================================="
echo ""

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo -e "${RED}❌ 无法检测操作系统${NC}"
    exit 1
fi

echo -e "${BLUE}📋 系统信息:${NC}"
echo "  操作系统: $OS"
echo "  版本: $VER"
echo "  架构: $(uname -m)"
echo ""

# 更新系统包
echo -e "${YELLOW}📦 更新系统包...${NC}"
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt-get update
    PACKAGE_MANAGER="apt-get"
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Amazon Linux"* ]]; then
    sudo yum update -y
    PACKAGE_MANAGER="yum"
else
    echo -e "${RED}❌ 不支持的操作系统: $OS${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 系统包更新完成${NC}"
echo ""

# 安装基础工具
echo -e "${YELLOW}🔨 安装基础工具...${NC}"
if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
    sudo apt-get install -y \
        curl \
        wget \
        git \
        unzip \
        vim \
        htop \
        tree \
        rsync \
        build-essential \
        software-properties-common
elif [ "$PACKAGE_MANAGER" = "yum" ]; then
    sudo yum install -y \
        curl \
        wget \
        git \
        unzip \
        vim \
        htop \
        tree \
        rsync \
        gcc \
        gcc-c++ \
        make
fi

echo -e "${GREEN}✅ 基础工具安装完成${NC}"
echo ""

# 安装Python 3.9+
echo -e "${YELLOW}🐍 安装Python 3.9+...${NC}"
if ! command -v python3.9 &> /dev/null; then
    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        sudo add-apt-repository ppa:deadsnakes/ppa -y
        sudo apt-get update
        sudo apt-get install -y python3.9 python3.9-venv python3.9-dev python3-pip
        # 设置python3指向python3.9
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    elif [ "$PACKAGE_MANAGER" = "yum" ]; then
        sudo yum install -y python39 python39-devel python39-pip
        sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    fi
else
    echo "Python 3.9+ 已安装"
fi

# 验证Python安装
python3 --version
pip3 --version

echo -e "${GREEN}✅ Python安装完成${NC}"
echo ""

# 安装Node.js 18+
echo -e "${YELLOW}📱 安装Node.js 18+...${NC}"
if ! command -v node &> /dev/null; then
    # 使用NodeSource repository安装最新的Node.js
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        sudo apt-get install -y nodejs
    elif [ "$PACKAGE_MANAGER" = "yum" ]; then
        sudo yum install -y nodejs npm
    fi
else
    echo "Node.js 已安装"
fi

# 验证Node.js安装
node --version
npm --version

echo -e "${GREEN}✅ Node.js安装完成${NC}"
echo ""

# 安装MySQL (可选)
echo -e "${YELLOW}🗃️  安装MySQL...${NC}"
read -p "是否安装MySQL数据库? (y/N): " install_mysql
if [[ $install_mysql =~ ^[Yy]$ ]]; then
    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        sudo apt-get install -y mysql-server mysql-client
        sudo systemctl start mysql
        sudo systemctl enable mysql
    elif [ "$PACKAGE_MANAGER" = "yum" ]; then
        sudo yum install -y mysql-server mysql
        sudo systemctl start mysqld
        sudo systemctl enable mysqld
    fi
    
    echo -e "${GREEN}✅ MySQL安装完成${NC}"
    echo -e "${YELLOW}⚠️  请运行 'sudo mysql_secure_installation' 配置MySQL安全设置${NC}"
else
    echo "跳过MySQL安装"
fi
echo ""

# 安装Nginx (可选)
echo -e "${YELLOW}🌐 安装Nginx...${NC}"
read -p "是否安装Nginx Web服务器? (y/N): " install_nginx
if [[ $install_nginx =~ ^[Yy]$ ]]; then
    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        sudo apt-get install -y nginx
    elif [ "$PACKAGE_MANAGER" = "yum" ]; then
        sudo yum install -y nginx
    fi
    
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    echo -e "${GREEN}✅ Nginx安装完成${NC}"
    echo "默认网站: http://$(curl -s ifconfig.me)"
else
    echo "跳过Nginx安装"
fi
echo ""

# 配置防火墙
echo -e "${YELLOW}🔥 配置防火墙...${NC}"
if command -v ufw &> /dev/null; then
    # Ubuntu/Debian使用ufw
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 8000/tcp  # Django开发服务器
    echo "y" | sudo ufw enable
    echo -e "${GREEN}✅ UFW防火墙配置完成${NC}"
elif command -v firewall-cmd &> /dev/null; then
    # CentOS/RHEL使用firewalld
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    sudo firewall-cmd --permanent --add-service=ssh
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-port=8000/tcp
    sudo firewall-cmd --reload
    echo -e "${GREEN}✅ Firewalld防火墙配置完成${NC}"
else
    echo -e "${YELLOW}⚠️  未找到防火墙管理工具，请手动配置${NC}"
fi
echo ""

# 创建项目目录
echo -e "${YELLOW}📁 创建项目目录...${NC}"
PROJECT_DIR="$HOME/emotion-diary"
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/logs"

echo -e "${GREEN}✅ 项目目录创建完成: $PROJECT_DIR${NC}"
echo ""

# 配置Git (如果需要)
echo -e "${YELLOW}📝 配置Git...${NC}"
if [ -z "$(git config --global user.name)" ]; then
    read -p "请输入Git用户名: " git_username
    git config --global user.name "$git_username"
fi

if [ -z "$(git config --global user.email)" ]; then
    read -p "请输入Git邮箱: " git_email
    git config --global user.email "$git_email"
fi

echo -e "${GREEN}✅ Git配置完成${NC}"
echo ""

# 创建systemd服务文件 (可选)
echo -e "${YELLOW}⚙️  创建systemd服务...${NC}"
read -p "是否创建emotion-diary systemd服务? (y/N): " create_service
if [[ $create_service =~ ^[Yy]$ ]]; then
    sudo tee /etc/systemd/system/emotion-diary.service > /dev/null <<EOF
[Unit]
Description=AI Emotion Diary Django Application
After=network.target

[Service]
Type=forking
User=$USER
Group=$USER
WorkingDirectory=$PROJECT_DIR/backend
Environment=PATH=$PROJECT_DIR/backend/venv/bin
ExecStart=$PROJECT_DIR/backend/venv/bin/python manage.py runserver 0.0.0.0:8000
ExecReload=/bin/kill -s HUP \$MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    echo -e "${GREEN}✅ systemd服务创建完成${NC}"
    echo "使用命令:"
    echo "  sudo systemctl start emotion-diary    # 启动服务"
    echo "  sudo systemctl enable emotion-diary   # 开机自启"
    echo "  sudo systemctl status emotion-diary   # 查看状态"
else
    echo "跳过systemd服务创建"
fi
echo ""

# 显示总结
echo -e "${GREEN}🎉 服务器环境配置完成！${NC}"
echo ""
echo -e "${BLUE}📋 安装总结:${NC}"
echo "  ✅ 基础工具已安装"
echo "  ✅ Python $(python3 --version | cut -d' ' -f2) 已安装"
echo "  ✅ Node.js $(node --version) 已安装"
if command -v mysql &> /dev/null; then
    echo "  ✅ MySQL 已安装"
fi
if command -v nginx &> /dev/null; then
    echo "  ✅ Nginx 已安装"
fi
echo "  ✅ 项目目录: $PROJECT_DIR"
echo ""

echo -e "${BLUE}🔧 下一步操作:${NC}"
echo "1. 使用手动部署脚本部署项目:"
echo "   ./scripts/manual-deploy.sh"
echo ""
echo "2. 或者手动克隆项目:"
echo "   cd $PROJECT_DIR"
echo "   git clone https://github.com/Nightwatcher1982/emotion-diary.git ."
echo ""
echo "3. 配置数据库连接 (如果使用MySQL)"
echo ""
echo "4. 启动服务并测试"
echo ""
echo -e "${GREEN}服务器环境配置完成！${NC}" 