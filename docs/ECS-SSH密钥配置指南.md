# 🔐 阿里云ECS SSH公钥配置指南

## 📋 概述

本指南将详细说明如何在阿里云ECS服务器上配置SSH公钥，以便GitHub Actions CI/CD能够自动连接服务器进行部署。

## 🚀 方法一：使用一键设置脚本生成密钥

### 1. 运行设置脚本
```bash
# 在本地项目目录运行
./scripts/setup-github-cicd.sh
```

脚本会自动生成SSH密钥对并显示公钥内容。

### 2. 复制公钥内容
脚本运行后会显示类似以下内容：
```
请将以下公钥添加到你的阿里云ECS服务器:
----------------------------------------
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxxxxx... github-actions@emotion-diary
----------------------------------------
```

## 🚀 方法二：手动生成SSH密钥

### 1. 在本地生成SSH密钥对
```bash
# 生成专用于部署的SSH密钥
ssh-keygen -t rsa -b 4096 -C "github-actions@emotion-diary" -f ~/.ssh/emotion-diary-deploy

# 查看生成的公钥
cat ~/.ssh/emotion-diary-deploy.pub
```

### 2. 复制公钥内容
复制输出的完整公钥内容，格式类似：
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxxxxx... github-actions@emotion-diary
```

## 🔧 在ECS服务器上配置公钥

### 方法A：通过SSH连接配置（推荐）

#### 1. 连接到ECS服务器
```bash
# 使用密码登录ECS服务器
ssh root@your-server-ip

# 或者使用阿里云控制台的远程连接功能
```

#### 2. 创建.ssh目录（如果不存在）
```bash
# 创建.ssh目录
mkdir -p ~/.ssh

# 设置正确的权限
chmod 700 ~/.ssh
```

#### 3. 添加公钥到authorized_keys文件
```bash
# 编辑authorized_keys文件
nano ~/.ssh/authorized_keys

# 或者使用echo命令直接添加（推荐）
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxxxxx... github-actions@emotion-diary" >> ~/.ssh/authorized_keys
```

#### 4. 设置文件权限
```bash
# 设置authorized_keys文件权限
chmod 600 ~/.ssh/authorized_keys

# 确保.ssh目录权限正确
chmod 700 ~/.ssh

# 确保home目录权限正确
chmod 755 ~
```

### 方法B：通过阿里云控制台配置

#### 1. 登录阿里云控制台
- 访问 [阿里云ECS控制台](https://ecs.console.aliyun.com/)
- 找到你的ECS实例

#### 2. 使用远程连接功能
- 点击实例右侧的"远程连接"
- 选择"VNC远程连接"或"Workbench远程连接"
- 输入root密码登录

#### 3. 执行配置命令
```bash
# 创建.ssh目录
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 添加公钥
echo "你的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## 🔍 验证SSH公钥配置

### 1. 在本地测试SSH连接
```bash
# 使用生成的私钥测试连接
ssh -i ~/.ssh/emotion-diary-deploy root@your-server-ip

# 如果连接成功，应该能直接登录而不需要密码
```

### 2. 测试命令执行
```bash
# 测试远程命令执行
ssh -i ~/.ssh/emotion-diary-deploy root@your-server-ip "echo 'SSH连接成功'"

# 测试服务状态检查
ssh -i ~/.ssh/emotion-diary-deploy root@your-server-ip "systemctl status nginx"
```

## 🚨 常见问题排除

### 问题1：权限被拒绝 (Permission denied)

**可能原因**：
- 文件权限设置不正确
- 公钥格式错误
- SELinux或防火墙阻止

**解决方案**：
```bash
# 检查并修复权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 755 ~

# 检查SELinux状态
getenforce

# 如果是Enforcing，临时禁用测试
setenforce 0
```

### 问题2：连接超时

**可能原因**：
- 安全组规则未开放22端口
- 服务器防火墙阻止SSH连接
- 网络连接问题

**解决方案**：
```bash
# 检查SSH服务状态
systemctl status sshd

# 检查防火墙状态
ufw status

# 检查端口监听
netstat -tlnp | grep :22
```

### 问题3：公钥格式错误

**正确的公钥格式**：
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxxxxx... github-actions@emotion-diary
```

**注意事项**：
- 必须是一行完整内容
- 不能有换行符
- 包含ssh-rsa前缀和注释部分

### 问题4：多个公钥管理

如果需要添加多个公钥：
```bash
# 每个公钥占一行
cat ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxxxxx... github-actions@emotion-diary
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDyyyyy... another-key@example.com
```

## 🔒 安全最佳实践

### 1. 禁用密码登录（可选）
```bash
# 编辑SSH配置
sudo nano /etc/ssh/sshd_config

# 修改以下配置
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# 重启SSH服务
sudo systemctl restart sshd
```

### 2. 限制SSH访问
```bash
# 只允许特定用户SSH登录
echo "AllowUsers root deploy-user" >> /etc/ssh/sshd_config

# 禁止root用户登录（生产环境推荐）
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
```

### 3. 配置防火墙
```bash
# 使用ufw配置防火墙
ufw allow ssh
ufw enable

# 或者使用iptables
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

## 📝 配置检查清单

### SSH公钥配置完成检查
- [ ] SSH密钥对已生成
- [ ] 公钥已添加到服务器~/.ssh/authorized_keys
- [ ] 文件权限设置正确（700/.ssh, 600/authorized_keys）
- [ ] 本地SSH连接测试成功
- [ ] 远程命令执行测试成功

### GitHub Actions配置检查
- [ ] SSH_PRIVATE_KEY已添加到GitHub Secrets
- [ ] SERVER_HOST已配置为ECS公网IP
- [ ] SERVER_USER已配置为root或部署用户
- [ ] 其他必需的Secrets已配置

## 🚀 快速配置命令

如果你想快速配置，可以使用以下一键命令：

```bash
# 在ECS服务器上执行（替换为你的实际公钥）
mkdir -p ~/.ssh && \
chmod 700 ~/.ssh && \
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxxxxx... github-actions@emotion-diary" >> ~/.ssh/authorized_keys && \
chmod 600 ~/.ssh/authorized_keys && \
echo "SSH公钥配置完成"
```

## 📞 获取帮助

如果配置过程中遇到问题：

1. **检查日志**：
   ```bash
   # SSH连接日志
   tail -f /var/log/auth.log
   
   # SSH服务日志
   journalctl -u sshd -f
   ```

2. **详细调试**：
   ```bash
   # 使用详细模式连接
   ssh -v -i ~/.ssh/emotion-diary-deploy root@your-server-ip
   ```

3. **验证配置**：
   ```bash
   # 检查SSH配置
   sshd -T | grep -i auth
   ```

配置完成后，你就可以使用GitHub Actions进行自动化部署了！ 