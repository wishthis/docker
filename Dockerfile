# Wishthis - Optimized docker image with Supervisord and flexible MTA
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

# Clone Wishthis project from GitHub - depth=1 for faster cloning
WORKDIR $WISHTHIS_INSTALL
RUN git clone -b $WISHTHIS_GITBRANCH --depth=1 https://github.com/wishthis/wishthis.git .

# Install Composer and PHP Mailer for flexible mail configuration
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN cd $WISHTHIS_INSTALL && composer require --no-interaction phpmailer/phpmailer

# Prepare configuration files
COPY script/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/mail_config.php $WISHTHIS_INSTALL/src/config/mail_config.php
RUN chmod +x /usr/local/bin/entrypoint.sh

# Final image build
FROM php:8.2-apache-bullseye

# Metadata
LABEL maintainer="hiob <50a7f360-a150-43e4-8aa0-5e837f6c061c@corbeille.xyz>"
LABEL author="hiob <50a7f360-a150-43e4-8aa0-5e837f6c061c@corbeille.xyz>"
LABEL description="PHP 8.2 / Apache 2 / Wishthis with Supervisord and flexible MTA"

# Environment variables
ENV WISHTHIS_INSTALL=/var/www/html
ENV WISHTHIS_CONFIG=/var/www/html/src/config/
ENV TZ=Europe/Paris
# Mail configuration environment variables with defaults
ENV USE_EXTERNAL_SMTP=false
ENV MAIL_HOST=localhost
ENV MAIL_PORT=25
ENV MAIL_ENCRYPTION=
ENV MAIL_USERNAME=
ENV MAIL_PASSWORD=
ENV MAIL_FROM_ADDRESS=admin@wishthis.local
ENV MAIL_FROM_NAME=Wishthis

# Install minimal required packages for runtime including supervisord
RUN apt-get update && apt-get install -y --no-install-recommends \
    sendmail \
    tzdata \
    sudo \
    supervisor \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  # Apache configuration
  && a2enmod rewrite \
  # Timezone configuration
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

# Copy PHP extensions and Apache configuration from build stage
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /etc/apache2/sites-available/wishthis.conf /etc/apache2/sites-available/
COPY --from=builder /etc/apache2/apache2.conf /etc/apache2/
RUN a2ensite wishthis.conf

# Copy application source code and configurations
COPY --from=builder $WISHTHIS_INSTALL $WISHTHIS_INSTALL
COPY --from=builder /usr/local/bin/entrypoint.sh /usr/local/bin/
COPY --from=builder /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer

# Set up log directories for supervisor
RUN mkdir -p /var/log/supervisor

# Set appropriate permissions
RUN chown -R www-data:www-data $WISHTHIS_INSTALL \
    && chown -R www-data:www-data /var/log/supervisor

# Add www-data to sudoers
RUN adduser www-data sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Configure volume for config files
VOLUME $WISHTHIS_CONFIG

# Healthcheck to ensure services are running
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD supervisorctl status all | grep -q "RUNNING" || exit 1

# Expose HTTP port
EXPOSE 80

# Entrypoint and default command
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

