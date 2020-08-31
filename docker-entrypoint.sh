#!/bin/bash

#set -e

#replace_conf(){
#	for arg in "$@" ; do
#		local key="$( cut -f1 -d'=' <<<"${arg}" )"
#		local value="$( cut -f2- -d'=' <<<"${arg}" )"
#		for f in "${CONF_FILES[@]}" ; do
#			sed -i s";${key};${value};" "${f}"
#		done
#	done
#}

parse_env(){
	if [ -r "$1" ] ; then
		while IFS="=" read key value  ; do
			export "${key}=${value}"
		done<<<"$( egrep '^[^#]+=.*' "$1" )"
	fi
}

bootstrap_conf(){
	touch log/{production.log,puma.err.log,puma.log}
	# Fixing permissions
	find /app -not -user discourse -exec chown discourse:discourse {} \+

	gosu discourse bundle config build.nokogiri --use-system-libraries
	gosu discourse bundle config set deployment 'true'
	gosu discourse bundle config set without 'test:development'

	gosu discourse bundle config set DISCOURSE_DB_HOST "${POSTGRES_HOST}"
	export DISCOURSE_DB_HOST="${POSTGRES_HOST}"
	gosu discourse bundle config set DISCOURSE_DB_PORT "${POSTGRES_PORT}"
	export DISCOURSE_DB_PORT="${POSTGRES_PORT}"
	gosu discourse bundle config set DISCOURSE_DB_NAME "${POSTGRES_DB_NAME}"
	export DISCOURSE_DB_NAME="${POSTGRES_DB_NAME}"
	gosu discourse bundle config set DISCOURSE_DB_USERNAME "${POSTGRES_USER}"
	export DISCOURSE_DB_USERNAME="${POSTGRES_USER}"
	gosu discourse bundle config set DISCOURSE_DB_PASSWORD "${POSTGRES_PASSWORD}"
	export DISCOURSE_DB_PASSWORD="${POSTGRES_PASSWORD}"

	gosu discourse bundle config set DISCOURSE_REDIS_HOST "${REDIS_HOST}"
	export DISCOURSE_REDIS_HOST="${REDIS_HOST}"
	gosu discourse bundle config set DISCOURSE_REDIS_PORT "${REDIS_PORT}"
	export DISCOURSE_REDIS_PORT="${REDIS_PORT}"
	if [ "${REDIS_PASSWORD}" ] ; then
		gosu discourse bundle config set DISCOURSE_REDIS_PASSWORD "${REDIS_PASSWORD}"
		export DISCOURSE_REDIS_PASSWORD="${REDIS_PASSWORD}"
	fi
	if [ "${REDIS_DB}" ] ; then
		gosu discourse bundle config set DISCOURSE_REDIS_DB "${REDIS_DB}"
		export DISCOURSE_REDIS_DB="${REDIS_DB}"
	fi

	gosu discourse bundle config set DISCOURSE_SMTP_ADDRESS "${SMTP_HOST}"
	export DISCOURSE_SMTP_ADDRESS="${SMTP_HOST}"
	gosu discourse bundle config set DISCOURSE_SMTP_PORT "${SMTP_PORT}"
	export DISCOURSE_SMTP_PORT="${SMTP_PORT}"
	gosu discourse bundle config set DISCOURSE_SMTP_USER_NAME "${SMTP_USER}"
	export DISCOURSE_SMTP_USER_NAME="${SMTP_USER}"
	gosu discourse bundle config set DISCOURSE_SMTP_PASSWORD "${SMTP_PASSWORD}"
	export DISCOURSE_SMTP_PASSWORD="${SMTP_PASSWORD}"
	gosu discourse bundle config set DISCOURSE_SMTP_AUTHENTICATION "${SMTP_AUTHENTICATION}"
	export DISCOURSE_SMTP_AUTHENTICATION="${SMTP_AUTHENTICATION}"
	gosu discourse bundle config set DISCOURSE_SMTP_ENABLE_START_TLS "${SMTP_ENABLE_START_TLS}"
	export DISCOURSE_SMTP_ENABLE_START_TLS="${SMTP_ENABLE_START_TLS}"
}

parse_env '/env.sh'
parse_env '/run/secrets/env.sh'

if [[ "start" == *"$1"* ]]; then
	/wait-for "${POSTGRES_HOST}:${POSTGRES_PORT}" -- echo DB "${POSTGRES_HOST}:${POSTGRES_PORT}" started
	/wait-for "${REDIS_HOST}:${REDIS_PORT}" -- echo Redis Server: "${REDIS_HOST}:${REDIS_PORT}" started
	bootstrap_conf

	#exec gosu discourse bundle exec rake assets:precompile
	if [ "${DISCOURSE_DONT_INIT_DATABASE}" != "true" ] ; then
		gosu discourse bundle exec rake db:create || echo 'ERROR: bundle exec rake db:create'
	fi
	gosu discourse bundle exec rake db:migrate || echo 'ERROR: bundle exec rake db:migrate'

	if [ "${DISCOURSE_DONT_INIT_SU}" != "true" -a ! -f /discourse_su_created ] ; then
		#echo -e "${DISCOURSE_SU_EMAIL}\n${DISCOURSE_SU_PASSWORD}\n${DISCOURSE_SU_PASSWORD}\nY"
		echo -e "${DISCOURSE_SU_EMAIL}\n${DISCOURSE_SU_PASSWORD}\n${DISCOURSE_SU_PASSWORD}\nY" \
			| gosu discourse bundle exec rake admin:create
		touch /discourse_su_created
	fi

	if [ "${DISCOURSE_DISABLE_CSP}" = "true" ] ; then
		echo 'SiteSetting.content_security_policy = false' | /docker-entrypoint.sh bundle exec rails c
	fi
	if [ "${DISCOURSE_DONT_PRECOMPILE}" != "true" -a ! -f /discourse_precompiled ] ; then
		gosu discourse bundle exec rake assets:precompile
		touch /discourse_precompiled
	fi
	#gosu discourse mailcatcher --http-ip 0.0.0.0

	tail -f log/* &

	(
		while true ; do
			gosu discourse bundle exec sidekiq -v -L /dev/stdout -c 5
		done
	) &
	exec gosu discourse bundle exec rails server --binding="0.0.0.0" --port="${DISCOURSE_PORT}"
elif [[ "bundle" == "$1" ]]; then
	bootstrap_conf

	exec gosu discourse $@
elif [[ "healthcheck" == "$1" ]]; then
	nc -z -w5 127.0.0.1 "${DISCOURSE_PORT}" || exit 1
	exit 0
fi

bootstrap_conf
exec "$@"

