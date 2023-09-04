# Wishthis - Official docker image
FROM php:8.1-apache

# Maintainer
LABEL maintainer "hiob <hello@hiob.fr>"
LABEL author "hiob <hello@hiob.fr>"

LABEL description "PHP 8.1 / Apache 2 / Wishthis ($WISHTHIS_GITBRANCH)"

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
  sendmail \
  sudo \
  tzdata \ 
  zlib1g-dev \
  && apt clean -y
  
# Add PHP extensions  
RUN docker-php-ext-configure intl \
 && docker-php-ext-install -j$(nproc) exif gettext iconv intl mysqli pdo pdo_mysql \
 && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
 && docker-php-ext-install -j$(nproc) gd
 
# Working directory
ENV WISHTHIS_INSTALL /var/www/html
ENV WISHTHIS_CONFIG /var/www/html/src/config/
RUN chown -R www-data:www-data $WISHTHIS_INSTALL

# Enabling Apache vhost
COPY config/wishthis.conf /etc/apache2/sites-available/wishthis.conf
RUN a2enmod rewrite
WORKDIR /etc/apache2/sites-available/
RUN a2ensite wishthis.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN service apache2 restart

# Configure Sendmail for MJML
RUN echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

## Timezone
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Change work directory
WORKDIR $WISHTHIS_INSTALL

# Add www-data to sudoers
RUN adduser www-data sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Change user to www-data (quickly than chown)
USER www-data

# GET WISHTHIS
## Git clone grandeljay/wishthis (default stable branch)
ARG WISHTHIS_GITBRANCH=stable
ENV WISHTHIS_GITBRANCH $WISHTHIS_GITBRANCH
RUN git --version && echo '...Cloning $WISHTHIS_GITBRANCH branch...'
RUN git clone -b $WISHTHIS_GITBRANCH https://github.com/wishthis/wishthis.git .

# Mount volume (config file)
VOLUME $WISHTHIS_CONFIG

# Expose port
EXPOSE 80

# ENTRYPOINT / CMD
COPY script/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sudo chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]


