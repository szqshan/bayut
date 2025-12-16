# Bayut API 集成完整指南

## 概述

本指南详细说明如何集成Bayut API（通过RapidAPI平台），包括API调用策略、错误处理、速率限制和最佳实践。

## 目录

1. [API基础信息](#api基础信息)
2. [认证配置](#认证配置)
3. [核心端点](#核心端点)
4. [请求示例](#请求示例)
5. [速率限制策略](#速率限制策略)
6. [错误处理](#错误处理)
7. [数据采集策略](#数据采集策略)
8. [缓存策略](#缓存策略)
9. [最佳实践](#最佳实践)

---

## API基础信息

### 基本信息
- **提供商**: Bayut API
- **平台**: RapidAPI
- **API主机**: bayut-api1.p.rapidapi.com
- **协议**: HTTPS
- **数据格式**: JSON

### RapidAPI订阅计划（推测）

| 计划 | 请求限制 | 价格 | 适用场景 |
|------|---------|------|---------|
| Free | 100/day | $0 | 测试开发 |
| Basic | 10,000/month | $50/month | 小规模应用 |
| Pro | 100,000/month | $200/month | 中等规模 |
| Ultra | 1,000,000/month | $1000/month | 大规模应用 |

注意：实际计划请访问RapidAPI平台确认

---

## 认证配置

### 获取API密钥

1. 访问 https://rapidapi.com/BayutAPI/api/bayut-api1
2. 点击 "Subscribe to Test"
3. 选择订阅计划
4. 在 "Code Snippets" 中找到你的 `x-rapidapi-key`

### 环境变量配置

```bash
# .env 文件
BAYUT_API_KEY=11866b605emsh4cd66daa3f619a6p116389jsnc7a9076d4000
BAYUT_API_HOST=bayut-api1.p.rapidapi.com
BAYUT_BASE_URL=https://bayut-api1.p.rapidapi.com
```

### Python配置示例

```python
# config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    BAYUT_API_KEY: str
    BAYUT_API_HOST: str
    BAYUT_BASE_URL: str = "https://bayut-api1.p.rapidapi.com"

    class Config:
        env_file = ".env"

settings = Settings()
```

---

## 核心端点

### 1. 房产列表查询

**端点**: `GET /properties/list`

**功能**: 根据条件获取房产列表

**查询参数**:
```python
{
    "locationExternalIDs": "5002",  # 位置ID（迪拜）
    "purpose": "for-sale",          # for-sale 或 for-rent
    "hitsPerPage": 25,              # 每页结果数（最大50）
    "page": 0,                      # 页码（从0开始）
    "lang": "en",                   # 语言（en, ar）
    "sort": "city-level-score",     # 排序方式
    "rentFrequency": "yearly",      # 租金频率（仅租赁）
    "categoryExternalID": "4",      # 类型ID（公寓、别墅等）
    "minPrice": 50000,              # 最低价格
    "maxPrice": 1000000,            # 最高价格
    "minBeds": 1,                   # 最少卧室
    "maxBeds": 5,                   # 最多卧室
    "minBaths": 1,                  # 最少浴室
    "maxBaths": 3,                  # 最多浴室
    "minArea": 500,                 # 最小面积（平方英尺）
    "maxArea": 5000,                # 最大面积
}
```

**响应示例**:
```json
{
  "hits": [
    {
      "id": 12345678,
      "externalID": "12345678",
      "title": "2BR Apartment in Marina",
      "price": 850000,
      "currency": "AED",
      "area": 1200.50,
      "bedrooms": 2,
      "bathrooms": 2,
      "location": [
        {"name": "Dubai", "level": 0},
        {"name": "Dubai Marina", "level": 1}
      ],
      "geography": {
        "lat": 25.0808,
        "lng": 55.1414
      },
      "contactName": "Agent Name",
      "phoneNumber": {
        "mobile": "+971501234567"
      },
      "coverPhoto": {
        "url": "https://..."
      },
      "photos": [...],
      "amenities": ["Balcony", "Parking", "Gym"],
      "createdAt": "2025-01-15T10:30:00Z",
      "updatedAt": "2025-01-16T14:20:00Z"
    }
  ],
  "nbHits": 1234,
  "nbPages": 50
}
```

### 2. 房产详情查询

**端点**: `GET /properties/detail`

**查询参数**:
```python
{
    "externalID": "12345678",  # 房产ID
    "lang": "en"               # 语言
}
```

**响应示例**:
```json
{
  "id": 12345678,
  "externalID": "12345678",
  "title": "2BR Apartment in Marina",
  "description": "Beautiful 2 bedroom apartment...",
  "price": 850000,
  "currency": "AED",
  "area": 1200.50,
  "bedrooms": 2,
  "bathrooms": 2,
  "rooms": 4,
  "purpose": "for-sale",
  "furnishingStatus": "furnished",
  "category": [
    {"id": 4, "name": "Apartment", "level": 0}
  ],
  "location": [...],
  "geography": {
    "lat": 25.0808,
    "lng": 55.1414
  },
  "agent": {
    "id": 2512279,
    "name": "Agent Name",
    "email": "agent@email.com",
    "phone": "+971501234567",
    "company": "Real Estate Co."
  },
  "amenities": ["Balcony", "Parking", "Gym", "Pool"],
  "photos": [
    {"id": 1, "url": "https://...", "title": "Living Room"},
    {"id": 2, "url": "https://...", "title": "Bedroom"}
  ],
  "videos": [...],
  "floorPlans": [...],
  "permitNumber": "12345",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-16T14:20:00Z"
}
```

### 3. 经纪人信息查询

**端点**: `GET /agent/{agentID}`

**路径参数**:
- `agentID`: 经纪人ID（如：2512279）

**查询参数**:
```python
{
    "langs": "en"  # 或 "ar"
}
```

**响应示例**:
```json
{
  "id": 2512279,
  "name": "Agent Name",
  "email": "agent@email.com",
  "mobile": "+971501234567",
  "company": "Real Estate Company",
  "photo": "https://...",
  "languages": ["English", "Arabic"],
  "activeListings": 125,
  "rating": 4.5,
  "reviews": 89,
  "description": "Experienced real estate agent..."
}
```

### 4. 地理位置查询

**端点**: `GET /auto-complete`

**查询参数**:
```python
{
    "query": "Marina",  # 搜索关键词
    "hitsPerPage": 10,  # 结果数量
    "page": 0,
    "lang": "en"
}
```

**响应示例**:
```json
{
  "hits": [
    {
      "id": 1,
      "externalID": "5002,6,1482",
      "name": "Dubai Marina",
      "name_l1": "مارينا دبي",
      "hierarchy": [
        {"level": 0, "name": "UAE", "externalID": "1"},
        {"level": 1, "name": "Dubai", "externalID": "5002"},
        {"level": 2, "name": "Dubai Marina", "externalID": "1482"}
      ],
      "geography": {
        "lat": 25.0808,
        "lng": 55.1414
      }
    }
  ]
}
```

### 5. 类别查询

**端点**: `GET /categories`

**响应示例**:
```json
[
  {"id": 1, "name": "Residential", "externalID": "1"},
  {"id": 4, "name": "Apartments", "externalID": "4", "parent": 1},
  {"id": 3, "name": "Villas", "externalID": "3", "parent": 1},
  {"id": 16, "name": "Townhouses", "externalID": "16", "parent": 1}
]
```

---

## 请求示例

### Python完整实现

```python
import requests
from typing import Dict, Any, Optional
import time
from functools import wraps
import logging

logger = logging.getLogger(__name__)

class BayutAPIClient:
    """Bayut API客户端"""

    def __init__(self, api_key: str, api_host: str):
        self.api_key = api_key
        self.api_host = api_host
        self.base_url = f"https://{api_host}"
        self.session = requests.Session()

        # 设置默认请求头
        self.session.headers.update({
            "x-rapidapi-key": api_key,
            "x-rapidapi-host": api_host
        })

    def _make_request(
        self,
        method: str,
        endpoint: str,
        params: Optional[Dict[str, Any]] = None,
        max_retries: int = 3
    ) -> Dict[str, Any]:
        """
        发送HTTP请求

        Args:
            method: HTTP方法（GET, POST等）
            endpoint: API端点
            params: 查询参数
            max_retries: 最大重试次数

        Returns:
            响应JSON数据
        """
        url = f"{self.base_url}{endpoint}"

        for attempt in range(max_retries):
            try:
                response = self.session.request(
                    method=method,
                    url=url,
                    params=params,
                    timeout=30
                )

                # 处理速率限制
                if response.status_code == 429:
                    retry_after = int(response.headers.get('Retry-After', 60))
                    logger.warning(f"Rate limited. Waiting {retry_after}s")
                    time.sleep(retry_after)
                    continue

                # 抛出HTTP错误
                response.raise_for_status()

                return response.json()

            except requests.exceptions.Timeout:
                logger.error(f"Timeout on attempt {attempt + 1}")
                if attempt == max_retries - 1:
                    raise
                time.sleep(2 ** attempt)  # 指数退避

            except requests.exceptions.RequestException as e:
                logger.error(f"Request failed: {e}")
                if attempt == max_retries - 1:
                    raise
                time.sleep(2 ** attempt)

        raise Exception(f"Failed after {max_retries} retries")

    def get_properties(
        self,
        location_external_ids: str = "5002",
        purpose: str = "for-sale",
        hits_per_page: int = 25,
        page: int = 0,
        **kwargs
    ) -> Dict[str, Any]:
        """
        获取房产列表

        Args:
            location_external_ids: 位置ID
            purpose: 用途（for-sale 或 for-rent）
            hits_per_page: 每页结果数
            page: 页码
            **kwargs: 其他过滤参数

        Returns:
            房产列表响应
        """
        params = {
            "locationExternalIDs": location_external_ids,
            "purpose": purpose,
            "hitsPerPage": hits_per_page,
            "page": page,
            "lang": kwargs.get("lang", "en"),
            **kwargs
        }

        return self._make_request("GET", "/properties/list", params)

    def get_property_detail(
        self,
        external_id: str,
        lang: str = "en"
    ) -> Dict[str, Any]:
        """
        获取房产详情

        Args:
            external_id: 房产外部ID
            lang: 语言

        Returns:
            房产详情
        """
        params = {
            "externalID": external_id,
            "lang": lang
        }

        return self._make_request("GET", "/properties/detail", params)

    def get_agent(
        self,
        agent_id: int,
        langs: str = "en"
    ) -> Dict[str, Any]:
        """
        获取经纪人信息

        Args:
            agent_id: 经纪人ID
            langs: 语言

        Returns:
            经纪人信息
        """
        params = {"langs": langs}
        return self._make_request("GET", f"/agent/{agent_id}", params)

    def search_locations(
        self,
        query: str,
        hits_per_page: int = 10,
        lang: str = "en"
    ) -> Dict[str, Any]:
        """
        搜索地理位置

        Args:
            query: 搜索关键词
            hits_per_page: 结果数量
            lang: 语言

        Returns:
            位置列表
        """
        params = {
            "query": query,
            "hitsPerPage": hits_per_page,
            "lang": lang
        }

        return self._make_request("GET", "/auto-complete", params)

# 使用示例
if __name__ == "__main__":
    from config import settings

    client = BayutAPIClient(
        api_key=settings.BAYUT_API_KEY,
        api_host=settings.BAYUT_API_HOST
    )

    # 获取迪拜Marina区域的公寓
    properties = client.get_properties(
        location_external_ids="5002,6,1482",
        purpose="for-sale",
        categoryExternalID="4",
        minPrice=500000,
        maxPrice=2000000,
        minBeds=2,
        maxBeds=3,
        hits_per_page=25
    )

    print(f"找到 {properties['nbHits']} 个房源")

    # 获取第一个房源的详情
    if properties['hits']:
        first_property = properties['hits'][0]
        detail = client.get_property_detail(first_property['externalID'])
        print(f"房源详情: {detail['title']}")
```

---

## 速率限制策略

### Token Bucket限流器

```python
import time
from threading import Lock
from typing import Optional

class TokenBucket:
    """令牌桶算法实现速率限制"""

    def __init__(self, rate: int, capacity: int):
        """
        Args:
            rate: 每秒生成令牌数
            capacity: 桶容量
        """
        self.rate = rate
        self.capacity = capacity
        self.tokens = capacity
        self.last_update = time.time()
        self.lock = Lock()

    def consume(self, tokens: int = 1) -> bool:
        """
        尝试消费令牌

        Args:
            tokens: 需要消费的令牌数

        Returns:
            是否成功消费
        """
        with self.lock:
            now = time.time()
            elapsed = now - self.last_update

            # 添加新令牌
            self.tokens = min(
                self.capacity,
                self.tokens + elapsed * self.rate
            )
            self.last_update = now

            # 尝试消费
            if self.tokens >= tokens:
                self.tokens -= tokens
                return True

            return False

    def wait_for_token(self, tokens: int = 1) -> None:
        """等待直到有足够令牌"""
        while not self.consume(tokens):
            time.sleep(0.1)

# 使用示例
class RateLimitedBayutClient(BayutAPIClient):
    """带速率限制的Bayut客户端"""

    def __init__(self, api_key: str, api_host: str, requests_per_second: int = 10):
        super().__init__(api_key, api_host)
        self.rate_limiter = TokenBucket(rate=requests_per_second, capacity=requests_per_second * 2)

    def _make_request(self, method: str, endpoint: str, params: Optional[Dict] = None, max_retries: int = 3):
        # 等待令牌
        self.rate_limiter.wait_for_token()

        # 执行请求
        return super()._make_request(method, endpoint, params, max_retries)
```

---

## 错误处理

### 错误类型和处理策略

```python
from enum import Enum
from typing import Callable, Any

class APIErrorType(Enum):
    RATE_LIMIT = 429
    UNAUTHORIZED = 401
    NOT_FOUND = 404
    SERVER_ERROR = 500
    TIMEOUT = 408
    BAD_REQUEST = 400

class BayutAPIError(Exception):
    """Bayut API异常基类"""
    def __init__(self, message: str, status_code: int, response: Any = None):
        self.message = message
        self.status_code = status_code
        self.response = response
        super().__init__(self.message)

class RateLimitError(BayutAPIError):
    """速率限制异常"""
    pass

class AuthenticationError(BayutAPIError):
    """认证异常"""
    pass

class NotFoundError(BayutAPIError):
    """资源不存在"""
    pass

def handle_api_errors(func: Callable) -> Callable:
    """API错误处理装饰器"""

    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except requests.exceptions.HTTPError as e:
            status_code = e.response.status_code

            if status_code == 429:
                raise RateLimitError(
                    "API rate limit exceeded",
                    status_code,
                    e.response
                )
            elif status_code == 401:
                raise AuthenticationError(
                    "Invalid API credentials",
                    status_code,
                    e.response
                )
            elif status_code == 404:
                raise NotFoundError(
                    "Resource not found",
                    status_code,
                    e.response
                )
            elif status_code >= 500:
                logger.error(f"Server error: {e}")
                raise BayutAPIError(
                    "Bayut API server error",
                    status_code,
                    e.response
                )
            else:
                raise BayutAPIError(
                    f"API error: {e}",
                    status_code,
                    e.response
                )
        except requests.exceptions.Timeout:
            logger.error("Request timeout")
            raise BayutAPIError("Request timeout", 408)
        except Exception as e:
            logger.exception("Unexpected error")
            raise

    return wrapper
```

---

## 数据采集策略

### 全量采集

```python
from typing import List, Generator
import logging

logger = logging.getLogger(__name__)

class PropertyCollector:
    """房产数据采集器"""

    def __init__(self, client: BayutAPIClient):
        self.client = client

    def collect_all_properties(
        self,
        location_id: str,
        purpose: str = "for-sale",
        batch_size: int = 25
    ) -> Generator[Dict, None, None]:
        """
        采集所有房产数据（生成器）

        Args:
            location_id: 位置ID
            purpose: 用途
            batch_size: 批次大小

        Yields:
            房产数据
        """
        page = 0
        total_pages = None

        while True:
            try:
                result = self.client.get_properties(
                    location_external_ids=location_id,
                    purpose=purpose,
                    hits_per_page=batch_size,
                    page=page
                )

                if total_pages is None:
                    total_pages = result.get('nbPages', 0)
                    logger.info(f"Total pages to collect: {total_pages}")

                hits = result.get('hits', [])
                if not hits:
                    break

                for property_data in hits:
                    yield property_data

                logger.info(f"Collected page {page + 1}/{total_pages}")

                page += 1
                if page >= total_pages:
                    break

            except Exception as e:
                logger.error(f"Error collecting page {page}: {e}")
                # 继续下一页
                page += 1
                if total_pages and page >= total_pages:
                    break

# 使用示例
def save_properties_to_db(properties: List[Dict], db_session):
    """保存到数据库"""
    for prop in properties:
        # 数据清洗和验证
        cleaned_data = clean_property_data(prop)

        # 检查是否已存在
        existing = db_session.query(Property).filter_by(
            external_id=cleaned_data['external_id']
        ).first()

        if existing:
            # 更新
            for key, value in cleaned_data.items():
                setattr(existing, key, value)
        else:
            # 新增
            new_property = Property(**cleaned_data)
            db_session.add(new_property)

    db_session.commit()

def run_full_collection():
    """执行全量采集"""
    client = RateLimitedBayutClient(
        api_key=settings.BAYUT_API_KEY,
        api_host=settings.BAYUT_API_HOST,
        requests_per_second=5  # 根据你的订阅计划调整
    )

    collector = PropertyCollector(client)

    # 采集迪拜所有待售房产
    properties = collector.collect_all_properties(
        location_id="5002",
        purpose="for-sale"
    )

    batch = []
    batch_size = 100

    for prop in properties:
        batch.append(prop)

        if len(batch) >= batch_size:
            save_properties_to_db(batch, db_session)
            batch = []

    # 保存剩余数据
    if batch:
        save_properties_to_db(batch, db_session)
```

### 增量采集

```python
from datetime import datetime, timedelta

def collect_recent_updates(since_hours: int = 1):
    """
    采集最近更新的房产

    Args:
        since_hours: 采集最近N小时的更新
    """
    client = RateLimitedBayutClient(
        api_key=settings.BAYUT_API_KEY,
        api_host=settings.BAYUT_API_HOST
    )

    # 获取最近更新的房产
    result = client.get_properties(
        location_external_ids="5002",
        purpose="for-sale",
        sort="date-desc",  # 按日期降序
        hits_per_page=50
    )

    cutoff_time = datetime.now() - timedelta(hours=since_hours)
    new_properties = []

    for prop in result['hits']:
        updated_at = datetime.fromisoformat(
            prop['updatedAt'].replace('Z', '+00:00')
        )

        if updated_at > cutoff_time:
            new_properties.append(prop)
        else:
            break  # 已经超出时间范围

    return new_properties
```

---

## 缓存策略

### Redis缓存实现

```python
import redis
import json
from typing import Optional, Callable
from functools import wraps

class RedisCache:
    """Redis缓存管理器"""

    def __init__(self, redis_client: redis.Redis, prefix: str = "bayut"):
        self.redis = redis_client
        self.prefix = prefix

    def get(self, key: str) -> Optional[Any]:
        """获取缓存"""
        full_key = f"{self.prefix}:{key}"
        data = self.redis.get(full_key)
        if data:
            return json.loads(data)
        return None

    def set(self, key: str, value: Any, ttl: int = 300):
        """设置缓存"""
        full_key = f"{self.prefix}:{key}"
        self.redis.setex(
            full_key,
            ttl,
            json.dumps(value, default=str)
        )

    def delete(self, key: str):
        """删除缓存"""
        full_key = f"{self.prefix}:{key}"
        self.redis.delete(full_key)

def cached(ttl: int = 300):
    """缓存装饰器"""
    def decorator(func: Callable):
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            # 生成缓存键
            cache_key = f"{func.__name__}:{hash(str(args) + str(kwargs))}"

            # 尝试从缓存获取
            cached_result = self.cache.get(cache_key)
            if cached_result is not None:
                logger.debug(f"Cache hit: {cache_key}")
                return cached_result

            # 执行函数
            result = func(self, *args, **kwargs)

            # 缓存结果
            self.cache.set(cache_key, result, ttl)
            logger.debug(f"Cache set: {cache_key}")

            return result

        return wrapper
    return decorator

# 使用示例
class CachedBayutClient(RateLimitedBayutClient):
    """带缓存的Bayut客户端"""

    def __init__(self, api_key: str, api_host: str, redis_client: redis.Redis):
        super().__init__(api_key, api_host)
        self.cache = RedisCache(redis_client)

    @cached(ttl=900)  # 15分钟缓存
    def get_property_detail(self, external_id: str, lang: str = "en"):
        return super().get_property_detail(external_id, lang)

    @cached(ttl=300)  # 5分钟缓存
    def get_properties(self, **kwargs):
        return super().get_properties(**kwargs)
```

---

## 最佳实践

### 1. 合理使用缓存

```python
缓存策略建议：
- 房源列表：5-10分钟
- 房源详情：15-30分钟
- 经纪人信息：1小时
- 地理位置数据：24小时
- 类别数据：7天
```

### 2. 批量请求优化

```python
# 不推荐：逐个请求
for property_id in property_ids:
    detail = client.get_property_detail(property_id)
    process(detail)

# 推荐：批量收集后处理
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
    futures = [
        executor.submit(client.get_property_detail, pid)
        for pid in property_ids
    ]
    for future in concurrent.futures.as_completed(futures):
        detail = future.result()
        process(detail)
```

### 3. 错误监控

```python
import sentry_sdk

# 监控API错误
try:
    result = client.get_properties()
except BayutAPIError as e:
    sentry_sdk.capture_exception(e)
    # 记录到数据库
    log_api_error(e)
    raise
```

### 4. 数据验证

```python
from pydantic import BaseModel, validator

class PropertySchema(BaseModel):
    external_id: str
    title: str
    price: float
    area: float
    bedrooms: int
    bathrooms: int

    @validator('price')
    def validate_price(cls, v):
        if v <= 0:
            raise ValueError('Price must be positive')
        if v > 100000000:  # 1亿上限
            raise ValueError('Price seems unrealistic')
        return v

    @validator('area')
    def validate_area(cls, v):
        if v <= 0 or v > 100000:
            raise ValueError('Invalid area')
        return v

# 使用
raw_data = client.get_property_detail('12345678')
validated_property = PropertySchema(**raw_data)
```

### 5. 请求日志记录

```python
import logging
from datetime import datetime

class RequestLogger:
    """API请求日志记录"""

    @staticmethod
    def log_request(endpoint: str, params: Dict, response_time: float, status: int):
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'endpoint': endpoint,
            'params': params,
            'response_time': response_time,
            'status': status
        }

        logger.info(f"API Request: {json.dumps(log_entry)}")

        # 保存到数据库用于分析
        save_request_log(log_entry)
```

---

## 故障排查

### 常见问题

#### 1. 401 Unauthorized
**原因**: API密钥无效或过期
**解决**:
- 检查环境变量配置
- 在RapidAPI确认密钥是否有效
- 检查订阅是否过期

#### 2. 429 Rate Limit
**原因**: 超出速率限制
**解决**:
- 实施速率限制器
- 增加请求间隔
- 升级订阅计划

#### 3. 404 Not Found
**原因**: 资源不存在
**解决**:
- 验证房产ID是否正确
- 房源可能已下架

#### 4. 超时
**原因**: 网络问题或服务器负载
**解决**:
- 增加超时时间
- 实施重试机制
- 检查网络连接

---

## 性能优化建议

1. **使用连接池**: 复用HTTP连接
2. **并发控制**: 限制并发请求数（建议5-10）
3. **智能重试**: 指数退避策略
4. **数据压缩**: 启用gzip压缩
5. **监控告警**: 设置API调用监控

---

**文档版本**: v1.0
**最后更新**: 2025-12-16
**适用于**: Bayut API via RapidAPI
