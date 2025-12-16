# 部署脚本目录

这个目录包含了将Bayut平台部署到云服务器的自动化脚本和文档。

## 📁 文件说明

- **setup_server.sh** - 自动化部署脚本（核心文件）
- **QUICKSTART.md** - 5分钟快速开始指南
- **DEPLOYMENT_GUIDE.md** - 完整部署文档
- **README.md** - 本文件

## 🚀 快速开始

### 一键部署

```bash
# SSH登录到服务器
ssh root@47.115.213.95

# 执行自动部署
curl -fsSL https://raw.githubusercontent.com/szqshan/bayut/claude/setup-bayut-api-request-krtbA/deploy/setup_server.sh | bash
```

详细步骤请查看：**QUICKSTART.md**

## 📚 文档导航

### 新手用户
1. 阅读 **QUICKSTART.md**
2. 执行一键部署
3. 参考 **DEPLOYMENT_GUIDE.md** 的"验证部署"章节

### 有经验的用户
- 直接执行 `setup_server.sh`
- 遇到问题查看 **DEPLOYMENT_GUIDE.md** 的"故障排查"章节

## ⚠️ 安全提醒

部署完成后请立即：
1. 修改root密码：`passwd`
2. 创建新管理员账户
3. 配置SSH密钥登录
4. 禁用root SSH登录

详见：**DEPLOYMENT_GUIDE.md** 的"安全加固建议"章节

## 🛠️ 脚本功能

`setup_server.sh` 会自动完成：

- ✅ 安装Docker和Docker Compose
- ✅ 安装Python 3.11和依赖
- ✅ 克隆项目代码
- ✅ 启动PostgreSQL和Redis
- ✅ 执行数据库迁移
- ✅ 配置systemd服务（开机自启）
- ✅ 安装和配置Nginx
- ✅ 配置防火墙

## 🔧 手动执行

如果不想使用一键部署：

```bash
# 下载脚本
wget https://raw.githubusercontent.com/szqshan/bayut/claude/setup-bayut-api-request-krtbA/deploy/setup_server.sh

# 查看脚本内容（可选，建议）
cat setup_server.sh

# 添加执行权限
chmod +x setup_server.sh

# 执行
./setup_server.sh
```

## 📝 部署后检查

```bash
# 检查服务状态
systemctl status bayut-api

# 检查Docker容器
docker compose ps

# 测试API
curl http://localhost:8000/health

# 查看日志
journalctl -u bayut-api -f
```

## 🆘 故障排查

遇到问题请查看：
- **DEPLOYMENT_GUIDE.md** 的"故障排查"章节
- API日志：`journalctl -u bayut-api -n 100`
- Docker日志：`docker compose logs -f`

## 📊 支持的系统

- ✅ Ubuntu 20.04 LTS
- ✅ Ubuntu 22.04 LTS
- ✅ Debian 11/12
- ⚠️ 其他Linux发行版可能需要修改脚本

## 🔄 更新部署

```bash
cd /opt/bayut
git pull
systemctl restart bayut-api
```

详细更新流程见：**DEPLOYMENT_GUIDE.md** 的"更新代码"章节

---

**当前服务器**: 47.115.213.95
**项目目录**: /opt/bayut
**服务名称**: bayut-api
