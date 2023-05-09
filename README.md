# ![](https://git.nefald.fr/uploads/-/system/project/avatar/229/wishthis_logo.png?width=48) Wishthis - [Unofficial docker image](https://hub.docker.com/r/hiob/wishthis)
[Wishthis](https://wishthis.online/) is a simple, intuitive and modern wishlist platform to create, manage and view your wishes for any kind of occasion.

## Wishthis : documentation and setup
Always refer you to [Wishthis documentation](https://github.com/grandeljay/wishthis/).

## Docker : usage
You can find support and an updated documentation on our [Gitlab](https://git.nefald.fr/docker/wishthis).

### Docker-compose
Here a sample of [docker-compose.yml](sample/docker-compose.yml.sample) :

```
version: '3.7'

services:
  wishthis:
    container_name: wishthis
    restart: unless-stopped
    image: hiob/wishthis:latest
    volumes:
      - ./config.php:/var/www/html/src/config/config.php
```

### Permanent configuration

To keep your database configuration  permanent, mount a volume (see example above), create a file named `config.php` and copy the [`config-sample.php` from Github's repo](https://github.com/grandeljay/wishthis/blob/develop/src/config/config-sample.php).
