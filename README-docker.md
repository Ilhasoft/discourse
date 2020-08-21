# What is Discourse?

Discourse is an open source Internet forum and mailing list management software application founded in 2013 by Jeff Atwood, Robin Ward, and Sam Saffron. Discourse received funding from First Round Capital and Greylock Partners. The application is written with Ember.js and Ruby on Rails.

> [https://en.wikipedia.org/wiki/Discourse_(software)](https://en.wikipedia.org/wiki/Discourse_(software))

![logo](https://www.discourse.org/a/img/favicon.png)


# How to use this image

## start a discourse instance

```console
$ docker run --name discourse -e DISCOURSE_DB_HOST=10.0.0.10 -d psychomantys/discourse:2.5.0-buster-slim
```

The default `discourse` will connect to a test `redis` and `postgres` servers.

> The image have many envs. to be set. View the list of envs on docs.
>
> [Environment](#Environment)

## ... via [`docker-compose`](https://github.com/docker/compose)

Example `.env` for `discourse` on project root directory:

```bash
POSTGRES_HOST=discourse-db
POSTGRES_PORT=5432
POSTGRES_PASSWORD=q39XPRR7oLOU
POSTGRES_USER=discourse
POSTGRES_DB_NAME=discourse

DISCOURSE_PORT=8080
DISCOURSE_DONT_INIT_DATABASE=
DISCOURSE_SU_EMAIL=admin@admin.com
DISCOURSE_SU_PASSWORD=111sssDDDD

REDIS_HOST=discourse-redis
REDIS_PASSWORD=uSbUU8ZDVx
REDIS_PORT=6379
```

Example `docker-compose.yml` for `discourse`:

```yaml
version: '3.5'

services:
  discourse-db:
    image: postgres
    environment:
      POSTGRES_PORT: ${POSTGRES_PORT}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_DB: ${POSTGRES_DB_NAME}
    restart: unless-stopped
    command: -p "${POSTGRES_PORT}"

  discourse-web:
    image: psychomantys/discourse:2.5.0-buster-slim
    build:
      context: .
    restart: unless-stopped
    ports:
      - "${DISCOURSE_PORT}:${DISCOURSE_PORT}"
    environment:
      POSTGRES_HOST: ${POSTGRES_HOST}
      POSTGRES_PORT: ${POSTGRES_PORT}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_DB_NAME: ${POSTGRES_DB_NAME}
      DISCOURSE_PORT: ${DISCOURSE_PORT}
      DISCOURSE_SU_EMAIL: ${DISCOURSE_SU_EMAIL}
      DISCOURSE_SU_PASSWORD: ${DISCOURSE_SU_PASSWORD}
      DISCOURSE_PORT: ${DISCOURSE_PORT}
      DISCOURSE_DONT_INIT_DATABASE: ${DISCOURSE_DONT_INIT_DATABASE}
      REDIS_HOST: ${REDIS_HOST}
      REDIS_PASSWORD: ${REDIS_PASSWORD}
      REDIS_PORT: ${REDIS_PORT}

  discourse-redis:
    image: redis
    command: redis-server --requirepass ${REDIS_PASSWORD} --port ${REDIS_PORT}
    restart: always
    environment:
      REDIS_HOST: ${REDIS_HOST}
      REDIS_PORT: ${REDIS_PORT}
      REDIS_PASSWORD: ${REDIS_PASSWORD}
```

[![Try in PWD](https://github.com/play-with-docker/stacks/raw/cff22438cb4195ace27f9b15784bbb497047afa7/assets/images/button.png)](http://play-with-docker.com?stack=https://github.com/Ilhasoft/discourse/raw/baltazar-docker/docker-compose.yml)

Run `docker-compose build && docker-compose up`, wait for it to initialize completely, and visit `http://swarm-ip:8080`, `http://localhost:8080`, or `http://host-ip:8080` (as appropriate).


## ... [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/)


Example `.env` for `discourse` on project root directory:

```bash
POSTGRES_HOST=discourse-db
POSTGRES_PORT=5432
POSTGRES_PASSWORD=q39XPRR7oLOU
POSTGRES_USER=discourse
POSTGRES_DB_NAME=discourse

DISCOURSE_PORT=8080
DISCOURSE_DONT_INIT_DATABASE=
DISCOURSE_SU_EMAIL=admin@admin.com
DISCOURSE_SU_PASSWORD=111sssDDDD

REDIS_HOST=discourse-redis
REDIS_PASSWORD=uSbUU8ZDVx
REDIS_PORT=6379
```

Example `docker-compose.yml` for `discourse`:

```yaml
version: '3.5'

services:
  discourse-db:
    image: postgres
    environment:
      POSTGRES_PORT: ${POSTGRES_PORT}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_DB: ${POSTGRES_DB_NAME}
    restart: unless-stopped
    command: -p "${POSTGRES_PORT}"

  discourse-web:
    image: psychomantys/discourse:2.5.0-buster-slim
    build:
      context: .
    restart: unless-stopped
    ports:
      - "${DISCOURSE_PORT}:${DISCOURSE_PORT}"
    configs:
      - env.sh

  discourse-redis:
    image: redis
    command: redis-server --requirepass ${REDIS_PASSWORD} --port ${REDIS_PORT}
    restart: always
    environment:
      REDIS_HOST: ${REDIS_HOST}
      REDIS_PORT: ${REDIS_PORT}
      REDIS_PASSWORD: ${REDIS_PASSWORD}

configs:
  env.sh:
    file: .env
```

Run:

```bash
# Optional if image is up already
docker build -t psychomantys/discourse:2.5.0-buster-slim .
docker stack rm discourse && docker-compose config | docker stack deploy discourse --compose-file -
```

Wait for it to initialize completely, and visit `http://swarm-ip:8080`, `http://localhost:8080`, or `http://host-ip:8080` (as appropriate).

# Environment

## Build Args

> `ARG EXECJS_RUNTIME="Node"`
> `ARG DISCOURSE_VERSION="v2.5.0"`
> `ARG BUNDLE_JOBS=6`
> `ARG BUILD_DEPS`
> `ARG RUNTIME_DEPS=`
> `ARG DISCOURSE_UID=500`
> `ARG DISCOURSE_GID=500`
> `ARG DISCOURSE_REPOSITORY_URL="https://github.com/discourse/discourse.git"`
> `ARG DISCOURSE_PLUGINS=""`

## Runtime environment

```bash
POSTGRES_HOST=discourse-db
POSTGRES_PORT=5432
POSTGRES_PASSWORD=q39XPRR7oLOU
POSTGRES_USER=discourse
POSTGRES_DB_NAME=discourse

DISCOURSE_PORT=8080
DISCOURSE_DONT_INIT_DATABASE=
DISCOURSE_SU_EMAIL=admin@admin.com
DISCOURSE_SU_PASSWORD=111sssDDDD

REDIS_HOST=discourse-redis
REDIS_PASSWORD=uSbUU8ZDVx
REDIS_PORT=6379
```

