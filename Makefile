COMPOSE_FILE ?= compose.dev.yaml
ENV_FILE ?= .env
DC = docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

.PHONY: help up down restart build ps logs backend-sh backend-root-sh symfony composer

help:
	@echo "Usage: make <target> [VAR=value]"
	@echo ""
	@echo "Core:"
	@echo "  make up                  Start local stack"
	@echo "  make down                Stop local stack"
	@echo "  make restart             Restart local stack"
	@echo "  make build               Build backend/frontend images"
	@echo "  make ps                  Show container status"
	@echo "  make logs                Tail all logs"
	@echo ""
	@echo "Backend:"
	@echo "  make backend-sh          Shell in backend container"
	@echo "  make backend-root-sh     Root shell in backend container"
	@echo "  make symfony CMD='about' Run Symfony console command"
	@echo "  make composer CMD='install' Run Composer command in backend"
	@echo ""
	@echo "Optional vars:"
	@echo "  COMPOSE_FILE=compose.dev.yaml ENV_FILE=.env"

up:
	$(DC) up -d --build

down:
	$(DC) down

restart:
	$(DC) down
	$(DC) up -d --build

build:
	$(DC) build backend frontend

ps:
	$(DC) ps

logs:
	$(DC) logs -f --tail=200

backend-sh:
	$(DC) exec backend sh

backend-root-sh:
	$(DC) exec -u root backend sh

symfony:
	@if [ -z "$(CMD)" ]; then echo "Usage: make symfony CMD='about'"; exit 1; fi
	$(DC) exec backend php bin/console $(CMD)

composer:
	@if [ -z "$(CMD)" ]; then echo "Usage: make composer CMD='install'"; exit 1; fi
	$(DC) exec backend composer $(CMD)
