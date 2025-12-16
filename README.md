# Bayut房产数据智能平台

基于Bayut API构建的房产数据采集、监控和智能分析平台。

## 项目概述

本项目旨在打造一个全面的房产数据服务平台，提供：

- 房产数据全量采集和实时更新
- 价格监控和变化提醒
- 智能房产推荐和分析
- 市场趋势洞察
- AI驱动的房产顾问服务

## 快速开始

### 前置要求

- Python 3.11+
- Node.js 18+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+

### 环境搭建

1. 克隆仓库
```bash
git clone https://github.com/your-org/bayut-platform.git
cd bayut-platform
```

2. 配置环境变量
```bash
# 后端
cp backend/.env.example backend/.env
# 编辑 backend/.env 填入你的配置

# 前端
cp frontend/.env.example frontend/.env.local
# 编辑 frontend/.env.local 填入你的配置
```

3. 使用Docker Compose启动服务
```bash
docker-compose up -d
```

4. 访问应用
- 前端: http://localhost:3000
- 后端API: http://localhost:8000
- API文档: http://localhost:8000/docs

### 手动安装（不使用Docker）

#### 后端

```bash
cd backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt

# 数据库迁移
alembic upgrade head

# 启动开发服务器
uvicorn src.main:app --reload

# 启动Celery Worker（新终端）
celery -A src.workers.celery_app worker --loglevel=info

# 启动Celery Beat（新终端）
celery -A src.workers.celery_app beat --loglevel=info
```

#### 前端

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

## 核心功能

### 1. 数据采集

- 自动采集Bayut平台房源数据
- 支持全量和增量采集
- 智能去重和数据清洗
- 速率限制和错误重试

### 2. 实时监控

- 价格变化监控
- 新房源上架提醒
- 自定义监控规则
- 多渠道通知（邮件、短信、推送）

### 3. 智能分析

- 市场趋势分析
- 价格预测模型
- 区域热力图
- 投资建议

### 4. AI房产顾问

- 智能问答系统
- 个性化推荐
- 投资咨询
- 市场洞察报告

## 技术栈

### 后端
- FastAPI - 现代高性能Web框架
- SQLAlchemy - ORM
- PostgreSQL - 主数据库
- Redis - 缓存和消息队列
- Celery - 分布式任务队列
- Elasticsearch - 全文搜索

### 前端
- Next.js 14 - React框架
- TypeScript - 类型安全
- TailwindCSS - 样式框架
- React Query - 状态管理
- Mapbox - 地图服务

### DevOps
- Docker - 容器化
- Kubernetes - 容器编排
- GitHub Actions - CI/CD
- Prometheus + Grafana - 监控

## 项目结构

详见 [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)

## 技术架构

完整技术架构文档请查看 [TECHNICAL_ARCHITECTURE.md](./TECHNICAL_ARCHITECTURE.md)

## API文档

### Bayut API集成

详细的API集成指南请参考 [BAYUT_API_GUIDE.md](./BAYUT_API_GUIDE.md)

### 平台API

启动后端服务后，访问：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 开发指南

### 数据库迁移

```bash
# 创建新迁移
alembic revision --autogenerate -m "描述"

# 执行迁移
alembic upgrade head

# 回滚
alembic downgrade -1
```

### 运行测试

```bash
# 后端测试
cd backend
pytest

# 前端测试
cd frontend
npm test
```

### 代码规范

```bash
# 后端代码格式化
black backend/src/
flake8 backend/src/

# 前端代码格式化
npm run lint
npm run format
```

## 部署

### 使用Docker

```bash
# 构建镜像
docker-compose -f docker-compose.prod.yml build

# 启动服务
docker-compose -f docker-compose.prod.yml up -d
```

### 使用Kubernetes

```bash
kubectl apply -f infrastructure/kubernetes/
```

详细部署指南请参考 [docs/deployment/README.md](./docs/deployment/README.md)

## 环境变量

### 必需配置

```bash
# Bayut API
BAYUT_API_KEY=your_rapidapi_key_here
BAYUT_API_HOST=bayut-api1.p.rapidapi.com

# 数据库
DATABASE_URL=postgresql://user:password@localhost:5432/bayut_db

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT密钥
JWT_SECRET_KEY=your_secret_key_here
```

完整的环境变量说明请参考 `.env.example`

## 监控和日志

### 应用监控
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001

### 日志查看

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f celery-worker
```

## 贡献指南

我们欢迎任何形式的贡献！

### 提交流程

1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

### 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具链相关

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 支持和联系

- 问题反馈: [GitHub Issues](https://github.com/your-org/bayut-platform/issues)
- 功能建议: [GitHub Discussions](https://github.com/your-org/bayut-platform/discussions)
- 邮件: support@bayut-platform.com

## 致谢

- [Bayut API](https://rapidapi.com/BayutAPI/api/bayut-api1) - 数据来源
- [FastAPI](https://fastapi.tiangolo.com/) - 后端框架
- [Next.js](https://nextjs.org/) - 前端框架

## 路线图

- [x] 基础数据采集系统
- [x] 用户认证和授权
- [x] 房源搜索和筛选
- [ ] 实时价格监控
- [ ] 移动端应用
- [ ] AI智能顾问
- [ ] 市场分析报告
- [ ] 开放API平台

---

**开始时间**: 2025-12-16
**当前版本**: v0.1.0
**状态**: 开发中
