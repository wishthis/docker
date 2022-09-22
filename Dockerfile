# Wishthis - Unofficial docker image
FROM php:8.1-fpm

# Maintainer
LABEL maintainer="hiob <hello@hiob.fr>"
LABEL author="hiob <hello@hiob.fr>"

# Add required packages
RUN apt update \
  && apt install -y curl \
  git \
  libicu-dev \
  libpng-dev \
  mysqli \
  tzdata \
  zlib1g-dev \
  && apt clean -y \
  
# Add PHP extensions  
RUN docker-php-ext-configure intl \
 && docker-php-ext-install intl mysqli pdo_mysql

# Working directory
WORKDIR /var/www/html

# Chown /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Change user
USER www-data

# Git clone Wishthis
RUN git --version
RUN git clone -b stable https://github.com/grandeljay/wishthis.git .
# Add PHPinfo (dev purpose)
COPY ./phpinfo.php phpinfo.php

#Timezone default Env
ENV TZ Europe/Paris

# Expose port
EXPOSE 80

# Launch
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
