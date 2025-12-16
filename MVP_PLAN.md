# Bayut房产平台 - MVP开发计划

## MVP目标

构建一个最小可行产品，核心功能：
1. 连接Bayut API并获取房产数据
2. 将数据存储到数据库
3. 提供简单的查询API
4. 基础的价格监控功能

## MVP范围界定

### 包含功能
- Bayut API客户端（带限流和错误处理）
- 数据采集任务（手动触发）
- 数据库存储（房产、价格历史）
- REST API（查询房产）
- 简单的价格变化检测

### 不包含功能（后续迭代）
- 用户系统
- 前端界面
- 实时通知
- AI推荐
- 复杂分析

---

## 技术栈（MVP）

### 后端
- Python 3.11+
- FastAPI
- SQLAlchemy + PostgreSQL
- Redis（缓存）
- pytest（测试）

### 工具
- Docker Compose（本地开发）
- Alembic（数据库迁移）

---

## 开发阶段

### Phase 1: 项目基础搭建（第1周）

#### 1.1 环境初始化
**任务**:
- [ ] 创建项目目录结构
- [ ] 设置Python虚拟环境
- [ ] 配置Docker Compose（PostgreSQL + Redis）
- [ ] 创建.env配置文件

**测试标准**:
```bash
# 能够成功启动数据库和Redis
docker-compose up -d
docker-compose ps  # 所有服务状态为Up

# Python环境正常
python --version  # 显示3.11+
pip list  # 显示已安装包
```

**代码结构**:
```
bayut-mvp/
├── backend/
│   ├── src/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   └── ...
│   ├── tests/
│   ├── requirements.txt
│   ├── .env.example
│   └── Dockerfile
├── docker-compose.yml
└── README.md
```

#### 1.2 数据库设计
**任务**:
- [ ] 设计Property表结构
- [ ] 设计PriceHistory表结构
- [ ] 创建Alembic迁移脚本
- [ ] 初始化数据库

**数据模型**:
```python
# models/property.py
class Property:
    id: UUID (PK)
    external_id: String (唯一索引)
    title: String
    price: Decimal
    currency: String
    area: Decimal
    bedrooms: Integer
    bathrooms: Integer
    location_text: String
    latitude: Float
    longitude: Float
    purpose: Enum (sale/rent)
    category: String
    created_at: DateTime
    updated_at: DateTime

# models/price_history.py
class PriceHistory:
    id: UUID (PK)
    property_id: UUID (FK)
    old_price: Decimal
    new_price: Decimal
    change_percentage: Decimal
    recorded_at: DateTime
```

**测试标准**:
```bash
# 迁移成功
alembic upgrade head

# 表已创建
psql -U bayut -d bayut_db -c "\dt"
# 输出：properties, price_history, alembic_version

# 可以插入测试数据
python scripts/test_db.py  # 成功插入和查询
```

---

### Phase 2: Bayut API集成（第2周）

#### 2.1 API客户端开发
**任务**:
- [ ] 创建BayutAPIClient类
- [ ] 实现get_properties方法
- [ ] 实现get_property_detail方法
- [ ] 添加错误处理和重试
- [ ] 实现简单的速率限制

**核心代码**:
```python
# services/bayut_client.py
class BayutAPIClient:
    def __init__(self, api_key: str, api_host: str):
        pass

    def get_properties(self, **params) -> Dict:
        """获取房产列表"""
        pass

    def get_property_detail(self, external_id: str) -> Dict:
        """获取房产详情"""
        pass
```

**测试标准**:
```python
# tests/test_bayut_client.py
def test_get_properties():
    client = BayutAPIClient(api_key, api_host)
    result = client.get_properties(
        location_external_ids="5002",
        purpose="for-sale",
        hits_per_page=5
    )
    assert 'hits' in result
    assert len(result['hits']) > 0

def test_get_property_detail():
    client = BayutAPIClient(api_key, api_host)
    # 使用已知存在的房源ID
    result = client.get_property_detail("12345678")
    assert 'externalID' in result

def test_rate_limiting():
    # 测试速率限制是否工作
    pass

def test_error_handling():
    # 测试错误处理（无效ID等）
    pass
```

**验收标准**:
```bash
pytest tests/test_bayut_client.py -v
# 所有测试通过（PASSED）
```

#### 2.2 数据采集服务
**任务**:
- [ ] 创建PropertyCollector类
- [ ] 实现数据清洗函数
- [ ] 实现数据保存到数据库
- [ ] 添加日志记录

**核心代码**:
```python
# services/property_collector.py
class PropertyCollector:
    def __init__(self, client: BayutAPIClient, db_session):
        pass

    def collect_and_save(
        self,
        location_id: str,
        purpose: str,
        max_pages: int = 5
    ) -> int:
        """采集并保存房产数据，返回保存数量"""
        pass

    def _clean_property_data(self, raw_data: Dict) -> Dict:
        """清洗数据"""
        pass
```

**测试标准**:
```python
def test_collect_and_save():
    collector = PropertyCollector(client, db_session)
    count = collector.collect_and_save(
        location_id="5002",
        purpose="for-sale",
        max_pages=2
    )
    assert count > 0

    # 验证数据库中有数据
    properties = db_session.query(Property).all()
    assert len(properties) == count

def test_duplicate_handling():
    # 重复采集，不应创建重复记录
    collector.collect_and_save("5002", "for-sale", max_pages=1)
    count1 = db_session.query(Property).count()

    collector.collect_and_save("5002", "for-sale", max_pages=1)
    count2 = db_session.query(Property).count()

    assert count1 == count2  # 数量不变
```

**验收标准**:
```bash
# 运行测试
pytest tests/test_property_collector.py -v

# 手动运行采集
python scripts/run_collection.py --location 5002 --max-pages 5
# 检查数据库
psql -U bayut -d bayut_db -c "SELECT COUNT(*) FROM properties;"
# 显示采集的数量
```

---

### Phase 3: REST API开发（第3周）

#### 3.1 基础API端点
**任务**:
- [ ] 创建FastAPI应用
- [ ] 实现GET /properties（列表查询）
- [ ] 实现GET /properties/{id}（详情查询）
- [ ] 添加分页、筛选、排序
- [ ] 集成Redis缓存

**API设计**:
```python
# api/v1/properties.py

@router.get("/properties")
async def get_properties(
    purpose: str = "for-sale",
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    bedrooms: Optional[int] = None,
    page: int = 1,
    page_size: int = 20
):
    """查询房产列表"""
    pass

@router.get("/properties/{property_id}")
async def get_property_detail(property_id: str):
    """获取房产详情"""
    pass

@router.get("/health")
async def health_check():
    """健康检查"""
    return {"status": "ok"}
```

**测试标准**:
```python
# tests/test_api.py
from fastapi.testclient import TestClient

def test_get_properties():
    response = client.get("/api/v1/properties?purpose=for-sale&page=1")
    assert response.status_code == 200
    data = response.json()
    assert 'items' in data
    assert 'total' in data
    assert 'page' in data

def test_get_property_detail():
    # 先创建测试数据
    property_id = create_test_property()

    response = client.get(f"/api/v1/properties/{property_id}")
    assert response.status_code == 200
    data = response.json()
    assert data['id'] == property_id

def test_pagination():
    response = client.get("/api/v1/properties?page=1&page_size=10")
    data = response.json()
    assert len(data['items']) <= 10

def test_filters():
    response = client.get(
        "/api/v1/properties?min_price=500000&max_price=1000000&bedrooms=2"
    )
    data = response.json()
    for item in data['items']:
        assert 500000 <= item['price'] <= 1000000
        assert item['bedrooms'] == 2
```

**验收标准**:
```bash
# 启动服务
uvicorn src.main:app --reload

# 测试健康检查
curl http://localhost:8000/health
# 输出: {"status":"ok"}

# 测试API
curl "http://localhost:8000/api/v1/properties?purpose=for-sale&page=1"
# 返回JSON数据

# 运行所有API测试
pytest tests/test_api.py -v
# 所有测试通过
```

---

### Phase 4: 价格监控功能（第4周）

#### 4.1 价格变化检测
**任务**:
- [ ] 创建价格变化检测逻辑
- [ ] 记录价格历史
- [ ] 实现监控任务（手动触发）
- [ ] 添加监控API端点

**核心代码**:
```python
# services/price_monitor.py
class PriceMonitor:
    def __init__(self, db_session):
        pass

    def check_price_changes(self, property_ids: List[str]) -> List[Dict]:
        """检查价格变化"""
        changes = []
        for prop_id in property_ids:
            # 获取最新价格
            latest = fetch_latest_price_from_api(prop_id)
            # 获取数据库中的价格
            stored = get_stored_property(prop_id)

            if latest['price'] != stored.price:
                change = {
                    'property_id': prop_id,
                    'old_price': stored.price,
                    'new_price': latest['price'],
                    'change_percentage': calculate_change(
                        stored.price,
                        latest['price']
                    )
                }
                changes.append(change)
                # 保存历史记录
                save_price_history(change)
                # 更新房产价格
                update_property_price(prop_id, latest['price'])

        return changes
```

**API端点**:
```python
@router.post("/monitor/check-prices")
async def trigger_price_check(
    location_id: Optional[str] = None,
    limit: int = 100
):
    """触发价格检查"""
    monitor = PriceMonitor(db_session)

    if location_id:
        # 检查特定区域的房产
        property_ids = get_properties_by_location(location_id, limit)
    else:
        # 检查最近更新的房产
        property_ids = get_recently_updated_properties(limit)

    changes = monitor.check_price_changes(property_ids)

    return {
        'checked': len(property_ids),
        'changes_found': len(changes),
        'changes': changes
    }

@router.get("/properties/{property_id}/price-history")
async def get_price_history(property_id: str):
    """获取价格历史"""
    history = db_session.query(PriceHistory).filter_by(
        property_id=property_id
    ).order_by(PriceHistory.recorded_at.desc()).all()

    return history
```

**测试标准**:
```python
def test_price_change_detection():
    # 创建测试房产
    prop = create_test_property(price=1000000)

    # 模拟API返回新价格
    mock_api_response(prop.external_id, price=950000)

    # 运行检测
    monitor = PriceMonitor(db_session)
    changes = monitor.check_price_changes([prop.external_id])

    assert len(changes) == 1
    assert changes[0]['old_price'] == 1000000
    assert changes[0]['new_price'] == 950000
    assert changes[0]['change_percentage'] == -5.0

    # 验证历史记录已保存
    history = db_session.query(PriceHistory).filter_by(
        property_id=prop.id
    ).all()
    assert len(history) == 1

def test_no_price_change():
    prop = create_test_property(price=1000000)
    mock_api_response(prop.external_id, price=1000000)

    monitor = PriceMonitor(db_session)
    changes = monitor.check_price_changes([prop.external_id])

    assert len(changes) == 0  # 无变化
```

**验收标准**:
```bash
# 运行测试
pytest tests/test_price_monitor.py -v

# 手动触发价格检查
curl -X POST "http://localhost:8000/api/v1/monitor/check-prices?limit=50"
# 返回检查结果

# 查看价格历史
curl "http://localhost:8000/api/v1/properties/{property_id}/price-history"
# 返回历史记录

# 验证数据库
psql -U bayut -d bayut_db -c "SELECT COUNT(*) FROM price_history;"
# 显示历史记录数量
```

---

### Phase 5: 部署和文档（第5周）

#### 5.1 生产环境准备
**任务**:
- [ ] 创建生产环境Dockerfile
- [ ] 配置环境变量管理
- [ ] 设置日志记录
- [ ] 添加健康检查端点
- [ ] 准备docker-compose.prod.yml

**验收标准**:
```bash
# 构建生产镜像
docker build -t bayut-api:v1.0 ./backend

# 使用生产配置启动
docker-compose -f docker-compose.prod.yml up -d

# 健康检查
curl http://localhost:8000/health
# 返回: {"status":"ok","version":"1.0.0"}

# 查看日志
docker-compose logs -f api
```

#### 5.2 API文档
**任务**:
- [ ] 完善FastAPI自动文档
- [ ] 添加使用示例
- [ ] 创建简单的README

**验收标准**:
- 访问 http://localhost:8000/docs 查看Swagger文档
- 所有端点都有清晰的描述和示例
- README包含快速开始指南

---

## MVP完成标准

### 功能测试清单

- [ ] 可以从Bayut API获取房产数据
- [ ] 数据正确保存到PostgreSQL
- [ ] API可以查询房产列表（支持分页和筛选）
- [ ] API可以获取单个房产详情
- [ ] 价格监控可以检测价格变化
- [ ] 价格历史被正确记录
- [ ] 所有单元测试通过
- [ ] 所有集成测试通过
- [ ] Docker Compose可以一键启动所有服务
- [ ] API文档完整可访问

### 性能指标

- API响应时间 < 1秒（90%请求）
- 采集100个房产 < 2分钟
- 数据库查询 < 100ms

### 代码质量

- 测试覆盖率 > 70%
- 所有代码通过lint检查
- 关键函数有文档字符串

---

## 每周检查点

### Week 1 检查点
- [ ] Docker环境正常运行
- [ ] 数据库表创建成功
- [ ] 可以手动插入和查询数据

### Week 2 检查点
- [ ] 可以成功调用Bayut API
- [ ] 可以采集至少50个房产到数据库
- [ ] API客户端测试全部通过

### Week 3 检查点
- [ ] FastAPI服务运行正常
- [ ] 可以通过API查询房产
- [ ] API测试全部通过

### Week 4 检查点
- [ ] 价格监控功能正常工作
- [ ] 价格历史记录正确
- [ ] 监控测试全部通过

### Week 5 检查点
- [ ] 生产环境可以部署
- [ ] 文档完整
- [ ] MVP所有功能验收通过

---

## 后续迭代方向

MVP完成后，可以选择以下方向扩展：

### 迭代1: 自动化和调度
- Celery定时任务
- 自动采集调度
- 自动价格监控

### 迭代2: 用户系统
- 用户注册登录
- API认证（JWT）
- 用户偏好设置

### 迭代3: 通知功能
- 邮件通知
- 价格提醒订阅
- 自定义监控规则

### 迭代4: 前端界面
- React前端
- 搜索界面
- 数据可视化

### 迭代5: 高级功能
- AI推荐
- 市场分析
- 移动端App

---

## 开发规范

### 提交规范
```bash
feat: 添加房产查询API
fix: 修复价格监控bug
test: 添加API测试
docs: 更新README
```

### 分支策略
```
main - 稳定版本
develop - 开发分支
feature/* - 功能分支
```

### 测试要求
- 每个功能开发完成必须有测试
- 测试必须通过才能合并
- 关键路径必须有集成测试

---

## 资源需求

### 开发环境
- 8GB+ RAM
- 20GB+ 磁盘空间
- Docker Desktop

### API费用
- RapidAPI订阅（建议Basic计划 $50/月）
- 预计月调用量：10,000-50,000次

### 时间投入
- MVP开发：5周（1人全职）
- 或：10周（1人半职）

---

**计划版本**: v1.0
**创建日期**: 2025-12-16
**目标完成**: 5周内

这是一个可执行的MVP计划，每一步都有明确的任务、测试标准和验收标准。建议严格按照这个计划执行，确保每个阶段都完成并测试通过后再进入下一阶段。
