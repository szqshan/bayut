"""
PriceHistory model - tracks property price changes over time
"""
import uuid
from datetime import datetime
from sqlalchemy import Column, Numeric, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from src.db.base import Base


class PriceHistory(Base):
    """Price history model"""
    __tablename__ = "price_history"

    # Primary key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Foreign key to property
    property_id = Column(
        UUID(as_uuid=True),
        ForeignKey("properties.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )

    # Price change information
    old_price = Column(Numeric(15, 2), nullable=False)
    new_price = Column(Numeric(15, 2), nullable=False)
    change_percentage = Column(Numeric(6, 2), nullable=False)  # e.g., -5.50 for 5.5% decrease

    # Timestamp
    recorded_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)

    # Relationships
    property = relationship("Property", back_populates="price_history")

    def __repr__(self):
        return f"<PriceHistory(property_id={self.property_id}, {self.old_price} -> {self.new_price}, {self.change_percentage}%)>"

    def to_dict(self):
        """Convert model to dictionary"""
        return {
            "id": str(self.id),
            "property_id": str(self.property_id),
            "old_price": float(self.old_price),
            "new_price": float(self.new_price),
            "change_percentage": float(self.change_percentage),
            "recorded_at": self.recorded_at.isoformat() if self.recorded_at else None,
        }
