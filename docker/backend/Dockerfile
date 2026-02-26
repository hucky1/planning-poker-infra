ARG PHP_VERSION=8.5-fpm-alpine
ARG COMPOSER_VERSION=2
ARG INSTALL_XDEBUG=0

FROM composer:${COMPOSER_VERSION} AS composer_bin
FROM php:${PHP_VERSION}

ARG INSTALL_XDEBUG=0

WORKDIR /workspace

RUN set -eux; \
  apk add --no-cache git unzip icu-dev libzip-dev postgresql-dev; \
  apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers; \
  docker-php-ext-install intl pdo pdo_pgsql opcache zip; \
  if [ "$INSTALL_XDEBUG" = "1" ]; then \
    git init /tmp/xdebug; \
    git -C /tmp/xdebug remote add origin https://github.com/xdebug/xdebug.git; \
    git -C /tmp/xdebug fetch --depth=1 origin "9f1bf000563a2be6b5318e86793e4a1024fa470e"; \
    git -C /tmp/xdebug checkout --detach FETCH_HEAD; \
    cd /tmp/xdebug; \
    phpize; \
    ./configure --enable-xdebug; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/xdebug; \
    docker-php-ext-enable xdebug; \
  fi; \
  apk del .build-deps

COPY --from=composer_bin /usr/bin/composer /usr/bin/composer
COPY docker/backend/start-backend.sh /usr/local/bin/start-backend
COPY docker/backend/xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini
RUN chmod +x /usr/local/bin/start-backend

CMD ["start-backend"]
