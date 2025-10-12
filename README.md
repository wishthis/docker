![wish**this** logo](https://raw.githubusercontent.com/wishthis/wishthis/develop/src/assets/img/logo-readme.svg "wish**this** logo")

# wish**this** - [Official docker image](https://hub.docker.com/r/hiob/wishthis)
[wish**this**](https://wishthis.online/) is a simple, intuitive and modern wishlist platform to create, manage and view your wishes for any kind of occasion.

## wish**this** : documentation and setup
Always refer you to [wish**this** documentation](https://github.com/wishthis/wishthis/).

## Docker : usage
You can find support and an updated documentation on our [Github's repository](https://github.com/wishthis/docker/).
We host our docker images on [Docker's hub](https://hub.docker.com/r/hiob/wishthis) or [ghcr.io](https://ghcr.io/wishthis/docker)

Three tags/images are avalaible: 
- **develop** : for Wish**this**'s [*develop branch*](https://github.com/wishthis/wishthis/tree/develop)
- **release-candidate** : for Wish**this**'s [*release-candidate branch*](https://github.com/wishthis/wishthis/tree/release-candidate) **RECOMMENDED**
- **stable** : for Wish**this**'s [*stable branch*](https://github.com/wishthis/wishthis/tree/stable)

### Docker-compose : wish**this** with MariaDB
Install docker-compose version 2. Example with apt: `sudo apt install docker-compose-v2`. Always refer to the [Docker compose documentation](https://docs.docker.com/compose/reference/). 

Here a sample of [docker-compose.yml.sample](sample/docker-compose.yml.sample). MySQL/MariaDB server isn't included in image, you should set it in another container, this is done in the linked docker-compose sample.

1. Copy the [docker-compose.yml](sample/docker-compose.yml.sample) to a folder on your docker host, name it `docker-compose.yml`.
2. Edit the file and configure your MySQL compatible MariaDB's connection settings, by altering the values of `MARIADB_ROOT_PASSWORD`, `MARIADB_DATABASE`, `MARIADB_USER` and `MARIADB_PASSWORD`.
3. Copy [config-sample.php](https://github.com/wishthis/wishthis/blob/develop/src/config/config-sample.php) into a file called `config-sample.php` in the same folder as `docker-compose.yml`
4. Run `docker-compose up -d`

Wishthis will be available to http://localhost:80. 

5. Follow the installation guide. Select MySQL and enter the values from the MariaDB configuration in your `docker-compose.yml`. 

You can use a reverse proxy ([Nginx](https://www.nginx.com/),[ Traefik](https://doc.traefik.io/traefik/getting-started/quick-start/), [SWAG](https://docs.linuxserver.io/general/swag)...) to serve wishthis with is own (sub)domain name. 

### Docker-compose : wish**this** with SQLite
Install docker-compose version 2.
1. Copy the [docker-compose-sqlite.yml](sample/docker-compose-sqlite.yml) to a folder on your docker host, name it `docker-compose.yml`.
2. Copy [config-sample.php](https://github.com/wishthis/wishthis/blob/develop/src/config/config-sample.php) into a file called `config-sample.php` in the same folder as `docker-compose.yml`
3. Run `docker-compose up -d`

Wishthis will be available to http://localhost:80. 

> **NOTE**: The SQLite database will reside inside the container in `/var/www/html/database.sqlite`. To make your database persistent between containers, you should extract the file to your docker host and then mount it as a volume. (see [docker-compose.yml example](sample/docker-compose-sqlite-dbvol.yml)). This extra step can be eliminated when [this issue](https://github.com/wishthis/wishthis/issues/232) has been resolved.

### Docker CLI : wish**this** with SQLite

1. Copy [config-sample.php](https://github.com/wishthis/wishthis/blob/develop/src/config/config-sample.php) into a file called `config-sample.php` in the same folder as `docker-compose.yml`
2. Run 
   ```
   docker run -d \
   --name wishthis \
   --restart unless-stopped \
   -e VIRTUAL_HOST=sub.domain.ext \
   -p 80:80 \
   -v "$(pwd)/config/:/var/www/html/src/config/" \
   hiob/wishthis:develop
   ```

> **NOTE**: The SQLite database will reside inside the container in `/var/www/html/database.sqlite`. To make your database persistent between containers, you should extract the file to your docker host and then mount it as a volume. This extra step can be eliminated when [this issue](https://github.com/wishthis/wishthis/issues/232) has been resolved. To mount this extra file with the docker CLI also, the full command will be:
   ```
   docker run -d \
   --name wishthis \
   --restart unless-stopped \
   -e VIRTUAL_HOST=sub.domain.ext \
   -p 80:80 \
   -v "$(pwd)/config/:/var/www/html/src/config/" \
   -v "$(pwd)/database.sqlite:/var/www/htmldatabase.sqlite" \
   hiob/wishthis:develop
   ```