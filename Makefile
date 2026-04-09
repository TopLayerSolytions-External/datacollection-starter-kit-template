# Makefile - in the root of the project, to build the project and run tests
#
# Use: make <target>
# Command list: make help

.PHONY: help setup start stop restart logs ps build migrate migrate-down \
        migrate-create test lint format clean reset shell-app shell-db

COMPOSE = docker compose -f docker/docker-compose.yml
APP_SERVICE = datacollection_python
DB_SERVICE = postgres

# ─── Setup ───────────────────────────────────────

help:           ## Display the list of available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup:          ## Initial setup - run once when cloning the repo
	@echo "→ Copying .env.example to .env"
	@test -f .env || cp .env.example .env
	@echo "→ Installing Python dependencies"
	uv sync
	@echo "→ Installing pre-commit hooks"
	uv run pre-commit autoupdate
	uv run pre-commit install
	@echo "✓ Setup complete. Run: make start"


# ─── Lifecycle ───────────────────────────────────────

start:          ## Start all services in the background (detached mode)
	$(COMPOSE) up -d
	@echo ""
	@echo "  Temporal UI → http://localhost:8080"
	@echo "  Postgres    → localhost:5432"
	@echo "  Datacollection Python App logs    → make logs"

stop:           ## Stop all services (don't remove containers, keep data)
	$(COMPOSE) down

restart:        ## Restart all services (stop + start)
	$(COMPOSE) restart

build:          ## Rebuild app image (use if you changed Dockerfile or dependencies)
	$(COMPOSE) build $(APP_SERVICE)

ps:             ## Status of the running containers
	$(COMPOSE) ps

logs:           ## Tracking logs of all services (app + temporal, Ctrl+C for stop)
	$(COMPOSE) logs -f

logs-app:       ## Tracking logs of the app service only (Ctrl+C for stop)
	$(COMPOSE) logs -f $(APP_SERVICE)

logs-temporal:  ## Tracking logs of the temporal service only (Ctrl+C for stop)
	$(COMPOSE) logs -f temporal

# ─── Database ────────────────────────────────────────────────

migrate:        ## Run all migrations (alembic upgrade head)
	$(COMPOSE) exec $(APP_SERVICE) uv run alembic upgrade head

migrate-down:   ## One migration back (alembic downgrade -1)
	$(COMPOSE) exec $(APP_SERVICE) uv run alembic downgrade -1

migrate-create: ## Make a new migration with autogenerate (alembic revision --autogenerate -m "message")
	$(COMPOSE) exec $(APP_SERVICE) uv run alembic revision --autogenerate -m "$(MSG)"

migrate-history:## Get the history of migrations (alembic history --verbose)
	$(COMPOSE) exec $(APP_SERVICE) uv run alembic history --verbose

# ─── Testing & quality ───────────────────────────────────────

test:           ## Run all tests with coverage report (uv run pytest --cov=src --cov-report=term-missing -v)
	uv run pytest --cov=src --cov-report=term-missing -v

test-fast:      ## Run tests without coverage (faster, uv run pytest -x -q)
	uv run pytest -x -q

lint:           ## Run all pre-commit hooks (Ruff, Secrets, etc.) and Pyright
	uv run pre-commit run --all-files
	uv run pyright src/

format:         ## Automatically fix formatting and linting issues
	uv run ruff format .
	uv run ruff check --fix .

# ─── Shells ──────────────────────────────────────────────────

shell-app:      ## Open shell inside the app container (bash)
	$(COMPOSE) exec $(APP_SERVICE) /bin/bash

shell-db:       ## Open psql shell inside the postgres container (psql -U user -d db)
	$(COMPOSE) exec $(DB_SERVICE) psql -U $${POSTGRES_USER:-sandbox} -d $${POSTGRES_DB:-sandbox_db}

# ─── Cleanup ─────────────────────────────────────────────────

clean:          ## Remove all stopped containers, dangling images, and unused volumes (docker system prune -a --volumes)
	$(COMPOSE) down --rmi local

reset:          ## ⚠ REMOVE ALL DATA - Stop containers, remove them, and delete all volumes (docker compose down -v)
	@echo "⚠ This will remove ALL from the database. Continue? [y/N]"
	@read ans && [ $${ans:-N} = y ] || exit 1
	$(COMPOSE) down -v
	@echo "✓ Reset completed. Run: make start && make migrate"