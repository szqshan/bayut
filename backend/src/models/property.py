"""
Property model - represents real estate properties from Bayut
"""
import uuid
from datetime import datetime
from sqlalchemy import Column, String, Numeric, Integer, DateTime, Enum as SQLEnum, Text, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import enum

from src.db.base import Base


class PropertyPurpose(str, enum.Enum):
    """Property purpose enumeration"""
    SALE = "for-sale"
    RENT = "for-rent"


class Property(Base):
    """Property model"""
    __tablename__ = "properties"

    # Primary key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Bayut external ID (unique identifier from API)
    external_id = Column(String(100), unique=True, nullable=False, index=True)

    # Basic information
    title = Column(String(500), nullable=False)
    description = Column(Text, nullable=True)

    # Price information
    price = Column(Numeric(15, 2), nullable=False, index=True)
    currency = Column(String(10), default="AED", nullable=False)

    # Property details
    area = Column(Numeric(10, 2), nullable=True)  # in square feet
    bedrooms = Column(Integer, nullable=True, index=True)
    bathrooms = Column(Integer, nullable=True)
    rooms = Column(Integer, nullable=True)

    # Purpose and category
    purpose = Column(
        SQLEnum(PropertyPurpose),
        nullable=False,
        index=True
    )
    category = Column(String(100), nullable=True)  # apartment, villa, townhouse, etc.

    # Location information
    location_text = Column(String(500), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    # Additional information
    furnishing_status = Column(String(50), nullable=True)  # furnished, unfurnished, etc.
    amenities = Column(Text, nullable=True)  # JSON string of amenities
    photos = Column(Text, nullable=True)  # JSON string of photo URLs

    # Contact information
    agent_name = Column(String(200), nullable=True)
    agent_phone = Column(String(50), nullable=True)
    agent_email = Column(String(200), nullable=True)

    # Metadata
    permit_number = Column(String(100), nullable=True)
    completion_status = Column(String(50), nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # API data timestamps
    first_seen_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    last_seen_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    price_history = relationship(
        "PriceHistory",
        back_populates="property",
        cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<Property(id={self.id}, external_id={self.external_id}, title={self.title[:50]})>"

    def to_dict(self):
        """Convert model to dictionary"""
        return {
            "id": str(self.id),
            "external_id": self.external_id,
            "title": self.title,
            "description": self.description,
            "price": float(self.price) if self.price else None,
            "currency": self.currency,
            "area": float(self.area) if self.area else None,
            "bedrooms": self.bedrooms,
            "bathrooms": self.bathrooms,
            "rooms": self.rooms,
            "purpose": self.purpose.value if self.purpose else None,
            "category": self.category,
            "location_text": self.location_text,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "furnishing_status": self.furnishing_status,
            "amenities": self.amenities,
            "photos": self.photos,
            "agent_name": self.agent_name,
            "agent_phone": self.agent_phone,
            "agent_email": self.agent_email,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
