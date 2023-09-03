![wishthis logo](https://raw.githubusercontent.com/wishthis/wishthis/develop/src/assets/img/logo-readme.svg "wishthis logo")

# wishthis - [official docker image](https://hub.docker.com/r/hiob/wishthis)
[wishthis](https://wishthis.online/) is a simple, intuitive and modern wishlist platform to create, manage and view your wishes for any kind of occasion.

## wishthis : documentation and setup
Always refer you to [wishthis documentation](https://github.com/wishthis/wishthis/).

## Docker : usage
You can find support and an updated documentation on our [Github's repository](https://github.com/wishthis/docker/).

### Docker-compose
Here a sample of [docker-compose.yml](sample/docker-compose.yml.sample) :

```
version: '3.7'

services:
  wishthis:
    container_name: wishthis
    restart: unless-stopped
    image: hiob/wishthis:latest
    ports:
      - 80:80
    volumes:
      - ./config.php:/var/www/html/src/config/config.php
```

### Permanent configuration

To keep your database configuration  permanent, mount a volume (see example above), create a file named `config.php` and copy the [`config-sample.php` from Github's repo](https://github.com/wishthis/wishthis/blob/develop/src/config/config-sample.php).
