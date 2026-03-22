FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    nodejs \
    npm \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY . /app

# Create paths Composer expects from composer.json
RUN mkdir -p app/Support database/seeds database/factories

# Create missing helpers file so Composer autoload does not fail
RUN [ -f app/Support/helpers.php ] || printf "<?php\n" > app/Support/helpers.php

RUN composer install --no-dev --no-scripts --no-autoloader
RUN composer dump-autoload --optimize

RUN npm ci && npm run production

RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}