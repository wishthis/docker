# Wishthis - Official optimized docker image
FROM php:8.2-apache-bullseye AS builder

# Git branch argument system
ARG WISHTHIS_GITBRANCH=stable
ENV WISHTHIS_GITBRANCH=$WISHTHIS_GITBRANCH

# System configuration and dependency installation in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    sendmail \
    tzdata \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && a2enmod rewrite \
  # PHP extensions configuration and installation in the same layer
  && docker-php-ext-configure intl \
  && docker-php-ext-install -j$(nproc) exif gettext iconv intl mysqli pdo pdo_mysql \
  && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd \
  # Sendmail configuration
  && echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini \
  # Timezone configuration
  && ln -snf /usr/share/zoneinfo/Europe/Paris /etc/localtime \
  && echo "Europe/Paris" > /etc/timezone \
  # Apache configuration
  && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Environment configuration
ENV WISHTHIS_INSTALL=/var/www/html
ENV WISHTHIS_CONFIG=/var/www/html/src/config/

# Copy and enable Apache configuration
COPY config/wishthis.conf /etc/apache2/sites-available/wishthis.conf
RUN a2ensite wishthis.conf

# Clone Wishthis project from GitHub
WORKDIR $WISHTHIS_INSTALL
RUN git clone -b $WISHTHIS_GITBRANCH https://github.com/wishthis/wishthis.git .

# Prepare entrypoint script
COPY script/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Final image build
FROM php:8.2-apache-bullseye

# Metadata
LABEL maintainer="hiob <50a7f360-a150-43e4-8aa0-5e837f6c061c@corbeille.xyz>"
LABEL author="hiob <50a7f360-a150-43e4-8aa0-5e837f6c061c@corbeille.xyz>"
LABEL description="PHP 8.2 / Apache 2 / Wishthis (${WISHTHIS_GITBRANCH})"

# Environment variables
ENV WISHTHIS_INSTALL=/var/www/html
ENV WISHTHIS_CONFIG=/var/www/html/src/config/
ENV TZ=Europe/Paris

# Install minimal required packages for runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    sendmail \
    tzdata \
  && rm -rf /var/lib/apt/lists/* \
  # Apache configuration
  && a2enmod rewrite \
  # Sendmail configuration
  && echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini \
  # Timezone configuration
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

# Copy PHP extensions and Apache configuration from build stage
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /etc/apache2/sites-available/wishthis.conf /etc/apache2/sites-available/
COPY --from=builder /etc/apache2/apache2.conf /etc/apache2/
RUN a2ensite wishthis.conf

# Copy application source code
COPY --from=builder $WISHTHIS_INSTALL $WISHTHIS_INSTALL
COPY --from=builder /usr/local/bin/entrypoint.sh /usr/local/bin/

# Set appropriate permissions
RUN chown -R www-data:www-data $WISHTHIS_INSTALL

# Configure volume for config files
VOLUME $WISHTHIS_CONFIG

# Expose HTTP port
EXPOSE 80

# Use www-data as default user
USER www-data

# Entrypoint and default command
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

