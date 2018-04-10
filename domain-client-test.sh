#! /bin/bash

source domain-client-installer-packages.sh
source domain-client-test-credentials.conf

ENCRYPTION_KEY=...

function decrypt {
	echo "$1" | openssl enc -aes-256-cbc -a -d -salt -pass pass:"${ENCRYPTION_KEY}"
	if [ ! $? = 0 ] ; then
		echo "Unable to decrypt given data." 1>&2
		exit 1
	fi
}

RETURN_CODE=0

${DOMAIN_CLIENT_INIT_SCRIPT_ABS}

# Test LDAP configuration.
# I'm specifying the username here because a single "getent passwd" won't connect to the LDAP in some architectures (such as SSSD). In case this is desired, change the "enumeration" configuration parameter in SSSD to "true".
GETENT_OUTPUT=$(getent passwd "$(decrypt "${CLIENT_TEST_ENCRYPTED_USERNAME}")")
if [ ! $? = 0 ] ; then
	echo "'getent passwd' failed." 1>&2
	RETURN_CODE=1
fi

if [[ ! ${GETENT_OUTPUT} = *"$(decrypt "${CLIENT_TEST_ENCRYPTED_USERNAME}")"* ]] ; then
	echo "'getent passwd' didn't return the expected username." 1>&2
	RETURN_CODE=1
fi

# Test Kerberos configuration.
decrypt "${CLIENT_TEST_ENCRYPTED_PASSWORD}" | kinit -p "$(decrypt "${CLIENT_TEST_ENCRYPTED_USERNAME}")"
if [ ! $? = 0 ] ; then
	echo "'kinit' failed." 1>&2
	RETURN_CODE=1
fi

kdestroy -A
if [ ! $? = 0 ] ; then
	echo "'kdestroy' failed." 1>&2
	RETURN_CODE=1
fi

case ${CLIENT_TYPE} in
	standard)
		# Nothing to do here.
	;;
	sssd)
		# We've already tested Kerberos client, but we need to make sure that Kerberos client configuration is working properly through SSSD.
		# The only way I've found to test authentication is using SSH.

		# Start the service
		service ssh start

		# Accept all host keys
		mkdir ~/.ssh
		cat > ~/.ssh/config <<TEXT
Host *
    StrictHostKeyChecking no
TEXT
		# chmod 400 ~/.ssh/config

		# Try connection
		sshpass -f <(decrypt "${CLIENT_TEST_ENCRYPTED_PASSWORD}") ssh "$(decrypt "${CLIENT_TEST_ENCRYPTED_USERNAME}")@localhost" "exit 0"
		if [ ! $? = 0 ] ; then
			echo "'ssh' failed." 1>&2
			RETURN_CODE=1
		fi

		# Clean up
		rm -Rf ~/.ssh
	;;
	*)
		echo "Unhandled client type '${CLIENT_TYPE}'" 1>&2
		exit 1
	;;
esac

# Perform clean-up (but only if everything went OK, to avoid introducing noise).
if [ ${RETURN_CODE} = 0 ] ; then
	# Remove all unnecessary binaries.
	apt-get remove --quiet --quiet --yes --purge "${TESTING_PACKAGES_TO_INSTALL[@]}"
	apt-get autoremove --quiet --quiet --yes
	apt-get clean

	# Stop all services.
	for service_to_stop in /etc/init.d/* ; do "${service_to_stop}" stop ; done;
fi

exit ${RETURN_CODE}

