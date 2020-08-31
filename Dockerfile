FROM ruby:2.7.1-slim-buster AS base
#FROM ruby:2.7.1-buster AS base

# Env and Args

#ARG DISCOURSE_VERSION="master"
ARG EXECJS_RUNTIME="Node"
ARG DISCOURSE_VERSION="v2.5.0"
ARG BUNDLE_JOBS=6

ARG NODE_BUILD_DEPS=""
ARG NODE_RUNTIME_DEPS="source-map commander svgo uglify-js"

ARG BUILD_DEPS="\
      build-essential \
      git \
      autoconf \
      curl \
      jhead \
      libbz2-dev \
      libxslt-dev \
      libfreetype6-dev \
      libjpeg-dev \
      libjpeg-turbo-progs \
      libtiff-dev \
      pkg-config \
      ghostscript \
      gsfonts \
      libpq-dev \
      imagemagick \
      jpegoptim \
      libxml2-dev \
      nodejs \
      optipng \
      gifsicle \
      pngquant"
ARG RUNTIME_DEPS="\
      git \
      uglifyjs \
      jpegoptim \
      optipng \
      jhead \
      libfreetype6 \
      libjpeg62-turbo \
      libjpeg-turbo-progs \
      libtiff5 \
      libbz2-1.0 \
      libpq5 \
      libxml2 \
      libxslt1.1 \
      libpng16-16 \
      zlib1g \
      gifsicle \
      pngquant \
      ghostscript \
      gsfonts \
      netcat \
      gosu \
      postgresql-client \
      imagemagick \
      sendmail \
      nodejs \
      brotli"

ARG DISCOURSE_UID=500
ARG DISCOURSE_GID=500

ARG DISCOURSE_REPOSITORY_URL="https://github.com/discourse/discourse.git"

ARG DISCOURSE_PLUGINS="\
    https://github.com/discourse/discourse-spoiler-alert"

ENV RAILS_ENV=production \
    RUBY_GC_MALLOC_LIMIT=90000000 \
    RUBY_GLOBAL_METHOD_CACHE_SIZE=131072 \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_JOBS=${BUNDLE_JOBS} \
    DISCOURSE_PORT=8080 \
    DISCOURSE_SU_EMAIL=admin@admin.com \
    DISCOURSE_SU_PASSWORD=PASSWD_DISCOURSE_CHANGEME \
    DISCOURSE_DONT_INIT_DATABASE="" \
    DISCOURSE_DONT_PRECOMPILE="" \
    DISCOURSE_DONT_INIT_SU="" \
    DISCOURSE_SERVE_STATIC_ASSETS=true \
    DISCOURSE_UID=${DISCOURSE_UID} \
    DISCOURSE_GID=${DISCOURSE_GID} \
    DISCOURSE_REPOSITORY_URL=${DISCOURSE_REPOSITORY_URL} \
    DISCOURSE_VERSION=${DISCOURSE_VERSION} \
    REDIS_HOST=server-redis-hostname \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=PASSWD_REDIS_CHANGEME \
    POSTGRES_HOST=server-postgres-hostname \
    POSTGRES_PORT=5432 \
    POSTGRES_PASSWORD=PASSWD_POSTGRES_CHANGEME \
    POSTGRES_USER=postgres_user \
    POSTGRES_DB_NAME=${POSTGRES_USER} \
    EXECJS_RUNTIME=${EXECJS_RUNTIME} \
    NODE_BUILD_DEPS=${NODE_BUILD_DEPS} \
    NODE_RUNTIME_DEPS=${NODE_RUNTIME_DEPS} \
    BUILD_DEPS=${BUILD_DEPS} \
    RUNTIME_DEPS=${RUNTIME_DEPS}


LABEL discourse=${DISCOURSE_VERSION} \
    os="debian" \
    os.version="10" \
    name="Discourse ${DISCOURSE_VERSION}" \
    description="Discourse image" \
    maintainer="Ilhasoft Team"

RUN addgroup --gid "${DISCOURSE_GID}" discourse \
 && useradd --system -m -d /app -u "${DISCOURSE_UID}" -g "${DISCOURSE_GID}" discourse

WORKDIR /app

FROM base AS build

RUN if [ ! "x${NODE_BUILD_DEPS}" = "x" ] ; then apt-get update \
 && apt-get install -y --no-install-recommends curl -y \
 && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g ${NODE_BUILD_DEPS} ; fi

RUN apt-get update && apt-get install -y --no-install-recommends ${BUILD_DEPS}

RUN cd / && rm -rf /app \
 && git clone --branch ${DISCOURSE_VERSION} https://github.com/discourse/discourse.git /app \
 && cd /app \
 && git remote set-branches --add origin tests-passed \
 && rm -rf .git \
 && sed -i 's/daemonize true/daemonize false/g' ./config/puma.rb \
 && sed -i 's;/home/discourse/discourse;/app;g' ./config/puma.rb \
 && mkdir -p "tmp/pids" "tmp/sockets" \
 && bundle config build.nokogiri --use-system-libraries \
 && bundle config set deployment 'true' \
 && bundle config set without 'test development' \
 && bundle install --jobs "${BUNDLE_JOBS}"
 
# && bundle install --deployment --jobs 6 --without test development \
# && bundle exec rake maxminddb:get \

FROM base

COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY --from=build --chown=discourse:discourse /app /app

RUN if [ ! "x${NODE_RUNTIME_DEPS}" = "x" ] ; then apt-get update \
 && apt-get install -y --no-install-recommends curl -y \
 && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g ${NODE_RUNTIME_DEPS} ; fi

RUN apt-get update \
 && SUDO_FORCE_REMOVE=yes apt-get remove --purge -y ${BUILD_DEPS} \
 && apt autoremove -y \
 && apt-get install -y --no-install-recommends ${RUNTIME_DEPS} \
 && rm -rf /usr/share/man \
 && apt-get clean \
 && find /app/vendor/bundle -name tmp -type d -exec rm -rf {} + \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /app /usr/local/bundle -name "*.c" -delete \
 && find /app /usr/local/bundle -name "*.o" -delete \
 && rm vendor/bundle/ruby/*/cache/*.gem

COPY docker-entrypoint.sh /
COPY wait-for /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
#CMD sleep 6d

#HEALTHCHECK --interval=1m --timeout=5s --start-period=600s \
#  CMD /docker-entrypoint.sh healthcheck

