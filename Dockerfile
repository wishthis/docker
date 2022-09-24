# Wishthis - Unofficial docker image
FROM php:8.1-apache

# Maintainer
LABEL maintainer="hiob <hello@hiob.fr>"
LABEL author="hiob <hello@hiob.fr>"

LABEL version="0.1.0"
LABEL description="PHP 8.1 / Apache 2 / Wishthis 0.6.0"

# Add required packages
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
RUN mkdir $WISHTHIS_INSTALL
RUN chown -R www-data:www-data $WISHTHIS_INSTALL
WORKDIR $WISHTHIS_INSTALL

# Enabling Apache vhost
COPY wishthis.conf /etc/apache2/sites-available/wishthis.conf
RUN sed -i 's/wishthis.localhost/wishthis.${HOSTNAME}/' /etc/apache2/sites-available/wishthis.conf \
    && a2dissite * && a2ensite wishthis.conf
    
# Changing DOCUMENT ROOT
ENV APACHE_DOCUMENT_ROOT $WISHTHIS_INSTALL
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN echo "ServerName wishthis.localhost" >> /etc/apache2/apache2.conf \
    && a2enmod rewrite \
    && service apache2 restart

## Timezone
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Change user
USER www-data

# Git clone Wishthis
ENV WISHTHIS_GITBRANCH develop
RUN git --version
RUN git clone -b $WISHTHIS_GITBRANCH https://github.com/grandeljay/wishthis.git .

# Expose port
EXPOSE 80

# Volume
VOLUME $WISHTHIS_CONFIG

# Launch
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
