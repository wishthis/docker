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
ENV WISHTHIS_INSTALL /var/www/html
ENV WISHTHIS_CONFIG /var/www/html/src/config/
RUN chown -R www-data:www-data $WISHTHIS_INSTALL

WORKDIR $WISHTHIS_INSTALL

# Enabling Apache vhost
ARG HOSTNAME wishthis.localhost
ENV HOSTNAME $HOSTNAME
COPY wishthis.conf /etc/apache2/sites-available/wishthis.conf
RUN sed -i 's/wishthis.localhost/wishthis.${HOSTNAME}/' /etc/apache2/sites-available/wishthis.conf \
    && a2dissite * && a2ensite wishthis.conf \
    && a2enmod rewrite
RUN echo "ServerName wishthis.localhost" >> /etc/apache2/apache2.conf \
    && service apache2 restart

## Timezone
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Change user
USER www-data

# Git clone grandeljay/wishthis (default stable branch)
ARG WISHTHIS_GITBRANCH stable
ENV WISHTHIS_GITBRANCH $WISHTHIS_GITBRANCH
RUN git --version && echo ...Cloning $WISHTHIS_GITBRANCH branch...
RUN git clone -b $WISHTHIS_GITBRANCH https://github.com/grandeljay/wishthis.git .
   
# Expose port
EXPOSE 80

# Volume
VOLUME $WISHTHIS_CONFIG

# Launch
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
