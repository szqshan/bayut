# 🚀 快速开始 - 5分钟部署到云服务器

## 步骤1：登录服务器

```bash
ssh root@47.115.213.95
# 密码: shanzhiqiang
```

## 步骤2：执行一键部署

```bash
curl -fsSL https://raw.githubusercontent.com/szqshan/bayut/claude/setup-bayut-api-request-krtbA/deploy/setup_server.sh | bash
```

等待5-10分钟，脚本会自动完成所有安装和配置。

## 步骤3：配置API密钥

```bash
nano /opt/bayut/backend/.env
```

确保这一行正确：
```
BAYUT_API_KEY=11866b605emsh4cd66daa3f619a6p116389jsnc7a9076d4000
```

保存退出（Ctrl+X, Y, Enter）

```bash
# 重启服务
systemctl restart bayut-api
```

## 步骤4：测试

浏览器打开：**http://47.115.213.95:8000/docs**

或命令行测试：
```bash
curl http://47.115.213.95/health
```

## 步骤5：修改密码（重要！）

```bash
passwd
# 输入新密码
```

## 完成！✅

现在你可以：
- 访问API文档：http://47.115.213.95:8000/docs
- 查看日志：`journalctl -u bayut-api -f`
- 开始Phase 2开发

---

详细说明请查看：**DEPLOYMENT_GUIDE.md**
