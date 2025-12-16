# 开发环境搭建指南

## 方案选择

### 方案1：本地Docker环境（推荐）⭐

#### Windows系统
1. **下载Docker Desktop**
   - 访问：https://www.docker.com/products/docker-desktop/
   - 下载Windows版本
   - 双击安装，重启电脑

2. **验证安装**
   ```powershell
   docker --version
   docker-compose --version
   ```

3. **启动Docker Desktop**
   - 打开Docker Desktop应用
   - 等待Docker引擎启动（右下角图标变绿）

#### macOS系统
1. **下载Docker Desktop**
   - 访问：https://www.docker.com/products/docker-desktop/
   - 选择Mac芯片类型（Intel或Apple Silicon）
   - 安装.dmg文件

2. **验证安装**
   ```bash
   docker --version
   docker-compose --version
   ```

#### Linux系统
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 重新登录后验证
docker --version
docker compose version
```

#### 克隆项目并启动
```bash
# 克隆GitHub仓库
git clone https://github.com/szqshan/bayut.git
cd bayut

# 启动数据库服务
docker compose up -d postgres redis

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f postgres
```

---

### 方案2：使用云端PostgreSQL和Redis（快速开始）🚀

不需要本地Docker，使用免费云服务：

#### 2.1 PostgreSQL - 使用Supabase（免费）

1. **注册Supabase**
   - 访问：https://supabase.com
   - 免费注册账号

2. **创建项目**
   - 点击"New Project"
   - 记录以下信息：
     - Database URL
     - API URL
     - API Key

3. **获取连接字符串**
   ```
   格式：postgresql://postgres:[YOUR-PASSWORD]@[PROJECT-REF].supabase.co:5432/postgres
   ```

#### 2.2 Redis - 使用Upstash（免费）

1. **注册Upstash**
   - 访问：https://upstash.com
   - 免费注册

2. **创建Redis数据库**
   - 选择区域（选择离你最近的）
   - 复制连接URL

3. **获取连接字符串**
   ```
   格式：redis://default:[PASSWORD]@[HOST]:[PORT]
   ```

#### 2.3 更新配置

编辑 `backend/.env`:
```bash
# 使用云端数据库
DATABASE_URL=postgresql://postgres:your_password@xxx.supabase.co:5432/postgres
REDIS_URL=redis://default:your_password@xxx.upstash.io:6379

# Bayut API密钥（你已有的）
BAYUT_API_KEY=11866b605emsh4cd66daa3f619a6p116389jsnc7a9076d4000
BAYUT_API_HOST=bayut-api1.p.rapidapi.com
BAYUT_BASE_URL=https://bayut-api1.p.rapidapi.com
```

---

### 方案3：本地直接安装PostgreSQL和Redis（不推荐）

如果不想用Docker或云服务，可以直接安装：

#### Windows
```powershell
# 安装PostgreSQL
# 1. 下载：https://www.postgresql.org/download/windows/
# 2. 安装时记住密码
# 3. 创建数据库
psql -U postgres
CREATE DATABASE bayut_db;
CREATE USER bayut WITH PASSWORD 'bayut123';
GRANT ALL PRIVILEGES ON DATABASE bayut_db TO bayut;

# 安装Redis
# 1. 下载：https://github.com/microsoftarchive/redis/releases
# 2. 解压运行redis-server.exe
```

#### macOS
```bash
# 使用Homebrew安装
brew install postgresql@15
brew install redis

# 启动服务
brew services start postgresql@15
brew services start redis

# 创建数据库
psql postgres
CREATE DATABASE bayut_db;
CREATE USER bayut WITH PASSWORD 'bayut123';
GRANT ALL PRIVILEGES ON DATABASE bayut_db TO bayut;
```

#### Linux
```bash
# PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo -u postgres psql
CREATE DATABASE bayut_db;
CREATE USER bayut WITH PASSWORD 'bayut123';
GRANT ALL PRIVILEGES ON DATABASE bayut_db TO bayut;

# Redis
sudo apt install redis-server
sudo systemctl start redis
sudo systemctl enable redis
```

---

### 方案4：使用GitHub Codespaces（在线开发）☁️

完全在云端开发，不需要本地环境：

1. **在GitHub上打开仓库**
   - 访问：https://github.com/szqshan/bayut

2. **启动Codespace**
   - 点击绿色"Code"按钮
   - 选择"Codespaces"标签
   - 点击"Create codespace on main"

3. **在Codespace中工作**
   ```bash
   # Codespace已预装Docker
   docker compose up -d postgres redis

   # 正常开发
   cd backend
   pip install -r requirements.txt
   uvicorn src.main:app --reload
   ```

---

## 🎯 推荐路径（针对你的情况）

### 最快速方案：方案2（云端数据库）

**优点**：
- ✅ 不需要安装Docker
- ✅ 5分钟内可以开始开发
- ✅ 免费
- ✅ 可以随时随地访问

**步骤**：
1. 注册Supabase（PostgreSQL）
2. 注册Upstash（Redis）
3. 更新`.env`文件
4. 直接开始Phase 2开发

### 长期最佳：方案1（本地Docker）

**优点**：
- ✅ 完全控制环境
- ✅ 离线工作
- ✅ 速度快
- ✅ 行业标准

**时间**：
- 安装Docker：10-15分钟
- 启动项目：2分钟

---

## 📋 完整启动检查清单

### 使用方案1（本地Docker）

```bash
# 1. 克隆代码
git clone https://github.com/szqshan/bayut.git
cd bayut

# 2. 启动Docker Desktop（Windows/Mac）
# 确保右下角/顶部Docker图标显示"running"

# 3. 启动数据库
docker compose up -d postgres redis

# 4. 验证服务
docker compose ps
# 应该看到：
# bayut-postgres   Up   0.0.0.0:5432->5432/tcp
# bayut-redis      Up   0.0.0.0:6379->6379/tcp

# 5. 进入backend目录
cd backend

# 6. 创建Python虚拟环境
python -m venv venv

# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate

# 7. 安装依赖
pip install -r requirements.txt

# 8. 复制环境变量
cp .env.example .env
# 编辑.env，确认BAYUT_API_KEY正确

# 9. 运行数据库迁移
alembic revision --autogenerate -m "Initial schema"
alembic upgrade head

# 10. 启动应用
uvicorn src.main:app --reload

# 11. 测试
# 访问 http://localhost:8000/docs
curl http://localhost:8000/health
```

### 使用方案2（云端数据库）

```bash
# 1. 克隆代码
git clone https://github.com/szqshan/bayut.git
cd bayut/backend

# 2. 创建Python虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. 安装依赖
pip install -r requirements.txt

# 4. 配置云端数据库
cp .env.example .env
nano .env  # 或用任何编辑器

# 修改这些行：
# DATABASE_URL=postgresql://postgres:xxx@xxx.supabase.co:5432/postgres
# REDIS_URL=redis://default:xxx@xxx.upstash.io:6379

# 5. 运行迁移
alembic revision --autogenerate -m "Initial schema"
alembic upgrade head

# 6. 启动应用
uvicorn src.main:app --reload

# 7. 测试
curl http://localhost:8000/health
```

---

## 🚨 常见问题

### Q: Docker Desktop启动失败？
**A**: 确保启用了虚拟化
- **Windows**: 在BIOS中启用Hyper-V和虚拟化
- **Mac**: 无需额外配置

### Q: 端口被占用？
```bash
# 查看端口占用
# Windows
netstat -ano | findstr :5432
netstat -ano | findstr :6379

# Mac/Linux
lsof -i :5432
lsof -i :6379

# 修改docker-compose.yml中的端口映射
ports:
  - "5433:5432"  # 改用5433端口
```

### Q: Python虚拟环境激活失败？
```bash
# Windows PowerShell可能需要
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或使用CMD而不是PowerShell
```

### Q: pip install很慢？
```bash
# 使用国内镜像
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

---

## 🎓 学习资源

### Docker入门
- Docker官方文档：https://docs.docker.com/get-started/
- Docker Desktop使用指南：https://docs.docker.com/desktop/

### 云服务文档
- Supabase文档：https://supabase.com/docs
- Upstash文档：https://docs.upstash.com/redis

---

## 💡 建议

根据你的情况，我建议：

1. **如果你今天就想开始开发** → 使用方案2（云端数据库）
2. **如果你有30分钟时间** → 安装Docker Desktop（方案1）
3. **如果你想要最稳定的长期方案** → Docker + 本地开发

**最佳实践**：
- 开发阶段：方案2（云端，方便快捷）
- 测试阶段：方案1（本地Docker，完全控制）
- 生产环境：云服务器 + Docker

---

## 下一步

环境准备好后，查看：
- `PHASE1_COMPLETE.md` - 验收清单
- `MVP_PLAN.md` - Phase 2开发计划
- `BAYUT_API_GUIDE.md` - API集成指南

准备好后开始Phase 2！🚀
