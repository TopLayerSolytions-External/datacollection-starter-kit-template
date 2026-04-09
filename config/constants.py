from __future__ import annotations

import pathlib
from enum import Enum
from typing import TypeVar

from pydantic import BaseModel

_CURRENT_DIR = pathlib.Path(__file__).resolve().parent
_ROOT_DIR = _CURRENT_DIR.parent
GENERIC_TYPE = TypeVar("GENERIC_TYPE", bound=BaseModel)


class AppEnv(str, Enum):
    """
    Defines the execution environments for the application.

    Used to toggle environment-specific logic such as logging levels,
    storage providers (local vs. cloud), and database connection strings.
    """

    LOCAL = "local"
    DEVELOPMENT = "development"
    UAT = "uat"
    PRODUCTION = "production"
