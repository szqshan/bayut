"""
Database initialization script
Creates all tables in the database
"""
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.db.base import Base
from src.db.session import engine
from src.models import Property, PriceHistory
from src.config import settings


def init_db():
    """Initialize database"""
    print(f"Creating tables in database: {settings.DATABASE_URL}")
    print("Models to create:")
    print(f"  - {Property.__tablename__}")
    print(f"  - {PriceHistory.__tablename__}")

    try:
        Base.metadata.create_all(bind=engine)
        print("✓ Database tables created successfully!")
    except Exception as e:
        print(f"✗ Error creating tables: {e}")
        sys.exit(1)


def drop_db():
    """Drop all tables (use with caution!)"""
    print(f"WARNING: Dropping all tables from: {settings.DATABASE_URL}")
    confirm = input("Are you sure? Type 'yes' to confirm: ")

    if confirm.lower() == "yes":
        try:
            Base.metadata.drop_all(bind=engine)
            print("✓ All tables dropped successfully!")
        except Exception as e:
            print(f"✗ Error dropping tables: {e}")
            sys.exit(1)
    else:
        print("Cancelled.")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Database initialization")
    parser.add_argument(
        "--drop",
        action="store_true",
        help="Drop all tables (DANGEROUS!)"
    )

    args = parser.parse_args()

    if args.drop:
        drop_db()
    else:
        init_db()
