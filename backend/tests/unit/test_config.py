"""
Test configuration loading
"""
import pytest
from src.config import settings


def test_settings_loaded():
    """Test that settings are loaded correctly"""
    assert settings.APP_NAME is not None
    assert settings.APP_VERSION is not None
    assert settings.DATABASE_URL is not None
    assert settings.REDIS_URL is not None
    assert settings.BAYUT_API_KEY is not None
    assert settings.BAYUT_API_HOST is not None


def test_database_url_format():
    """Test database URL format"""
    assert settings.DATABASE_URL.startswith("postgresql://")


def test_redis_url_format():
    """Test Redis URL format"""
    assert settings.REDIS_URL.startswith("redis://")


def test_bayut_api_config():
    """Test Bayut API configuration"""
    assert settings.BAYUT_API_HOST == "bayut-api1.p.rapidapi.com"
    assert len(settings.BAYUT_API_KEY) > 0
