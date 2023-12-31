![wishthis logo](https://raw.githubusercontent.com/wishthis/wishthis/develop/src/assets/img/logo-readme.svg "wishthis logo")

# wishthis - [Official docker image](https://hub.docker.com/r/hiob/wishthis)
[wishthis](https://wishthis.online/) is a simple, intuitive and modern wishlist platform to create, manage and view your wishes for any kind of occasion.

## wishthis : documentation and setup
Always refer you to [wishthis documentation](https://github.com/wishthis/wishthis/).

## Docker : usage
You can find support and an updated documentation on our [Github's repository](https://github.com/wishthis/docker/).
We host ours docker images on [Docker's hub](https://hub.docker.com/r/hiob/wishthis) or [ghcr.io](https://ghcr.io/wishthis/docker)

Three tags/images are avalaibles: 
- **develop** : for Wishthis's [*develop branch*](https://github.com/wishthis/wishthis/tree/develop)
- **release-candidate** : for Wishthis's [*release-candidate branch*](https://github.com/wishthis/wishthis/tree/release-candidate) **RECOMMENDED**
- **stable** : for Wishthis's [*stable branch*](https://github.com/wishthis/wishthis/tree/stable)

### Docker-compose
Always refer you to [Docker compose documentation](https://docs.docker.com/compose/reference/).

Here a sample of [docker-compose.yml](sample/docker-compose.yml.sample). MySQL server isn't included in image, you should set it in another container :


```
version: '3.7'

services:
  wishthis:
    container_name: wishthis
    restart: unless-stopped
    image: hiob/wishthis:stable
    environment:
      - VIRTUAL_HOST=sub.domain.ext
    ports:
      - 80:80
    volumes:
      - ./config.php:/var/www/html/src/config/config.php
    networks:
      - wishthis
      
  mariadb:
    container_name: db
    restart: unless-stopped
    image: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: rootpassword
      MARIADB_DATABASE: databasename
      MARIADB_USER: username
      MARIADB_PASSWORD: userpassword
    volumes:
      - ./data:/var/lib/mysql
    ports:
      - 3306:3306
    networks:
      - wishthis

networks:
  wishthis:
    external: true
```

Wishthis will be available to http://localhost:80. 

You can use a reverse proxy ([Nginx](https://www.nginx.com/),[ Traefik](https://doc.traefik.io/traefik/getting-started/quick-start/), [SWAG](https://docs.linuxserver.io/general/swag)...) to serve wishthis with is own (sub)domain name. 

### Permanent configuration
At first launch, if you didn't create a Wishthis's configuration file by mounting a permanent volume, You will be invite to setup Wishthis and database.

To keep your database configuration  permanent, mount a volume (see example above), create a file named `config.php` and copy the [`config-sample.php` from Github's repo](https://github.com/wishthis/wishthis/blob/develop/src/config/config-sample.php).
