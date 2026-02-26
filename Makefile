COMPOSE_FILE ?= compose.dev.yaml
ENV_FILE ?= .env
DC = docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

.PHONY: help up down restart build ps logs backend-sh backend-root-sh symfony composer xdebug-on xdebug-off xdebug-status

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
	@echo "  make xdebug-on           Enable Xdebug (rebuild backend)"
	@echo "  make xdebug-off          Disable Xdebug (rebuild backend)"
	@echo "  make xdebug-status       Show Xdebug status in backend container"
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

xdebug-on:
	@set -e; \
	if [ ! -f "$(ENV_FILE)" ]; then echo "$(ENV_FILE) not found"; exit 1; fi; \
	if grep -q '^INSTALL_XDEBUG=' "$(ENV_FILE)"; then \
	  sed -i.bak 's/^INSTALL_XDEBUG=.*/INSTALL_XDEBUG=1/' "$(ENV_FILE)"; \
	else \
	  printf '\nINSTALL_XDEBUG=1\n' >> "$(ENV_FILE)"; \
	fi; \
	if grep -q '^XDEBUG_MODE=' "$(ENV_FILE)"; then \
	  sed -i.bak 's/^XDEBUG_MODE=.*/XDEBUG_MODE=debug,develop/' "$(ENV_FILE)"; \
	else \
	  printf 'XDEBUG_MODE=debug,develop\n' >> "$(ENV_FILE)"; \
	fi; \
	rm -f "$(ENV_FILE).bak"
	$(DC) build --no-cache backend
	$(DC) up -d --force-recreate backend
	$(MAKE) xdebug-status

xdebug-off:
	@set -e; \
	if [ ! -f "$(ENV_FILE)" ]; then echo "$(ENV_FILE) not found"; exit 1; fi; \
	if grep -q '^XDEBUG_MODE=' "$(ENV_FILE)"; then \
	  sed -i.bak 's/^XDEBUG_MODE=.*/XDEBUG_MODE=off/' "$(ENV_FILE)"; \
	else \
	  printf 'XDEBUG_MODE=off\n' >> "$(ENV_FILE)"; \
	fi; \
	rm -f "$(ENV_FILE).bak"
	$(DC) up -d --force-recreate backend
	$(MAKE) xdebug-status

xdebug-status:
	$(DC) exec -T backend sh -lc 'php -v | sed -n "1,8p"; echo "---"; php -m | grep -i xdebug || true; echo "---"; php --ri xdebug 2>/dev/null | sed -n "1,50p" || echo "Xdebug not installed/enabled"'
