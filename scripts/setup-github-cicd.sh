#!/bin/bash

# GitHub CI/CD 快速设置脚本
# 使用方法: ./setup-github-cicd.sh

set -e

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

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# 检查必要工具
check_requirements() {
    log "检查必要工具..."
    
    for cmd in git ssh-keygen; do
        if ! command -v $cmd &> /dev/null; then
            error "缺少必要命令: $cmd"
        fi
    done
    
    log "工具检查通过"
}

# 初始化Git仓库
init_git_repo() {
    log "初始化Git仓库..."
    
    if [ ! -d ".git" ]; then
        git init
        log "Git仓库已初始化"
    else
        log "Git仓库已存在"
    fi
    
    # 检查是否有远程仓库
    if ! git remote get-url origin &> /dev/null; then
        warn "请手动添加GitHub远程仓库:"
        echo "git remote add origin https://github.com/your-username/emotion-diary.git"
        read -p "按回车键继续..."
    fi
}

# 生成SSH密钥
generate_ssh_key() {
    log "生成部署用SSH密钥..."
    
    SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
    
    if [ ! -f "$SSH_KEY_PATH" ]; then
        ssh-keygen -t rsa -b 4096 -C "github-actions@emotion-diary" -f "$SSH_KEY_PATH" -N ""
        log "SSH密钥已生成: $SSH_KEY_PATH"
    else
        log "SSH密钥已存在: $SSH_KEY_PATH"
    fi
    
    # 显示公钥
    echo ""
    info "请将以下公钥添加到你的阿里云ECS服务器:"
    echo "----------------------------------------"
    cat "${SSH_KEY_PATH}.pub"
    echo "----------------------------------------"
    echo ""
    info "在服务器上执行以下命令:"
    echo "echo '$(cat ${SSH_KEY_PATH}.pub)' >> ~/.ssh/authorized_keys"
    echo ""
    read -p "完成后按回车键继续..."
    
    # 显示私钥（用于GitHub Secrets）
    echo ""
    info "请将以下私钥添加到GitHub Secrets (SSH_PRIVATE_KEY):"
    echo "----------------------------------------"
    cat "$SSH_KEY_PATH"
    echo "----------------------------------------"
    echo ""
    read -p "完成后按回车键继续..."
}

# 配置GitHub Secrets指导
setup_github_secrets() {
    log "GitHub Secrets配置指导..."
    
    echo ""
    info "请在GitHub仓库中配置以下Secrets:"
    echo "1. 进入仓库页面 → Settings → Secrets and variables → Actions"
    echo "2. 点击 'New repository secret' 添加以下配置:"
    echo ""
    echo "Secret名称: SSH_PRIVATE_KEY"
    echo "值: [刚才显示的私钥内容]"
    echo ""
    echo "Secret名称: SERVER_HOST"
    echo -n "值: "
    read -p "请输入你的阿里云ECS公网IP: " SERVER_IP
    echo ""
    echo "Secret名称: SERVER_USER"
    echo "值: root"
    echo ""
    echo "Secret名称: QIANFAN_API_KEY"
    echo -n "值: "
    read -p "请输入你的百度千帆API密钥: " QIANFAN_KEY
    echo ""
    
    # 保存配置到本地文件
    cat > .github-secrets.txt << EOF
GitHub Secrets配置:
==================
SSH_PRIVATE_KEY: [私钥内容已在上面显示]
SERVER_HOST: $SERVER_IP
SERVER_USER: root
QIANFAN_API_KEY: $QIANFAN_KEY

配置完成后删除此文件: rm .github-secrets.txt
EOF
    
    log "配置信息已保存到 .github-secrets.txt"
    read -p "配置完成后按回车键继续..."
}

# 测试SSH连接
test_ssh_connection() {
    log "测试SSH连接..."
    
    if [ -z "$SERVER_IP" ]; then
        read -p "请输入服务器IP地址: " SERVER_IP
    fi
    
    SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"
    
    if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$SERVER_IP "echo 'SSH连接成功'" 2>/dev/null; then
        log "SSH连接测试成功"
    else
        warn "SSH连接测试失败，请检查:"
        echo "1. 服务器IP地址是否正确"
        echo "2. 公钥是否已添加到服务器"
        echo "3. 服务器SSH服务是否正常"
        echo "4. 防火墙是否允许SSH连接"
    fi
}

# 提交代码
commit_and_push() {
    log "提交CI/CD配置文件..."
    
    # 添加所有文件
    git add .
    
    # 检查是否有变更
    if git diff --cached --quiet; then
        log "没有需要提交的变更"
    else
        git commit -m "feat: 添加GitHub Actions CI/CD配置

- 添加自动化测试流程
- 添加自动化部署配置
- 添加安全扫描
- 支持自动回滚"
        
        log "代码已提交到本地仓库"
        
        # 推送到远程仓库
        if git remote get-url origin &> /dev/null; then
            echo ""
            read -p "是否推送到GitHub仓库? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git push origin main
                log "代码已推送到GitHub"
                echo ""
                info "请访问GitHub仓库的Actions页面查看CI/CD流程:"
                echo "https://github.com/your-username/emotion-diary/actions"
            fi
        else
            warn "未配置远程仓库，请手动推送代码"
        fi
    fi
}

# 显示后续步骤
show_next_steps() {
    log "设置完成！"
    echo ""
    echo "==================================="
    echo "  GitHub CI/CD 设置完成"
    echo "==================================="
    echo ""
    echo "✅ 已完成:"
    echo "  - Git仓库初始化"
    echo "  - SSH密钥生成"
    echo "  - CI/CD配置文件创建"
    echo "  - 代码提交"
    echo ""
    echo "📋 下一步操作:"
    echo "1. 确保GitHub Secrets配置正确"
    echo "2. 推送代码到main分支触发部署"
    echo "3. 在GitHub Actions页面监控部署状态"
    echo "4. 验证部署结果"
    echo ""
    echo "🔗 有用链接:"
    echo "  - GitHub Actions: https://github.com/your-username/emotion-diary/actions"
    echo "  - 部署文档: docs/GitHub-CICD-部署指南.md"
    echo ""
    echo "🚀 触发部署:"
    echo "  git push origin main"
    echo ""
    echo "==================================="
}

# 主函数
main() {
    log "开始设置GitHub CI/CD..."
    
    check_requirements
    init_git_repo
    generate_ssh_key
    setup_github_secrets
    test_ssh_connection
    commit_and_push
    show_next_steps
    
    log "GitHub CI/CD设置完成！"
}

# 运行主函数
main "$@" 