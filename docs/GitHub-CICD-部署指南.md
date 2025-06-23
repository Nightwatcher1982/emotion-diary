# 🚀 GitHub CI/CD 自动化部署指南

## 📋 概述

本指南将帮助你使用GitHub Actions实现AI情绪日记项目的自动化CI/CD部署到阿里云ECS服务器。

## 🎯 CI/CD流程设计

```mermaid
graph TD
    A[代码推送到GitHub] --> B[触发GitHub Actions]
    B --> C[运行测试]
    B --> D[构建前端]
    C --> E{测试通过?}
    D --> E
    E -->|是| F[部署到服务器]
    E -->|否| G[部署失败通知]
    F --> H[健康检查]
    H --> I{服务正常?}
    I -->|是| J[部署成功]
    I -->|否| K[自动回滚]
```

## 🔧 前置准备

### 1. GitHub仓库设置

首先将你的项目推送到GitHub：

```bash
# 初始化Git仓库
git init
git add .
git commit -m "Initial commit: AI情绪日记项目"

# 添加远程仓库
git remote add origin https://github.com/your-username/emotion-diary.git
git branch -M main
git push -u origin main
```

### 2. 阿里云ECS服务器准备

确保你的ECS服务器已经：
- ✅ 安装了基础环境（通过之前的部署脚本）
- ✅ 项目代码已部署到 `/var/www/emotion-diary`
- ✅ 服务正常运行
- ✅ 配置了SSH密钥认证

### 3. 生成SSH密钥对

在本地生成SSH密钥用于GitHub Actions连接服务器：

```bash
# 生成SSH密钥对
ssh-keygen -t rsa -b 4096 -C "github-actions@emotion-diary" -f ~/.ssh/emotion-diary-deploy

# 将公钥添加到服务器
ssh-copy-id -i ~/.ssh/emotion-diary-deploy.pub root@your-server-ip

# 测试连接
ssh -i ~/.ssh/emotion-diary-deploy root@your-server-ip
```

## 🔐 GitHub Secrets 配置

在GitHub仓库中配置以下Secrets：

### 进入仓库设置
1. 打开GitHub仓库页面
2. 点击 `Settings` 选项卡
3. 在左侧菜单中选择 `Secrets and variables` → `Actions`
4. 点击 `New repository secret`

### 必需的Secrets配置

| Secret名称 | 值 | 说明 |
|-----------|-----|------|
| `SSH_PRIVATE_KEY` | 私钥内容 | 用于连接服务器的SSH私钥 |
| `SERVER_HOST` | 服务器IP | 阿里云ECS实例的公网IP |
| `SERVER_USER` | root | 服务器用户名 |
| `QIANFAN_API_KEY` | API密钥 | 百度千帆API密钥 |

### 配置步骤详解

#### 1. SSH_PRIVATE_KEY
```bash
# 复制私钥内容
cat ~/.ssh/emotion-diary-deploy

# 复制完整输出内容，包括 -----BEGIN OPENSSH PRIVATE KEY----- 和 -----END OPENSSH PRIVATE KEY-----
```

#### 2. SERVER_HOST
```bash
# 你的阿里云ECS公网IP
123.456.789.012
```

#### 3. SERVER_USER
```bash
# 通常是root，或者你创建的部署用户
root
```

#### 4. QIANFAN_API_KEY
```bash
# 你的百度千帆API密钥
your-qianfan-api-key-here
```

## 🔄 CI/CD工作流程详解

### 工作流触发条件
- **推送到main分支**: 自动触发完整的CI/CD流程
- **Pull Request**: 只运行测试和安全扫描，不部署
- **手动触发**: 可在GitHub Actions页面手动运行

### 工作流阶段

#### 1. 测试阶段 (test)
```yaml
- 设置Python 3.11环境
- 启动MySQL和Redis服务
- 安装项目依赖
- 运行Django测试
- 执行代码质量检查
```

#### 2. 前端构建 (build-frontend)
```yaml
- 设置Node.js 18环境
- 安装前端依赖
- 构建微信小程序版本
- 上传构建产物
```

#### 3. 部署阶段 (deploy)
```yaml
- 下载构建产物
- 连接到服务器
- 备份当前版本
- 更新代码
- 安装依赖
- 数据库迁移
- 重启服务
- 健康检查
- 失败时自动回滚
```

#### 4. 安全扫描 (security-scan)
```yaml
- 依赖安全检查
- 代码安全扫描
- 漏洞报告生成
```

## 🚀 开始使用

### 1. 提交代码触发部署

```bash
# 修改代码
git add .
git commit -m "feat: 添加新功能"
git push origin main

# 推送后自动触发CI/CD流程
```

### 2. 查看部署状态

1. 打开GitHub仓库
2. 点击 `Actions` 选项卡
3. 查看最新的工作流运行状态

### 3. 部署成功验证

部署完成后，访问以下地址验证：
- 🌐 API文档: `https://your-domain.com/api/docs/`
- 🔧 管理后台: `https://your-domain.com/admin/`
- 📊 健康检查: `https://your-domain.com/health/`

## 🔧 高级配置

### 1. 环境分离

可以配置不同的环境（开发、测试、生产）：

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging
on:
  push:
    branches: [ develop ]

# .github/workflows/deploy-production.yml  
name: Deploy to Production
on:
  push:
    branches: [ main ]
```

### 2. 部署通知

添加部署状态通知（钉钉、微信、邮件）：

```yaml
- name: Notify deployment
  if: always()
  run: |
    curl -X POST "https://oapi.dingtalk.com/robot/send?access_token=${{ secrets.DINGTALK_TOKEN }}" \
         -H "Content-Type: application/json" \
         -d '{"msgtype": "text","text": {"content": "部署状态: ${{ job.status }}"}}'
```

### 3. 数据库备份

在部署前自动备份数据库：

```yaml
- name: Backup database
  run: |
    ssh $SERVER_USER@$SERVER_HOST "
      mysqldump -u emotion_user -p${{ secrets.DB_PASSWORD }} emotion_diary > /var/backups/emotion-diary/db_$(date +%Y%m%d_%H%M%S).sql
    "
```

### 4. 蓝绿部署

实现零停机部署：

```yaml
- name: Blue-Green deployment
  run: |
    # 启动新版本服务
    ssh $SERVER_USER@$SERVER_HOST "
      cd /var/www/emotion-diary-new
      # 部署新版本...
      # 健康检查通过后切换流量
      sudo nginx -s reload
    "
```

## 📊 监控和告警

### 1. 部署监控

```yaml
- name: Monitor deployment
  run: |
    # 检查服务状态
    ssh $SERVER_USER@$SERVER_HOST "
      systemctl is-active emotion-diary
      curl -f http://localhost:8000/health/
    "
```

### 2. 性能监控

```yaml
- name: Performance check
  run: |
    # API响应时间检查
    response_time=$(curl -o /dev/null -s -w '%{time_total}' https://your-domain.com/api/docs/)
    if (( $(echo "$response_time > 2.0" | bc -l) )); then
      echo "API响应时间过长: ${response_time}s"
      exit 1
    fi
```

## 🚨 故障排除

### 常见问题及解决方案

#### 1. SSH连接失败
```bash
# 检查SSH密钥格式
ssh-keygen -l -f ~/.ssh/emotion-diary-deploy

# 测试连接
ssh -i ~/.ssh/emotion-diary-deploy -v root@your-server-ip
```

#### 2. 部署权限问题
```bash
# 确保部署用户有sudo权限
sudo usermod -aG sudo deploy-user

# 配置免密码sudo
echo "deploy-user ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/deploy-user
```

#### 3. 服务启动失败
```bash
# 查看服务日志
journalctl -u emotion-diary -f

# 检查配置文件
python manage.py check --deploy
```

#### 4. 数据库迁移失败
```bash
# 手动执行迁移
python manage.py migrate --fake-initial

# 检查数据库连接
python manage.py dbshell
```

## 📈 最佳实践

### 1. 分支策略
```
main分支: 生产环境，稳定版本
develop分支: 开发环境，新功能集成
feature/*: 功能分支，单独功能开发
hotfix/*: 紧急修复分支
```

### 2. 提交规范
```bash
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
test: 测试相关
chore: 构建过程或辅助工具的变动
```

### 3. 版本管理
```bash
# 使用语义化版本
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 4. 回滚策略
```bash
# 快速回滚到上一个版本
git revert HEAD
git push origin main

# 或者回滚到指定版本
git reset --hard v1.0.0
git push --force origin main
```

## 📋 部署检查清单

### 部署前检查
- [ ] 代码已提交到GitHub
- [ ] 所有测试通过
- [ ] Secrets配置正确
- [ ] 服务器资源充足
- [ ] 数据库备份完成

### 部署后验证
- [ ] 服务状态正常
- [ ] API响应正常
- [ ] 数据库迁移成功
- [ ] 静态文件加载正常
- [ ] 日志无错误信息

## 🎯 总结

通过GitHub Actions CI/CD，你可以实现：

1. **自动化测试**: 每次代码提交自动运行测试
2. **自动化部署**: 推送到main分支自动部署到生产环境
3. **安全保障**: 自动安全扫描和漏洞检测
4. **快速回滚**: 部署失败自动回滚到上一版本
5. **状态监控**: 实时监控部署状态和服务健康

现在你可以专注于功能开发，部署工作完全自动化！

---

## 🔗 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [阿里云ECS文档](https://help.aliyun.com/product/25365.html)
- [Django部署指南](https://docs.djangoproject.com/en/4.2/howto/deployment/)
- [Nginx配置指南](https://nginx.org/en/docs/) 