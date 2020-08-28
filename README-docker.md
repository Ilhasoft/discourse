# What is Discourse?

Discourse is an open source Internet forum and mailing list management software application founded in 2013 by Jeff Atwood, Robin Ward, and Sam Saffron. Discourse received funding from First Round Capital and Greylock Partners. The application is written with Ember.js and Ruby on Rails.

> [https://en.wikipedia.org/wiki/Discourse_(software)](https://en.wikipedia.org/wiki/Discourse_(software))

![logo](https://www.discourse.org/a/img/favicon.png)


# How to use this image

## start a discourse instance

```console
$ docker run --name discourse -e POSTGRES_HOST=10.0.0.10 -d psychomantys/discourse:2.5.0-buster-slim
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

We will show the key `ARG` and environments to build the image and to put it into production.

## Build Args

Most important arguments for building the image

> `ARG DISCOURSE_VERSION`

Version to download code from repository(**`master`, `v2.5.0`, etc...**).

> `ARG BUILD_DEPS`

Debian packages to install on the build process.

> `ARG RUNTIME_DEPS`

Debian packages to install on runtime.

> `ARG NODE_BUILD_DEPS`

Node packages to install on the build process. If empty, `nodejs` will not be instaled.

> `ARG NODE_RUNTIME_DEPS`

Node packages to install on the runtime. If empty, `nodejs` will not be instaled.

> `ARG DISCOURSE_REPOSITORY_URL`

Git repository for clone and build **discourse** from source.

> `ARG DISCOURSE_UID`

**UID** of **discourse** on the image.

> `ARG DISCOURSE_GID`

**GID** of **discourse** on the image.

> `ARG BUNDLE_JOBS`

Threads used on `bundle install`.

> `ARG EXECJS_RUNTIME="Node"`

Used by `execjs` to compile front end code.

> `ARG DISCOURSE_PLUGINS`

Not used yet.

## Runtime environment

Environment who change the behavior of the container on runtime. Just change and re-run the container.

> `DISCOURSE_HOSTNAME`

Hostname used by the discourse. It is important, because it is used sometimes for some redicts for example.

> `DISCOURSE_PORT=8080`

Port discourse will bind internally.

> `DISCOURSE_SU_EMAIL=admin@admin.com`

Email of the user to be created as an admin user of discourse. This email is optional, user does not need to be created.

> `DISCOURSE_SU_PASSWORD=PASSWD_DISCOURSE_CHANGEME`

Password for admins user to be created. This password is optional, user does not need to be created.

> `DISCOURSE_DONT_INIT_SU=""`

Dont create admin user of discourse if equal do "true".

> `DISCOURSE_DONT_INIT_DATABASE=""`

Dont create basic tables of discourse on database if equal do "true".

> `DISCOURSE_DONT_PRECOMPILE=""`

Dont run `bundle exec rake assets:precompile` create admin user of discourse if equal do "true".

> `REDIS_HOST=server-redis-hostname`

Redis server host address.

> `REDIS_PORT=6379`

Redis server port.

> `REDIS_PASSWORD=PASSWD_REDIS_CHANGEME`

Password for redis server.

> `POSTGRES_HOST=server-postgres-hostname`

Hostname of database.

> `POSTGRES_PORT=5432`

Database port of database.

> `POSTGRES_PASSWORD=PASSWD_POSTGRES_CHANGEME`

Password used by database.

> `POSTGRES_USER=postgres_user`

Username used by database.

> `POSTGRES_DB_NAME=${POSTGRES_USER}`

Name of database used.

> `DISCOURSE_UID=${DISCOURSE_UID}`

**UID** of discourse user to run.

> `DISCOURSE_GID=${DISCOURSE_GID}`

**GID** of discourse user to run.

## Less used Environment

```bash
EXECJS_RUNTIME=${EXECJS_RUNTIME}
BUNDLE_JOBS=${BUNDLE_JOBS}
RAILS_ENV=production
RUBY_GC_MALLOC_LIMIT=90000000
RUBY_GLOBAL_METHOD_CACHE_SIZE=131072
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
DISCOURSE_SERVE_STATIC_ASSETS=true
```

