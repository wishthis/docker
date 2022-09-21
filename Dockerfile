FROM php:8.2-rc-alpine

# MAINTAINER
LABEL maintainer="hiob <hello@hiob.fr>"
LABEL author="hiob <hello@hiob.fr>"

# Add dependencies
RUN apk update
RUN apk add --update-cache git \
  tzdata

# Working directory
RUN mkdir /var/www/whisthis
WORKDIR /var/www/whisthis

# Git clone Wishthis
RUN git --version
RUN git clone -b stable https://github.com/grandeljay/wishthis.git .

# Chown /var/www/whisthis
RUN chown -R www-data:www-data /var/www/whisthis

#Timezone default Env
ENV TZ Europe/Paris

# Change user
USER www-data

# Expose port
EXPOSE 80

# Launch service
CMD [ "php", "./index.php" ]
