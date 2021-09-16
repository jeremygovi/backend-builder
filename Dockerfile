FROM php:7.4-fpm-alpine as backend_builder

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# Install some base packages
RUN apk add \
    make \
    git \
    openssh-client \
    curl \
    yarn \
    autoconf \
    g++ \
    postgresql-dev \
    libpng-dev \
    libxml2-dev

RUN echo "Europe/Paris" > /etc/timezone

RUN pecl install redis-5.1.1 apcu \
    && docker-php-ext-enable redis apcu

RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pgsql \
    intl \
    gd \
    soap

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Fix some php limits
RUN echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini
RUN echo "max_execution_time=900" >> /usr/local/etc/php/conf.d/docker-php-max_execution_time.ini
RUN sed -i s/'max_execution_time = 30'/'max_execution_time = 300'/g /usr/local/etc/php/php.ini*
