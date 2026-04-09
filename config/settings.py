"""
Application settings.

- Central place to store configuration values.
- Can be extended to read from environment variables or YAML files.
"""

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from config.constants import _ROOT_DIR, AppEnv


class Settings(BaseSettings):
    APP_ENV: AppEnv = Field(default=AppEnv.LOCAL, validation_alias="AZURE_ENV")
    TEMPORAL_HOST: str = Field(..., description="Temporal server host URL.")

    model_config = SettingsConfigDict(
        env_file=_ROOT_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
