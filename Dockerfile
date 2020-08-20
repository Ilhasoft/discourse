FROM ruby:2.7.1-slim-buster AS base
#FROM ruby:2.7.1-buster AS base

# Env and Args

ARG DISCOURSE_VERSION="master"
ARG EXECJS_RUNTIME="Node"
#ARG DISCOURSE_VERSION="v2.5.0"
ARG BUILD_DEPS="\
      build-essential \
      git \
      autoconf \
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
      uglifyjs \
      optipng \
      gifsicle \
      pngquant"
ARG RUNTIME_DEPS="\
      uglifyjs \
      jhead \
      libfreetype6 \
      libjpeg-dev \
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
      netcat \
      gosu \
      postgresql-client\
      curl \
      vim"

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
    EXECJS_RUNTIME=Disabled \
    REDIS_HOST=discourse-test-redis \
    REDIS_PASSWORD=asdasdsZDVx \
    REDIS_PORT=6379 \
    POSTGRES_HOST=discourse-test-db \
    POSTGRES_PORT=5432 \
    POSTGRES_PASSWORD=q39XPRR7oLOU \
    POSTGRES_USER=discourse \
    POSTGRES_DB_NAME=discourse \
    DISCOURSE_PORT=8080 \
    DISCOURSE_SERVE_STATIC_ASSETS=true \
    DISCOURSE_UID=${DISCOURSE_UID} \
    DISCOURSE_GID=${DISCOURSE_GID} \
    DISCOURSE_REPOSITORY_URL=${DISCOURSE_REPOSITORY_URL} \
    DISCOURSE_VERSION=${DISCOURSE_VERSION} \
    EXECJS_RUNTIME=Node \
    BUILD_DEPS=${BUILD_DEPS} \
    RUNTIME_DEPS=${RUNTIME_DEPS}

LABEL discourse=${DISCOURSE_VERSION} \
    os="debian" \
    os.version="10" \
    name="Discourse ${DISCOURSE_VERSION}" \
    description="Discourse image" \
    maintainer="Psycho Mantys"

RUN addgroup --gid "${DISCOURSE_GID}" discourse \
 && useradd --system -m -d /app -u "${DISCOURSE_UID}" -g "${DISCOURSE_GID}" discourse

WORKDIR /app

FROM base AS build

RUN apt-get update && apt-get install curl -y \
 && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
 && apt-get install -y nodejs \
 && npm install svgo uglify-js@"<3" -g

#RUN apt-get update && apt-get install -y --no-install-recommends \
RUN apt-get update && apt-get install -y \
      ${BUILD_DEPS} ${RUNTIME_DEPS}

RUN cd / && rm -rf /app \
 && git clone --branch ${DISCOURSE_VERSION} https://github.com/discourse/discourse.git /app

RUN apt-get update && apt-get install -y gnupg sudo curl locales locales-all nodejs advancecomp jhead jpegoptim libjpeg-turbo-progs optipng git rsyslog logrotate cron ssh-client less build-essential rsync \
                       libxslt-dev libcurl4-openssl-dev \
                       libssl-dev libyaml-dev libtool \
                       libxml2-dev gawk parallel \
                       libpq-dev libreadline-dev \
                       anacron wget \
                       psmisc vim whois brotli libunwind-dev \
                       libtcmalloc-minimal4 cmake
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get update && apt-get install -y nodejs

RUN apt-get remove -y uglifyjs

RUN npm install -g uglify-js && npm install -g svgo

RUN git remote set-branches --add origin tests-passed \
 && bundle install --deployment --jobs 6 --without test development \
 && bundle exec rake maxminddb:get \
 && find /app/vendor/bundle -name tmp -type d -exec rm -rf {} +

#RUN git remote set-branches --add origin tests-passed \
# && sed -i 's/daemonize true/daemonize false/g' ./config/puma.rb \
# && sed -i 's;/home/discourse/discourse;/app;g' ./config/puma.rb \
# && mkdir -p "tmp/pids" "tmp/sockets" \
# && bundle config build.nokogiri --use-system-libraries \
# && bundle config set deployment 'true' \
# && bundle config set without 'test development' \
# && bundle  --jobs 6 install
# && bundle clean --force

#FROM base

#COPY --from=build /usr/local/bundle/ /usr/local/bundle/
#COPY --from=build --chown=discourse:discourse /app /app

#RUN apt-get update \
# && SUDO_FORCE_REMOVE=yes apt-get remove --purge -y ${BUILD_DEPS} \
# && apt autoremove -y \
# && apt-get install -y --no-install-recommends ${RUNTIME_DEPS} \
# && rm -rf /usr/share/man \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/* \
# && rm -rf /usr/local/bundle/cache/*.gem \
# && find /app /usr/local/bundle -name "*.c" -delete \
# && find /app /usr/local/bundle -name "*.o" -delete \
# && rm vendor/bundle/ruby/*/cache/*.gem

#RUN apt-get update && apt-get install -y ${BUILD_DEPS} ${RUNTIME_DEPS}

RUN find /app -not -user discourse -exec chown discourse:discourse {} \+

COPY docker-entrypoint.sh /
COPY wait-for /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
#CMD sleep 6d


#HEALTHCHECK --interval=1m --timeout=5s --start-period=1m \
#  CMD /docker-entrypoint.sh healthcheck

