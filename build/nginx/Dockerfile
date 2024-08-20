FROM php:8.3-fpm-alpine
ARG WORKDIR=/var/www/html
ARG APPDIR=$WORKDIR/app
ENV DOCUMENT_ROOT=${WORKDIR}
ENV LARAVEL_PROCS_NUMBER=1
ARG GROUP_ID=1000
ARG USER_ID=1000
ENV USER_NAME=www-data
ARG GROUP_NAME=www-data

RUN apk add --update npm 
RUN apk add --update --no-cache linux-headers $PHPIZE_DEPS
RUN apk add --update supervisor
RUN apk add --update nginx
RUN apk add --update openssh git

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql
RUN pecl install xdebug-3.3.2 && docker-php-ext-enable xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR $WORKDIR

# GIT SETUP
COPY src/git/gitconfig /root/.gitconfig
RUN mkdir -p /root/.ssh
ADD src/git/rw_deploy /root/.ssh/id_rsa
ADD src/git/ssh_config /etc/ssh/ssh_config.d/
RUN chmod 600 /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN git config --global init.defaultBranch main


RUN rm -Rf /var/www/* && mkdir -p /var/www/html
RUN mkdir -p /var/log/supervisor

RUN composer create-project laravel/laravel app
WORKDIR $APPDIR
RUN composer require laravel/jetstream

RUN php ./artisan jetstream:install inertia --dark
RUN npm install
RUN npm run build

RUN mkdir -p /etc/supervisor/conf.d/
ADD src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD src/php.ini $PHP_INI_DIR/conf.d/php.ini
ADD src/nginx/default.conf /etc/nginx/http.d/default.conf
ADD src/nginx/nginx.conf /etc/nginx/nginx.conf
ADD src/laravel/vite.config.js $APPDIR/
COPY src/laravel/.env $APPDIR/.env

RUN chown -R www-data:www-data storage database
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
