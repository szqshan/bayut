"""
Test FastAPI application endpoints
"""
import pytest


def test_root_endpoint(client):
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data
    assert "docs" in data


def test_health_check(client):
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data
    assert "app_name" in data


def test_docs_available():
    """Test that API documentation is available"""
    from fastapi.testclient import TestClient
    from src.main import app

    with TestClient(app) as test_client:
        response = test_client.get("/docs")
        assert response.status_code == 200
