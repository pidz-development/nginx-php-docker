FROM php:7.2-fpm-alpine

RUN set -xe \
    && apk add --no-cache \
        nginx \
        supervisor \
        icu \
        libpng \
        libjpeg \
        freetype

# Install dependencies
RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        g++ \
        gcc \
        make \
        autoconf \
        libpng-dev \
        libxml2-dev \
        icu-dev \
        freetype-dev \
        libjpeg-turbo-dev \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd soap pdo_mysql intl zip opcache xml \
    && apk del --no-network .build-deps

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# https://github.com/gliderlabs/docker-alpine/issues/185#issuecomment-246595114
RUN mkdir -p /run/nginx

COPY etc /etc/

EXPOSE 80

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
