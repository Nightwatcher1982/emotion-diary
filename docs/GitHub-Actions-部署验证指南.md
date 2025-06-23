# GitHub Actions 自动部署验证指南

## 🎉 GitHub Secrets配置完成！

你已经成功配置了所有必需的GitHub Secrets：
- ✅ **SSH_PRIVATE_KEY** - SSH私钥
- ✅ **SERVER_HOST** - 阿里云ECS公网IP
- ✅ **SERVER_USER** - ECS服务器用户名
- ✅ **QIANFAN_API_KEY** - 百度千帆API密钥

## 🚀 触发自动部署

### 方法1：推送代码（推荐）
```bash
# 创建一个小的测试更改
echo "# 部署测试 - $(date)" >> README.md

# 提交并推送
git add .
git commit -m "测试自动部署功能"
git push origin main
```

### 方法2：直接在GitHub网页端操作
1. 访问你的仓库：https://github.com/Nightwatcher1982/emotion-diary
2. 点击任意文件进行编辑
3. 做一个小改动（比如在README中添加一行）
4. 点击 "Commit changes"
5. 选择 "Commit directly to the main branch"

## 📊 监控部署过程

### 1. 查看GitHub Actions状态
访问：https://github.com/Nightwatcher1982/emotion-diary/actions

你应该能看到：
- 🟡 **正在运行** - 黄色圆圈表示正在执行
- 🟢 **成功** - 绿色勾号表示部署成功
- 🔴 **失败** - 红色叉号表示需要检查

### 2. 部署流程监控
部署过程包含以下步骤：

#### Stage 1: build-frontend ✅
- 安装Node.js依赖
- 构建微信小程序版本
- 上传构建产物

#### Stage 2: deploy 🔧
- **检查Secrets配置** - 验证所有必需的secrets
- **SSH连接测试** - 测试到ECS服务器的连接
- **代码部署** - 克隆/更新代码到服务器
- **服务启动** - 启动Django后端服务

#### Stage 3: security-scan ✅
- 仅在Pull Request时运行
- 代码安全检查

## 🔍 部署结果验证

### 1. GitHub Actions日志检查
点击具体的workflow run，查看详细日志：

**成功的标志**：
```
✅ 所有必要的Secrets已配置
✅ 服务器已添加到known hosts  
✅ SSH连接成功
📂 检查项目目录...
📁 创建项目目录: /var/www/emotion-diary
📥 进入项目目录...
🔄 初始化或更新Git仓库...
✅ 部署完成！
✅ 部署成功完成！
```

**失败的可能原因**：
- SSH连接失败 → 检查SERVER_HOST和防火墙设置
- 权限被拒绝 → 检查SERVER_USER权限
- Git克隆失败 → 检查网络连接

### 2. 服务器状态检查

SSH登录到你的ECS服务器验证：

```bash
# 检查项目目录
ls -la /var/www/emotion-diary

# 检查Git仓库状态
cd /var/www/emotion-diary
git status
git log --oneline -5

# 检查最新提交
git show --stat
```

### 3. 服务运行状态检查

```bash
# 检查Python环境
cd /var/www/emotion-diary
python --version

# 检查Django项目
python manage.py check

# 如果配置了服务，检查服务状态
sudo systemctl status emotion-diary
```

## 🐛 常见问题排除

### 问题1: SSH连接失败
```
❌ SSH连接测试失败
```
**解决方案**：
- 检查SERVER_HOST是否为正确的公网IP
- 确认ECS安全组开放22端口
- 验证SSH密钥是否正确配置

### 问题2: 权限被拒绝
```
❌ Permission denied
```
**解决方案**：
- 检查SERVER_USER是否正确
- 确认用户有sudo权限
- 检查SSH密钥权限设置

### 问题3: Git操作失败
```
❌ fatal: could not read from remote repository
```
**解决方案**：
- 检查服务器网络连接
- 确认Git已安装
- 检查仓库URL是否正确

### 问题4: 目录权限问题
```
❌ mkdir: cannot create directory
```
**解决方案**：
- 确认用户有创建目录权限
- 检查/var/www目录权限
- 可能需要sudo权限

## 📈 部署成功后的下一步

### 1. 配置Web服务器（可选）
如果需要通过域名访问，可以配置Nginx：

```bash
# 安装Nginx
sudo apt update && sudo apt install nginx -y

# 配置反向代理
sudo nano /etc/nginx/sites-available/emotion-diary
```

### 2. 配置SSL证书（可选）
```bash
# 安装Let's Encrypt
sudo apt install certbot python3-certbot-nginx -y

# 获取SSL证书
sudo certbot --nginx -d yourdomain.com
```

### 3. 设置定期部署
现在每次推送到main分支都会自动部署！

## 🎯 验证清单

部署成功后，请检查：

- [ ] GitHub Actions显示绿色✅状态
- [ ] 服务器上有/var/www/emotion-diary目录
- [ ] 项目代码已更新到最新版本
- [ ] 没有明显的错误日志
- [ ] 可以考虑配置Web服务器进行访问

## 🎉 恭喜！

如果以上步骤都成功，你的AI情绪日记项目现在已经支持：

- ✅ **自动化CI/CD部署**
- ✅ **前端构建和打包**  
- ✅ **代码自动同步到服务器**
- ✅ **安全的SSH密钥认证**
- ✅ **详细的部署日志和错误处理**

现在你可以专注于开发功能，每次推送代码都会自动部署到服务器！🚀 