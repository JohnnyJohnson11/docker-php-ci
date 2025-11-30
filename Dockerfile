# syntax=docker/dockerfile:1

FROM composer:lts as deps
WORKDIR /app

RUN --mount=type=bind,source=composer.json,target=composer.json \
    --mount=type=bind,source=composer.lock,target=composer.lock \
    --mount=type=cache,target=/tmp/cache \
    composer install --no-dev --no-interaction --prefer-dist

FROM php:8.2-apache-bullseye AS final

# Enable PDO MySQL without system package installs
RUN docker-php-ext-install pdo_mysql

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN a2enmod rewrite

COPY --from=deps /app/vendor/ /var/www/html/vendor
COPY ./src /var/www/html

RUN chown -R www-data:www-data /var/www/html
USER www-data
WORKDIR /var/www/html

