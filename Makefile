COMPOSE_FILE ?= compose.dev.yaml
ENV_FILE ?= .env
DC = docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

.PHONY: help up down restart build ps logs backend-sh backend-root-sh backend-lint backend-lint-staged backend-phpstan backend-deptrac backend-phpcs backend-cs-fixer backend-fix backend-hooks-install frontend-sh frontend-root-sh frontend-logs symfony composer npm frontend-build frontend-lint xdebug-on xdebug-off xdebug-status

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
	@echo "  make backend-lint        Run all backend static checks"
	@echo "  make backend-lint-staged Run backend static checks for staged PHP files"
	@echo "  make backend-phpstan     Run PHPStan (level 8)"
	@echo "  make backend-deptrac     Run architecture dependency check"
	@echo "  make backend-phpcs       Run PHP_CodeSniffer"
	@echo "  make backend-cs-fixer    Run PHP-CS-Fixer in dry-run mode"
	@echo "  make backend-fix         Run PHPCBF + PHP-CS-Fixer autofixers"
	@echo "  make backend-hooks-install Install backend git hooks path"
	@echo ""
	@echo "Frontend:"
	@echo "  make frontend-sh         Shell in frontend container"
	@echo "  make frontend-root-sh    Root shell in frontend container"
	@echo "  make frontend-logs       Tail frontend logs"
	@echo "  make npm CMD='run build' Run npm command in frontend"
	@echo "  make frontend-build      Build Next.js app in frontend container"
	@echo "  make frontend-lint       Lint frontend app in frontend container"
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

frontend-sh:
	$(DC) exec frontend sh

frontend-root-sh:
	$(DC) exec -u root frontend sh

frontend-logs:
	$(DC) logs -f --tail=200 frontend

symfony:
	@if [ -z "$(CMD)" ]; then echo "Usage: make symfony CMD='about'"; exit 1; fi
	$(DC) exec backend php bin/console $(CMD)

composer:
	@if [ -z "$(CMD)" ]; then echo "Usage: make composer CMD='install'"; exit 1; fi
	$(DC) exec backend composer $(CMD)

backend-lint:
	$(DC) exec backend composer lint:all

backend-lint-staged:
	$(DC) exec backend ./bin/static-check --staged

backend-phpstan:
	$(DC) exec backend composer lint:phpstan

backend-deptrac:
	$(DC) exec backend composer lint:deptrac

backend-phpcs:
	$(DC) exec backend composer lint:phpcs

backend-cs-fixer:
	$(DC) exec backend composer lint:cs-fixer

backend-fix:
	$(DC) exec backend composer fix:all

backend-hooks-install:
	git -C planning-poker-backend config core.hooksPath .githooks
	git -C planning-poker-backend config --get core.hooksPath

npm:
	@if [ -z "$(CMD)" ]; then echo "Usage: make npm CMD='run build'"; exit 1; fi
	$(DC) exec frontend npm $(CMD)

frontend-build:
	$(DC) exec frontend npm run build

frontend-lint:
	$(DC) exec frontend npm run lint

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
