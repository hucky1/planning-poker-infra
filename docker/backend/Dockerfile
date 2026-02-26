ARG PHP_VERSION=8.5-fpm
ARG COMPOSER_VERSION=2

FROM php:${PHP_VERSION}

WORKDIR /workspace

RUN apt-get update \
  && apt-get install -y --no-install-recommends git unzip libicu-dev libzip-dev \
  && docker-php-ext-install intl pdo pdo_mysql opcache zip \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \
  && rm -rf /var/lib/apt/lists/*

COPY --from=composer:${COMPOSER_VERSION} /usr/bin/composer /usr/bin/composer
COPY docker/backend/start-backend.sh /usr/local/bin/start-backend
RUN chmod +x /usr/local/bin/start-backend

CMD ["start-backend"]
