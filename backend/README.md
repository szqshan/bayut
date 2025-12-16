# Bayut Platform Backend

Backend API for Bayut Property Platform - MVP Phase 1

## Quick Start

### 1. Start Database and Redis

```bash
# From project root
cd /home/user/bayut
docker-compose up -d postgres redis

# Check services are running
docker-compose ps
```

### 2. Install Dependencies

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Configure Environment

```bash
# Copy example env file
cp .env.example .env

# Edit .env and add your Bayut API key
nano .env  # or use any text editor
```

### 4. Initialize Database

```bash
# Method 1: Using Alembic (recommended)
alembic upgrade head

# Method 2: Using init script
python scripts/init_db.py
```

### 5. Run Application

```bash
# Development mode
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

# Or use Python directly
python src/main.py
```

### 6. Test the API

```bash
# Health check
curl http://localhost:8000/health

# API documentation
open http://localhost:8000/docs
```

## Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/unit/test_config.py -v

# Run only unit tests
pytest tests/unit/ -v

# Run only integration tests
pytest tests/integration/ -v
```

## Database Migrations

```bash
# Create new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# View migration history
alembic history
```

## Project Structure

```
backend/
├── src/
│   ├── api/           # API endpoints
│   ├── models/        # Database models
│   ├── schemas/       # Pydantic schemas
│   ├── services/      # Business logic
│   ├── db/            # Database configuration
│   ├── core/          # Core utilities
│   ├── config.py      # Settings
│   └── main.py        # FastAPI app
├── tests/
│   ├── unit/          # Unit tests
│   └── integration/   # Integration tests
├── alembic/           # Database migrations
└── scripts/           # Utility scripts
```

## Next Steps

Phase 1 is complete! Now proceed to:
- **Phase 2**: Bayut API Integration
- See `MVP_PLAN.md` for details

## Troubleshooting

### Database Connection Error

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check connection
psql -h localhost -U bayut -d bayut_db
# Password: bayut123
```

### Redis Connection Error

```bash
# Check Redis is running
docker-compose ps redis

# Test connection
redis-cli ping
# Should return: PONG
```

### Import Errors

```bash
# Make sure you're in the backend directory
cd backend

# And virtual environment is activated
source venv/bin/activate
```

## Environment Variables

Required variables in `.env`:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `BAYUT_API_KEY` - Your RapidAPI key for Bayut
- `BAYUT_API_HOST` - bayut-api1.p.rapidapi.com

See `.env.example` for all available variables.
