"""handle sqlalchemy session"""

from contextlib import asynccontextmanager
from typing import AsyncIterator

from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from config.settings import settings
from core.exceptions import DatabaseError

async_engine = create_async_engine(
    settings.ASYNC_DB_URL, pool_pre_ping=True, future=True
)
AsyncSessionLocal = async_sessionmaker(
    bind=async_engine, class_=AsyncSession, expire_on_commit=False
)


@asynccontextmanager
async def session_factory() -> AsyncIterator[AsyncSession]:
    async with AsyncSessionLocal(expire_on_commit=False) as session:
        try:
            yield session
        except SQLAlchemyError as e:
            await session.rollback()
            raise DatabaseError("Session error") from e
