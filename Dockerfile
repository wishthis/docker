# Wishthis - Unofficial docker image
FROM php:8.1-apache

# Maintainer
LABEL maintainer "hiob <hello@hiob.fr>"
LABEL author "hiob <hello@hiob.fr>"

LABEL version "0.1.0"
LABEL description "PHP 8.1 / Apache 2 / Wishthis 0.6.0"

# Add required packages
RUN a2enmod rewrite
RUN apt update \
  && apt install -y apt-utils \ 
  curl \ 
  git \ 
  libfreetype6-dev \
  libicu-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  nano \
  tzdata \ 
  zlib1g-dev \
  && apt clean -y
  
# Add PHP extensions  
RUN docker-php-ext-configure intl \
 && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd gettext intl mysqli pdo pdo_mysql

# Working directory
ENV WISHTHIS_INSTALL /var/www/wishthis
ENV WISHTHIS_CONFIG /var/www/wishthis/src/config/
RUN mkdir $WISHTHIS_INSTALL && chown -R www-data:www-data $WISHTHIS_INSTALL
WORKDIR $WISHTHIS_INSTALL

# Changing DOCUMENT ROOT
ENV APACHE_DOCUMENT_ROOT /var/www/whisthis

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enabling Apache vhost
COPY wishthis.conf /etc/apache2/sites-available/wishthis.conf
RUN a2dissite * && a2ensite wishthis.conf \
    && a2enmod rewrite
RUN echo "ServerName wishthis.hiob.fr" >> /etc/apache2/apache2.conf \
    && service apache2 restart

## Timezone
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
 
# Change user
USER www-data

# Git clone grandeljay/wishthis (default stable branch)
ARG WISHTHIS_GITBRANCH develop
ENV WISHTHIS_GITBRANCH $WISHTHIS_GITBRANCH
RUN git --version && echo ...Cloning $WISHTHIS_GITBRANCH branch...
RUN git clone -b $WISHTHIS_GITBRANCH https://github.com/grandeljay/wishthis.git .

# Mount volume (config file)
VOLUME $WISHTHIS_CONFIG

# Expose port
EXPOSE 80

# Launch
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
