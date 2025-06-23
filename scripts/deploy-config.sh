#!/bin/bash

# AI情绪日记 - 部署配置文件
# 请在这里配置您的服务器信息

# ================================
# 服务器配置 (必需)
# ================================

# 服务器IP地址 - 请修改为您的ECS服务器IP
export SERVER_HOST="YOUR_SERVER_IP_HERE"

# SSH用户名 - 通常为root
export SERVER_USER="root"

# SSH私钥路径 - 如果使用默认路径可以不修改
export SSH_KEY_PATH="$HOME/.ssh/emotion-diary-deploy"

# ================================
# 部署选项 (可选)
# ================================

# 项目目录名称
export PROJECT_DIR="emotion-diary"

# 远程部署路径
export REMOTE_PATH="/home/$SERVER_USER/$PROJECT_DIR"

# ================================
# 使用说明
# ================================
# 1. 修改上面的 SERVER_HOST 为您的实际服务器IP
# 2. 运行: source scripts/deploy-config.sh
# 3. 运行: ./scripts/deploy-current-version.sh

echo "🔧 部署配置已加载"
echo "服务器: $SERVER_HOST"
echo "用户: $SERVER_USER"
echo "SSH密钥: $SSH_KEY_PATH"
echo ""
echo "如果配置正确，请运行: ./scripts/deploy-current-version.sh" 