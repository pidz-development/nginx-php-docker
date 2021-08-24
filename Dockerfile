FROM amd64/php:8.0.9-fpm-alpine

RUN set -xe \
    && apk add --no-cache \
        nginx \
        git \
        openssh-client \
        supervisor \
        icu \
        libpng \
        libjpeg \
        libzip \
        freetype \
        msttcorefonts-installer \
        fontconfig \
        wkhtmltopdf \
        xvfb \
        jq \
        nodejs \
        yarn \
    && update-ms-fonts \
    && fc-cache -f

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        g++ \
        gcc \
        make \
        autoconf \
        libpng-dev \
        libxml2-dev \
        icu-dev \
        libzip-dev \
        freetype-dev \
        libjpeg-turbo-dev \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd soap pdo_mysql intl zip opcache xml iconv \
    && apk del --no-network .build-deps

RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN curl https://getcomposer.org/download/1.10.17/composer.phar -o composer.phar -s && mv composer.phar /usr/local/bin/composer && chmod 755 /usr/local/bin/composer

COPY etc /etc/
COPY usr /usr/

EXPOSE 80

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
