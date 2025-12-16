# 云服务器部署指南

## ⚠️ 安全警告

**你的服务器凭据已在对话中暴露，部署完成后请立即执行：**

```bash
# 登录服务器后立即修改密码
passwd

# 输入新密码（两次）
# 建议使用强密码：大小写字母+数字+特殊字符，至少12位
```

---

## 🚀 一键部署

### 方法1：直接执行（推荐）

```bash
# 1. SSH登录到服务器
ssh root@47.115.213.95
# 输入密码: shanzhiqiang

# 2. 下载并执行部署脚本
curl -fsSL https://raw.githubusercontent.com/szqshan/bayut/claude/setup-bayut-api-request-krtbA/deploy/setup_server.sh | bash

# 3. 等待完成（大约5-10分钟）
```

### 方法2：手动执行

```bash
# 1. 登录服务器
ssh root@47.115.213.95

# 2. 下载脚本
wget https://raw.githubusercontent.com/szqshan/bayut/claude/setup-bayut-api-request-krtbA/deploy/setup_server.sh

# 3. 添加执行权限
chmod +x setup_server.sh

# 4. 执行脚本
./setup_server.sh

# 或者使用bash执行
bash setup_server.sh
```

### 方法3：Git方式

```bash
# 1. 登录服务器
ssh root@47.115.213.95

# 2. 克隆仓库
cd /opt
git clone https://github.com/szqshan/bayut.git

# 3. 执行脚本
cd bayut/deploy
chmod +x setup_server.sh
./setup_server.sh
```

---

## 📦 脚本功能

自动化部署脚本会完成以下所有操作：

### 1. 系统准备
- ✅ 更新系统包
- ✅ 安装基础工具（git, curl, vim等）

### 2. Docker安装
- ✅ 安装Docker Engine
- ✅ 安装Docker Compose
- ✅ 配置Docker开机自启

### 3. Python环境
- ✅ 安装Python 3.11
- ✅ 创建虚拟环境
- ✅ 安装项目依赖

### 4. 项目部署
- ✅ 克隆GitHub代码
- ✅ 启动PostgreSQL和Redis容器
- ✅ 执行数据库迁移
- ✅ 配置systemd服务（开机自启）

### 5. Web服务器
- ✅ 安装Nginx
- ✅ 配置反向代理
- ✅ 配置防火墙规则

---

## 🔧 部署后配置

### 1. 配置API密钥

```bash
# 编辑环境变量文件
nano /opt/bayut/backend/.env

# 确保以下变量正确设置：
BAYUT_API_KEY=11866b605emsh4cd66daa3f619a6p116389jsnc7a9076d4000
BAYUT_API_HOST=bayut-api1.p.rapidapi.com
DATABASE_URL=postgresql://bayut:bayut123@localhost:5432/bayut_db
REDIS_URL=redis://localhost:6379/0

# 保存退出（Ctrl+X, Y, Enter）

# 重启服务使配置生效
systemctl restart bayut-api
```

### 2. 修改root密码（重要！）

```bash
passwd
# 输入新密码两次
```

### 3. 创建新的管理员账户（推荐）

```bash
# 创建新用户
adduser bayut
# 输入密码

# 添加sudo权限
usermod -aG sudo bayut

# 切换到新用户
su - bayut

# 以后用新用户登录
ssh bayut@47.115.213.95
```

---

## ✅ 验证部署

### 1. 检查服务状态

```bash
# 检查Docker容器
docker compose ps

# 应该看到postgres和redis都是Up状态

# 检查API服务
systemctl status bayut-api

# 应该看到active (running)

# 检查Nginx
systemctl status nginx

# 应该看到active (running)
```

### 2. 测试API访问

```bash
# 测试健康检查
curl http://47.115.213.95/health

# 应该返回：
# {"status":"ok","version":"1.0.0","app_name":"Bayut Property Platform"}

# 测试通过Nginx访问
curl http://47.115.213.95/

# 测试直接访问API
curl http://47.115.213.95:8000/health
```

### 3. 浏览器访问

打开浏览器访问：
- **API文档**: http://47.115.213.95:8000/docs
- **API根路径**: http://47.115.213.95/
- **健康检查**: http://47.115.213.95/health

---

## 📊 服务管理命令

### API服务

```bash
# 查看状态
systemctl status bayut-api

# 启动服务
systemctl start bayut-api

# 停止服务
systemctl stop bayut-api

# 重启服务
systemctl restart bayut-api

# 查看日志（实时）
journalctl -u bayut-api -f

# 查看最近100行日志
journalctl -u bayut-api -n 100
```

### Docker容器

```bash
# 进入项目目录
cd /opt/bayut

# 查看容器状态
docker compose ps

# 查看日志
docker compose logs -f

# 重启容器
docker compose restart

# 停止容器
docker compose down

# 启动容器
docker compose up -d postgres redis
```

### Nginx

```bash
# 查看状态
systemctl status nginx

# 重启
systemctl restart nginx

# 测试配置
nginx -t

# 查看访问日志
tail -f /var/log/nginx/access.log

# 查看错误日志
tail -f /var/log/nginx/error.log
```

---

## 🔍 故障排查

### 问题1：API无法访问

```bash
# 1. 检查服务是否运行
systemctl status bayut-api

# 2. 查看日志
journalctl -u bayut-api -n 50

# 3. 检查端口占用
netstat -tlnp | grep 8000

# 4. 手动启动测试
cd /opt/bayut/backend
source venv/bin/activate
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

### 问题2：数据库连接失败

```bash
# 1. 检查Docker容器
docker compose ps

# 2. 查看PostgreSQL日志
docker compose logs postgres

# 3. 测试数据库连接
docker compose exec postgres psql -U bayut -d bayut_db -c "SELECT 1;"

# 4. 重启数据库
docker compose restart postgres
```

### 问题3：防火墙阻止访问

```bash
# 检查防火墙状态
ufw status

# 允许端口
ufw allow 8000/tcp
ufw allow 80/tcp

# 检查阿里云安全组
# 登录阿里云控制台 -> ECS -> 安全组
# 确保开放了8000和80端口
```

### 问题4：环境变量未生效

```bash
# 1. 检查.env文件
cat /opt/bayut/backend/.env

# 2. 确保API密钥正确
grep BAYUT_API_KEY /opt/bayut/backend/.env

# 3. 重启服务
systemctl restart bayut-api
```

---

## 📝 更新代码

```bash
# 1. 进入项目目录
cd /opt/bayut

# 2. 拉取最新代码
git pull

# 3. 更新依赖（如果有变化）
cd backend
source venv/bin/activate
pip install -r requirements.txt

# 4. 执行新的迁移（如果有）
alembic upgrade head

# 5. 重启服务
systemctl restart bayut-api
```

---

## 🔒 安全加固建议

### 1. 禁用root SSH登录

```bash
# 编辑SSH配置
nano /etc/ssh/sshd_config

# 修改以下行：
PermitRootLogin no
PasswordAuthentication no  # 启用密钥登录后

# 重启SSH服务
systemctl restart sshd
```

### 2. 配置SSH密钥登录

```bash
# 在本地生成密钥
ssh-keygen -t ed25519

# 复制公钥到服务器
ssh-copy-id bayut@47.115.213.95
```

### 3. 安装fail2ban防止暴力破解

```bash
apt-get install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban
```

### 4. 启用自动安全更新

```bash
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

---

## 📈 监控和日志

### 系统资源监控

```bash
# 实时监控
htop

# 磁盘使用
df -h

# 内存使用
free -h

# 检查Docker资源使用
docker stats
```

### 日志位置

- **API日志**: `journalctl -u bayut-api`
- **Nginx访问日志**: `/var/log/nginx/access.log`
- **Nginx错误日志**: `/var/log/nginx/error.log`
- **PostgreSQL日志**: `docker compose logs postgres`
- **Redis日志**: `docker compose logs redis`

---

## 🎯 下一步

部署完成后：

1. ✅ 验证所有服务运行正常
2. ✅ 修改root密码
3. ✅ 配置API密钥
4. ✅ 测试API访问
5. 🚀 开始Phase 2开发

---

## 📞 获取帮助

如果遇到问题：

1. 查看日志：`journalctl -u bayut-api -f`
2. 检查服务状态：`systemctl status bayut-api`
3. 查看Docker日志：`docker compose logs -f`

---

**部署脚本地址**: https://github.com/szqshan/bayut/blob/claude/setup-bayut-api-request-krtbA/deploy/setup_server.sh
