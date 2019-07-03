FROM php:7.2-fpm-alpine

RUN set -xe \
    && apk add --no-cache \
        nginx \
        supervisor \
        icu \
        libpng \
        libjpeg \
        freetype \
        msttcorefonts-installer \
        fontconfig \
        wkhtmltopdf \
        xvfb \
        jq \
    && update-ms-fonts \
    && fc-cache -f

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
        libssh2-dev \
    && curl -O https://pecl.php.net/get/ssh2-1.1.2.tgz \
        && tar vxzf ssh2-1.1.2.tgz \
        && cd ssh2-1.1.2 \
        && phpize \
        && ./configure --with-ssh2 \
        && make \
        && make install \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis ssh2 \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd soap pdo_mysql intl zip opcache xml iconv \
    && apk del --no-network .build-deps

RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

COPY etc /etc/
COPY usr /usr/

EXPOSE 80

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
