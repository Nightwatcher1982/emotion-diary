#!/bin/bash

# Docker镜像版本管理脚本
# 保持最多3个emotion-diary-app镜像版本，删除最老的

echo "🧹 Docker镜像版本管理 - 最多保留3个版本"
echo "============================================"

IMAGE_NAME="emotion-diary-app"
MAX_IMAGES=3

# 获取所有emotion-diary-app镜像，按创建时间排序（最新的在前）
echo "📋 当前${IMAGE_NAME}镜像列表："
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}" | grep "${IMAGE_NAME}\|REPOSITORY"

# 获取镜像ID列表（按创建时间降序，最新的在前）
IMAGE_IDS=$(docker images ${IMAGE_NAME} --format "{{.ID}}" | head -20)
IMAGE_COUNT=$(echo "$IMAGE_IDS" | wc -l | tr -d ' ')

echo ""
echo "📊 统计信息："
echo "• 当前镜像数量: ${IMAGE_COUNT}"
echo "• 最大保留数量: ${MAX_IMAGES}"

if [ "$IMAGE_COUNT" -gt "$MAX_IMAGES" ]; then
    # 需要删除的镜像数量
    DELETE_COUNT=$((IMAGE_COUNT - MAX_IMAGES))
    echo "• 需要删除: ${DELETE_COUNT} 个镜像"
    echo ""
    
    # 获取需要删除的镜像ID（最老的几个）
    IMAGES_TO_DELETE=$(echo "$IMAGE_IDS" | tail -n $DELETE_COUNT)
    
    echo "🗑️  准备删除以下镜像（最老的${DELETE_COUNT}个）："
    for img_id in $IMAGES_TO_DELETE; do
        # 获取镜像详细信息
        IMG_INFO=$(docker images --format "{{.Repository}}:{{.Tag}} ({{.ID}}) - {{.CreatedAt}}" | grep "$img_id")
        echo "  ❌ $IMG_INFO"
    done
    
    echo ""
    read -p "⚠️  确认删除这些镜像吗？(y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 开始删除镜像..."
        for img_id in $IMAGES_TO_DELETE; do
            echo "  正在删除镜像 $img_id..."
            docker rmi $img_id --force 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "  ✅ 删除成功: $img_id"
            else
                echo "  ⚠️  删除失败: $img_id (可能正在使用中)"
            fi
        done
        
        echo ""
        echo "🧹 清理完成！当前镜像列表："
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}" | grep "${IMAGE_NAME}\|REPOSITORY"
        
        # 清理dangling镜像
        echo ""
        echo "🧽 清理无标签镜像..."
        docker image prune -f
        
    else
        echo "❌ 取消删除操作"
    fi
    
else
    echo "• ✅ 镜像数量未超过限制，无需清理"
fi

echo ""
echo "💾 Docker存储使用情况："
docker system df

echo ""
echo "📋 使用说明："
echo "=============="
echo "• 此脚本会保留最新的3个${IMAGE_NAME}镜像"
echo "• 自动删除超出数量的最老镜像"
echo "• 可以在docker-compose构建后自动调用"
echo "• 运行: ./scripts/docker-image-cleanup.sh" 