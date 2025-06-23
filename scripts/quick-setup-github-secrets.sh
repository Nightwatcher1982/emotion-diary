#!/bin/bash

# AI情绪日记 - GitHub Secrets 快速配置脚本
# 用于获取需要配置到GitHub的密钥信息

echo "🚀 AI情绪日记 - GitHub Secrets 配置信息"
echo "============================================"
echo ""

# 检查SSH密钥是否存在
if [ ! -f ~/.ssh/emotion-diary-deploy ]; then
    echo "❌ SSH密钥不存在，请先运行 SSH 密钥生成脚本"
    exit 1
fi

echo "📋 请将以下信息配置到GitHub Secrets："
echo "访问地址: https://github.com/Nightwatcher1982/emotion-diary/settings/secrets/actions"
echo ""

echo "1️⃣ SSH_PRIVATE_KEY 的值："
echo "----------------------------------------"
cat ~/.ssh/emotion-diary-deploy
echo ""
echo "----------------------------------------"
echo ""

echo "2️⃣ 其他必需的Secrets："
echo "----------------------------------------"
echo "SECRET名称: SERVER_HOST"
echo "值: [你的ECS公网IP地址]"
echo ""
echo "SECRET名称: SERVER_USER"  
echo "值: root"
echo ""
echo "SECRET名称: QIANFAN_API_KEY"
echo "值: [你的百度千帆API密钥]"
echo "----------------------------------------"
echo ""

echo "📝 配置步骤："
echo "1. 访问: https://github.com/Nightwatcher1982/emotion-diary/settings/secrets/actions"
echo "2. 点击 'New repository secret'"
echo "3. 输入Secret名称和对应的值"
echo "4. 点击 'Add secret'"
echo "5. 重复步骤2-4，直到所有4个Secrets都配置完成"
echo ""

echo "✅ 配置完成后，推送代码到GitHub将自动触发部署！"
echo ""

# 检查网络连接
echo "🔍 检查GitHub连接状态..."
if ping -c 1 github.com &> /dev/null; then
    echo "✅ GitHub连接正常"
else
    echo "⚠️  GitHub连接可能有问题，请检查网络"
fi

echo ""
echo "🎯 下一步操作："
echo "1. 复制上面的SSH_PRIVATE_KEY内容到GitHub"
echo "2. 配置其他3个Secrets"
echo "3. 运行: git push origin main"
echo "4. 查看部署状态: https://github.com/Nightwatcher1982/emotion-diary/actions" 