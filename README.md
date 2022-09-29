# ![](https://git.nefald.fr/uploads/-/system/project/avatar/229/wishthis_logo.png?width=48) Wishthis - Unofficial docker image

[Wishthis](https://wishthis.online/) is a simple, intuitive and modern wishlist platform to create, manage and view your wishes for any kind of occasion.



## Wishthis : documentation and setup
Always refer you to [Wishthis documentation](https://github.com/grandeljay/wishthis/).

## Usage
You can find support and an updated documentation on our [Gitlab](https://git.nefald.fr/docker/wishthis).

### Docker-compose
Here a sample of `docker-compose.yml` :

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
