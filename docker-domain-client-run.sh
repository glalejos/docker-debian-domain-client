#! /bin/bash

source docker-domain-common.sh
validate_client_type ""

# 1. Start required services.
service cron start
service rsyslog start

case ${CLIENT_TYPE} in
	standard)
		service nslcd start
	;;
	sssd)
		service sssd start
	;;
	*)
		echo "Unhandled client type '${CLIENT_TYPE}'" 1>&2
		exit 1
	;;
esac

# 2. Run the given command.
"$@"

