from sqlalchemy import text

from app.db.session import engine


async def init_db() -> None:
    async with engine.begin() as connection:
        # Schema management is handled by Alembic migrations.
        # Startup only verifies that the database is reachable.
        await connection.execute(text("SELECT 1"))
