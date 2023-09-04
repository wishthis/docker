![wishthis logo](https://raw.githubusercontent.com/wishthis/wishthis/develop/src/assets/img/logo-readme.svg "wishthis logo")

# wishthis - Official docker image
[wishthis](https://wishthis.online/) is a simple, intuitive and modern wishlist platform to create, manage and view your wishes for any kind of occasion.

## wishthis : documentation and setup
Always refer you to [wishthis documentation](https://github.com/wishthis/wishthis/).

## Docker : usage
You can find support and an updated documentation on our [Github's repository](https://github.com/wishthis/docker/).

We host ours docker images on these platforms:
 - [hub.docker.com/r/hiob/wishthis](https://hub.docker.com/r/hiob/wishthis)
 - [ghcr.io/wishthis/docker](https://ghcr.io/wishthis/docker)

Three tags/images are avalaibles: 
- **develop** : for Wishthis's [*develop branch*](https://github.com/wishthis/wishthis/tree/develop)
- **release-candidate** : for Wishthis's [*release-candidate branch*](https://github.com/wishthis/wishthis/tree/release-candidate)
- **stable** : for Wishthis's [*stable branch*](https://github.com/wishthis/wishthis/tree/stable)

### Docker-compose
Always refer you to [Docker compose documentation](https://docs.docker.com/compose/reference/)
Here a sample of [docker-compose.yml](sample/docker-compose.yml.sample) :

```
version: '3.7'

services:
  wishthis:
    container_name: wishthis
    restart: unless-stopped
    image: hiob/wishthis:stable
    ports:
      - 80:80
    volumes:
      - ./config.php:/var/www/html/src/config/config.php
```
At first launch, if you didn't create a Wishthis's configuration file by mounting a permanent volume, You will be invite to setup Wishthis and database.

### Permanent configuration

To keep your database configuration  permanent, mount a volume (see example above), create a file named `config.php` and copy the [`config-sample.php` from Github's repo](https://github.com/wishthis/wishthis/blob/develop/src/config/config-sample.php).
