# Bayut房产平台 - 项目结构指南

## 推荐的项目目录结构

### 单体仓库结构（Monorepo）

```
bayut-platform/
│
├── README.md                          # 项目总览
├── TECHNICAL_ARCHITECTURE.md          # 技术架构文档
├── docker-compose.yml                 # 本地开发环境
├── docker-compose.prod.yml            # 生产环境配置
├── .github/
│   └── workflows/                     # GitHub Actions CI/CD
│       ├── backend-ci.yml
│       ├── frontend-ci.yml
│       └── deploy.yml
│
├── backend/                           # 后端服务
│   ├── Dockerfile
│   ├── pyproject.toml                # Python依赖（Poetry）
│   ├── requirements.txt              # 或使用pip
│   ├── alembic/                      # 数据库迁移
│   │   ├── versions/
│   │   └── env.py
│   │
│   ├── src/
│   │   ├── __init__.py
│   │   ├── main.py                   # FastAPI应用入口
│   │   ├── config.py                 # 配置管理
│   │   │
│   │   ├── api/                      # API路由层
│   │   │   ├── __init__.py
│   │   │   ├── deps.py               # 依赖注入
│   │   │   └── v1/
│   │   │       ├── __init__.py
│   │   │       ├── properties.py     # 房产相关API
│   │   │       ├── agents.py         # 经纪人API
│   │   │       ├── users.py          # 用户API
│   │   │       ├── alerts.py         # 监控API
│   │   │       └── analytics.py      # 分析API
│   │   │
│   │   ├── core/                     # 核心功能
│   │   │   ├── __init__.py
│   │   │   ├── security.py           # 安全相关
│   │   │   ├── cache.py              # 缓存管理
│   │   │   └── rate_limit.py         # 限流器
│   │   │
│   │   ├── models/                   # 数据库模型
│   │   │   ├── __init__.py
│   │   │   ├── property.py
│   │   │   ├── agent.py
│   │   │   ├── user.py
│   │   │   ├── alert.py
│   │   │   └── price_history.py
│   │   │
│   │   ├── schemas/                  # Pydantic模式
│   │   │   ├── __init__.py
│   │   │   ├── property.py
│   │   │   ├── agent.py
│   │   │   ├── user.py
│   │   │   └── common.py
│   │   │
│   │   ├── services/                 # 业务逻辑层
│   │   │   ├── __init__.py
│   │   │   ├── bayut_client.py       # Bayut API客户端
│   │   │   ├── property_service.py
│   │   │   ├── alert_service.py
│   │   │   ├── notification_service.py
│   │   │   └── analytics_service.py
│   │   │
│   │   ├── workers/                  # 后台任务
│   │   │   ├── __init__.py
│   │   │   ├── celery_app.py         # Celery配置
│   │   │   ├── data_collector.py     # 数据采集任务
│   │   │   ├── monitor.py            # 监控任务
│   │   │   └── scheduler.py          # 定时任务
│   │   │
│   │   ├── db/                       # 数据库相关
│   │   │   ├── __init__.py
│   │   │   ├── base.py               # Base模型
│   │   │   ├── session.py            # 数据库会话
│   │   │   └── init_db.py            # 初始化脚本
│   │   │
│   │   ├── utils/                    # 工具函数
│   │   │   ├── __init__.py
│   │   │   ├── logger.py
│   │   │   ├── validators.py
│   │   │   └── helpers.py
│   │   │
│   │   └── ai/                       # AI功能
│   │       ├── __init__.py
│   │       ├── recommendation.py     # 推荐算法
│   │       ├── advisor.py            # 智能顾问
│   │       └── nlp.py                # 自然语言处理
│   │
│   ├── tests/                        # 测试
│   │   ├── __init__.py
│   │   ├── conftest.py               # pytest配置
│   │   ├── unit/
│   │   │   ├── test_services.py
│   │   │   └── test_models.py
│   │   ├── integration/
│   │   │   ├── test_api.py
│   │   │   └── test_workers.py
│   │   └── e2e/
│   │       └── test_flows.py
│   │
│   └── scripts/                      # 运维脚本
│       ├── seed_data.py              # 种子数据
│       ├── migrate.py                # 迁移辅助
│       └── backup.py                 # 备份脚本
│
├── frontend/                         # 前端应用
│   ├── Dockerfile
│   ├── package.json
│   ├── tsconfig.json
│   ├── next.config.js                # Next.js配置
│   │
│   ├── public/                       # 静态资源
│   │   ├── images/
│   │   └── icons/
│   │
│   ├── src/
│   │   ├── app/                      # Next.js App Router
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx              # 首页
│   │   │   ├── properties/
│   │   │   │   ├── page.tsx          # 房源列表
│   │   │   │   └── [id]/
│   │   │   │       └── page.tsx      # 房源详情
│   │   │   ├── search/
│   │   │   ├── dashboard/
│   │   │   └── api/                  # API路由
│   │   │
│   │   ├── components/               # React组件
│   │   │   ├── ui/                   # 基础UI组件
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Input.tsx
│   │   │   │   ├── Card.tsx
│   │   │   │   └── Modal.tsx
│   │   │   ├── property/             # 房产组件
│   │   │   │   ├── PropertyCard.tsx
│   │   │   │   ├── PropertyList.tsx
│   │   │   │   ├── PropertyFilter.tsx
│   │   │   │   └── PropertyMap.tsx
│   │   │   ├── layout/               # 布局组件
│   │   │   │   ├── Header.tsx
│   │   │   │   ├── Footer.tsx
│   │   │   │   └── Sidebar.tsx
│   │   │   └── dashboard/            # Dashboard组件
│   │   │
│   │   ├── lib/                      # 库和工具
│   │   │   ├── api.ts                # API客户端
│   │   │   ├── auth.ts               # 认证逻辑
│   │   │   └── utils.ts              # 工具函数
│   │   │
│   │   ├── hooks/                    # 自定义Hooks
│   │   │   ├── useProperties.ts
│   │   │   ├── useAuth.ts
│   │   │   └── useNotifications.ts
│   │   │
│   │   ├── types/                    # TypeScript类型
│   │   │   ├── property.ts
│   │   │   ├── user.ts
│   │   │   └── api.ts
│   │   │
│   │   └── styles/                   # 样式文件
│   │       ├── globals.css
│   │       └── themes.ts
│   │
│   └── tests/
│       ├── components/
│       └── integration/
│
├── mobile/                           # 移动端应用（可选）
│   ├── android/
│   ├── ios/
│   └── src/
│
├── admin/                            # 管理后台（可选独立项目）
│   ├── package.json
│   └── src/
│
├── infrastructure/                   # 基础设施代码
│   ├── terraform/                    # IaC配置
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── modules/
│   │
│   ├── kubernetes/                   # K8s配置
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   └── configmap.yaml
│   │
│   └── monitoring/                   # 监控配置
│       ├── prometheus/
│       ├── grafana/
│       └── elk/
│
├── docs/                             # 文档
│   ├── api/                          # API文档
│   │   └── openapi.yaml
│   ├── architecture/                 # 架构图
│   ├── deployment/                   # 部署指南
│   └── user-guide/                   # 用户指南
│
└── scripts/                          # 全局脚本
    ├── setup.sh                      # 环境搭建
    ├── deploy.sh                     # 部署脚本
    └── backup.sh                     # 备份脚本
```

---

## 核心文件说明

### 后端核心文件

#### `backend/src/main.py`
```python
应用入口文件，配置：
- FastAPI应用初始化
- CORS中间件
- 路由注册
- 异常处理器
- 启动/关闭事件
```

#### `backend/src/config.py`
```python
统一配置管理：
- 环境变量读取
- 数据库连接配置
- Redis配置
- API密钥管理
- 日志配置
```

#### `backend/src/services/bayut_client.py`
```python
Bayut API客户端核心：
- HTTP请求封装
- 速率限制实现
- 错误处理和重试
- 响应数据解析
- 缓存集成
```

#### `backend/src/workers/data_collector.py`
```python
数据采集任务：
- Celery任务定义
- 采集策略实现
- 数据清洗逻辑
- 数据库写入
- 错误日志记录
```

### 前端核心文件

#### `frontend/src/app/page.tsx`
```typescript
首页组件：
- 搜索表单
- 热门房源展示
- 统计信息
- 营销内容
```

#### `frontend/src/lib/api.ts`
```typescript
API客户端：
- Axios实例配置
- 请求拦截器（添加token）
- 响应拦截器（错误处理）
- 类型安全的API方法
```

#### `frontend/src/components/property/PropertyCard.tsx`
```typescript
房产卡片组件：
- 房产信息展示
- 图片轮播
- 收藏功能
- 快速操作按钮
```

---

## 环境配置文件

### `backend/.env`
```bash
# 数据库配置
DATABASE_URL=postgresql://user:pass@localhost:5432/bayut_db
DATABASE_POOL_SIZE=20

# Redis配置
REDIS_URL=redis://localhost:6379/0

# Bayut API
BAYUT_API_KEY=your_rapidapi_key
BAYUT_API_HOST=bayut-api1.p.rapidapi.com
BAYUT_RATE_LIMIT=100  # 每分钟请求数

# JWT配置
JWT_SECRET_KEY=your_secret_key_here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Celery
CELERY_BROKER_URL=redis://localhost:6379/1
CELERY_RESULT_BACKEND=redis://localhost:6379/2

# 日志
LOG_LEVEL=INFO
LOG_FILE=/var/log/bayut/app.log

# 通知服务
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_password

# AI服务
OPENAI_API_KEY=your_openai_key

# 监控
SENTRY_DSN=your_sentry_dsn
```

### `frontend/.env.local`
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_MAPBOX_TOKEN=your_mapbox_token
NEXT_PUBLIC_GA_ID=your_google_analytics_id
```

---

## Docker配置

### `docker-compose.yml`（开发环境）
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: bayut
      POSTGRES_PASSWORD: bayut123
      POSTGRES_DB: bayut_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./backend
    command: uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
    env_file:
      - ./backend/.env

  celery-worker:
    build: ./backend
    command: celery -A src.workers.celery_app worker --loglevel=info
    volumes:
      - ./backend:/app
    depends_on:
      - postgres
      - redis
    env_file:
      - ./backend/.env

  celery-beat:
    build: ./backend
    command: celery -A src.workers.celery_app beat --loglevel=info
    volumes:
      - ./backend:/app
    depends_on:
      - postgres
      - redis
    env_file:
      - ./backend/.env

  frontend:
    build: ./frontend
    command: npm run dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    depends_on:
      - backend
    env_file:
      - ./frontend/.env.local

volumes:
  postgres_data:
```

---

## 数据库迁移管理

### 使用Alembic

#### 初始化迁移
```bash
cd backend
alembic init alembic
```

#### 创建迁移
```bash
alembic revision --autogenerate -m "create properties table"
```

#### 执行迁移
```bash
alembic upgrade head
```

#### 回滚迁移
```bash
alembic downgrade -1
```

---

## 任务队列配置

### Celery任务类型

#### 定时任务（Celery Beat）
```python
from celery.schedules import crontab

beat_schedule = {
    'collect-new-properties': {
        'task': 'src.workers.data_collector.collect_properties',
        'schedule': crontab(minute='*/15'),  # 每15分钟
    },
    'monitor-price-changes': {
        'task': 'src.workers.monitor.check_price_changes',
        'schedule': crontab(minute='*/30'),  # 每30分钟
    },
    'generate-daily-report': {
        'task': 'src.workers.analytics.daily_report',
        'schedule': crontab(hour=8, minute=0),  # 每天早上8点
    },
}
```

#### 异步任务
```python
@celery_app.task(bind=True, max_retries=3)
def send_notification(self, user_id, message):
    try:
        # 发送通知逻辑
        pass
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)  # 60秒后重试
```

---

## API文档生成

FastAPI自动生成交互式API文档：

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`
- OpenAPI JSON: `http://localhost:8000/openapi.json`

---

## 测试策略

### 后端测试

#### 单元测试（pytest）
```bash
pytest tests/unit/ -v
```

#### 集成测试
```bash
pytest tests/integration/ -v
```

#### 测试覆盖率
```bash
pytest --cov=src --cov-report=html
```

### 前端测试

#### 单元测试（Jest + React Testing Library）
```bash
npm test
```

#### E2E测试（Playwright）
```bash
npm run test:e2e
```

---

## 代码质量工具

### 后端

#### 代码格式化（Black）
```bash
black src/
```

#### 代码检查（Flake8）
```bash
flake8 src/
```

#### 类型检查（mypy）
```bash
mypy src/
```

### 前端

#### 代码格式化（Prettier）
```bash
npm run format
```

#### 代码检查（ESLint）
```bash
npm run lint
```

#### 类型检查（TypeScript）
```bash
npm run type-check
```

---

## 部署流程

### 1. 构建镜像
```bash
docker build -t bayut-backend:latest ./backend
docker build -t bayut-frontend:latest ./frontend
```

### 2. 推送到仓库
```bash
docker push your-registry/bayut-backend:latest
docker push your-registry/bayut-frontend:latest
```

### 3. Kubernetes部署
```bash
kubectl apply -f infrastructure/kubernetes/
```

### 4. 数据库迁移
```bash
kubectl exec -it backend-pod -- alembic upgrade head
```

### 5. 健康检查
```bash
curl http://your-domain.com/health
```

---

## 监控和日志

### 应用监控

#### Prometheus指标暴露
```python
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()
Instrumentator().instrument(app).expose(app)
```

访问指标：`http://localhost:8000/metrics`

### 日志配置

#### 结构化日志（JSON格式）
```python
import logging
from pythonjsonlogger import jsonlogger

logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
```

---

## 最佳实践

### 1. 代码组织
- 遵循单一职责原则
- 使用依赖注入
- 避免循环依赖
- 保持模块解耦

### 2. API设计
- RESTful规范
- 统一错误响应格式
- API版本控制
- 请求/响应验证

### 3. 数据库
- 使用迁移管理schema变更
- 创建合适的索引
- 避免N+1查询
- 使用连接池

### 4. 安全
- 永远不要提交敏感信息
- 使用环境变量管理配置
- 实施HTTPS
- 输入验证和清理

### 5. 性能
- 实施多层缓存
- 异步处理长时间任务
- 数据库查询优化
- 前端代码分割

---

## Git工作流

### 分支策略

```
main              # 生产环境
  └── develop     # 开发环境
        ├── feature/property-search    # 功能分支
        ├── feature/price-monitoring
        └── hotfix/api-bug-fix         # 紧急修复
```

### 提交规范（Conventional Commits）

```bash
feat: 添加房产搜索功能
fix: 修复价格监控bug
docs: 更新API文档
style: 代码格式化
refactor: 重构数据采集模块
test: 添加单元测试
chore: 更新依赖
```

---

## 资源和参考

### 文档
- FastAPI: https://fastapi.tiangolo.com/
- Next.js: https://nextjs.org/docs
- PostgreSQL: https://www.postgresql.org/docs/
- Redis: https://redis.io/docs/

### 工具
- Docker Desktop
- Postman / Insomnia（API测试）
- DBeaver / pgAdmin（数据库管理）
- Redis Insight（Redis管理）

### 学习资源
- Real Python（Python教程）
- React官方文档
- System Design Primer（系统设计）
- Awesome FastAPI（资源集合）

---

**文档版本**: v1.0
**创建日期**: 2025-12-16
**用途**: 指导开发团队进行项目搭建和代码组织
