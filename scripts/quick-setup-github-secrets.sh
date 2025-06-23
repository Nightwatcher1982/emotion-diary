#!/bin/bash

# GitHub Secrets 快速配置脚本
# 用于配置 emotion-diary 项目的 CI/CD 部署所需的 secrets

echo "🔐 GitHub Secrets 配置指南"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 需要配置的 GitHub Secrets:${NC}"
echo ""
echo "1. SSH_PRIVATE_KEY - SSH私钥内容"
echo "2. SERVER_HOST - 阿里云ECS公网IP"
echo "3. SERVER_USER - ECS服务器用户名"
echo "4. QIANFAN_API_KEY - 百度千帆API密钥 (可选)"
echo ""

# 检查SSH密钥
echo -e "${YELLOW}🔍 检查SSH密钥...${NC}"
if [ -f ~/.ssh/emotion-diary-deploy ]; then
    echo -e "${GREEN}✅ 找到SSH私钥: ~/.ssh/emotion-diary-deploy${NC}"
    echo ""
    echo -e "${BLUE}📝 SSH_PRIVATE_KEY 内容:${NC}"
    echo "复制以下内容到GitHub Secrets中的 SSH_PRIVATE_KEY:"
    echo "----------------------------------------"
    cat ~/.ssh/emotion-diary-deploy
    echo "----------------------------------------"
    echo ""
else
    echo -e "${RED}❌ 未找到SSH私钥${NC}"
    echo "请先运行以下命令生成SSH密钥:"
    echo "ssh-keygen -t rsa -b 4096 -C \"github-actions@emotion-diary\" -f ~/.ssh/emotion-diary-deploy"
    echo ""
fi

# 服务器信息
echo -e "${YELLOW}🖥️  服务器信息配置:${NC}"
echo ""
echo -e "${BLUE}SERVER_HOST:${NC}"
echo "输入你的阿里云ECS公网IP地址"
echo "例如: 47.96.123.456"
echo ""

echo -e "${BLUE}SERVER_USER:${NC}"
echo "输入ECS服务器的用户名"
echo "通常是: root 或 ubuntu 或 ecs-user"
echo ""

# API密钥
echo -e "${YELLOW}🤖 API密钥配置:${NC}"
echo ""
echo -e "${BLUE}QIANFAN_API_KEY (可选):${NC}"
echo "如果你有百度千帆API密钥，可以配置此项"
echo "格式通常类似: sk-xxxxxxxxxxxxxxxx"
echo ""

# GitHub配置步骤
echo -e "${BLUE}📱 GitHub Secrets 配置步骤:${NC}"
echo ""
echo "1. 打开你的GitHub仓库页面:"
echo "   https://github.com/Nightwatcher1982/emotion-diary"
echo ""
echo "2. 点击 Settings 标签"
echo ""
echo "3. 在左侧菜单中找到 'Secrets and variables' → 'Actions'"
echo ""
echo "4. 点击 'New repository secret' 按钮"
echo ""
echo "5. 依次添加以下secrets:"
echo ""
echo "   名称: SSH_PRIVATE_KEY"
echo "   值: 上面显示的SSH私钥内容"
echo ""
echo "   名称: SERVER_HOST"
echo "   值: 你的阿里云ECS公网IP"
echo ""
echo "   名称: SERVER_USER"
echo "   值: 你的ECS用户名"
echo ""

# 验证脚本
echo -e "${YELLOW}🧪 配置完成后的验证:${NC}"
echo ""
echo "配置完成后，推送代码到main分支:"
echo "git add ."
echo "git commit -m \"配置GitHub Secrets\""
echo "git push origin main"
echo ""
echo "然后在GitHub Actions页面查看部署结果"
echo ""

# 故障排除
echo -e "${RED}🔧 常见问题排除:${NC}"
echo ""
echo "1. SSH连接失败:"
echo "   - 检查SERVER_HOST是否正确"
echo "   - 确认ECS安全组开放了22端口"
echo "   - 验证SSH密钥是否正确上传到服务器"
echo ""
echo "2. 权限被拒绝:"
echo "   - 检查SERVER_USER是否正确"
echo "   - 确认用户有sudo权限"
echo ""
echo "3. 密钥格式错误:"
echo "   - 确保复制了完整的私钥内容"
echo "   - 包含 -----BEGIN OPENSSH PRIVATE KEY----- 和 -----END OPENSSH PRIVATE KEY-----"
echo ""

echo -e "${GREEN}🎉 配置完成后，你的项目将支持自动部署！${NC}"
echo "" 