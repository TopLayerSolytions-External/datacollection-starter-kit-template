from __future__ import annotations

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from config.constants import _ROOT_DIR, AppEnv


class MigrationSettings(BaseSettings):
    """
    Separate settings for database migrations to avoid circular imports and ensure
    that Alembic can access the necessary configuration without depending on the full
    application settings.
    """

    DB_URL: str = Field(..., description="Connection string for the database.")
    APP_ENV: AppEnv = Field(default=AppEnv.LOCAL, validation_alias="AZURE_ENV")

    model_config = SettingsConfigDict(
        env_file=_ROOT_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )
