#!/bin/bash

# 自动化构建和部署脚本
# 包含镜像版本管理（最多保留3个版本）

set -e  # 遇到错误立即退出

echo "🚀 AI情绪日记APP - 自动化构建部署"
echo "=================================="

# 检查Docker是否运行
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker Desktop"
    exit 1
fi

# 1. 构建前检查
echo ""
echo "📋 构建前检查..."
echo "当前镜像数量: $(docker images emotion-diary-app --format "{{.ID}}" | wc -l)"

# 2. 停止现有服务
echo ""
echo "⏹️  停止现有服务..."
docker-compose down

# 3. 清理可能的文件权限问题
echo ""
echo "🧹 清理临时文件..."
find . -name "._*" -delete 2>/dev/null || true

# 4. 构建新镜像
echo ""
echo "🔨 构建新镜像..."
docker-compose build app --no-cache

if [ $? -ne 0 ]; then
    echo "❌ 镜像构建失败"
    exit 1
fi

# 5. 启动服务
echo ""
echo "🚀 启动服务..."
docker-compose up -d

# 等待服务启动
echo ""
echo "⏳ 等待服务启动..."
sleep 15

# 6. 健康检查
echo ""
echo "🔍 健康检查..."
HEALTH_CHECK=$(curl -s "http://localhost/health/" | jq -r '.status' 2>/dev/null || echo "failed")

if [ "$HEALTH_CHECK" = "healthy" ]; then
    echo "✅ 服务启动成功！"
else
    echo "❌ 健康检查失败"
    echo "📋 容器状态："
    docker-compose ps
    exit 1
fi

# 7. 镜像版本管理
echo ""
echo "🧹 镜像版本管理..."

# 检查镜像数量
IMAGE_COUNT=$(docker images emotion-diary-app --format "{{.ID}}" | wc -l)
MAX_IMAGES=3

if [ "$IMAGE_COUNT" -gt "$MAX_IMAGES" ]; then
    echo "⚠️  检测到${IMAGE_COUNT}个镜像，超过最大限制${MAX_IMAGES}个"
    
    # 自动删除最老的镜像（非交互模式）
    DELETE_COUNT=$((IMAGE_COUNT - MAX_IMAGES))
    IMAGES_TO_DELETE=$(docker images emotion-diary-app --format "{{.ID}}" | tail -n $DELETE_COUNT)
    
    echo "🗑️  自动删除最老的${DELETE_COUNT}个镜像..."
    for img_id in $IMAGES_TO_DELETE; do
        # 检查镜像是否正在使用
        if docker ps --format "{{.Image}}" | grep -q "$img_id"; then
            echo "  ⚠️  跳过正在使用的镜像: $img_id"
        else
            echo "  🗑️  删除镜像: $img_id"
            docker rmi $img_id --force 2>/dev/null || echo "    ⚠️  删除失败（可能有依赖）"
        fi
    done
    
    # 清理无用镜像
    echo "  🧽 清理无标签镜像..."
    docker image prune -f >/dev/null 2>&1
    
    echo "✅ 镜像清理完成"
else
    echo "✅ 镜像数量正常（${IMAGE_COUNT}/${MAX_IMAGES}）"
fi

# 8. 显示最终状态
echo ""
echo "📊 部署完成状态："
echo "=================="
docker-compose ps

echo ""
echo "💾 存储使用情况："
docker system df | head -4

echo ""
echo "🎉 部署成功！"
echo "============="
echo "• 前端应用: http://localhost/"
echo "• API文档: http://localhost:8000/api/schema/swagger-ui/"
echo "• 健康检查: http://localhost/health/"
echo ""
echo "📋 镜像版本管理规则已生效："
echo "• 最多保留 ${MAX_IMAGES} 个emotion-diary-app镜像版本"
echo "• 自动删除最老的超出版本"
echo "• 手动清理: ./scripts/docker-image-cleanup.sh" 