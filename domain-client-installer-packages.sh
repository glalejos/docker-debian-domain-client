#! /bin/bash

source docker-domain-common.sh
validate_client_type ""
source domain-client-installer.conf

export PACKAGES_TO_INSTALL=()

# Profile specific packages.
case ${CLIENT_TYPE} in
	standard)
		# Kerberos libraries
		# Note that installing krb5-conf will override DebConf selections.
		PACKAGES_TO_INSTALL+=(libpam-krb5)

		PACKAGES_TO_INSTALL+=(libnss-ldapd)
	;;
	sssd)
		PACKAGES_TO_INSTALL+=(sssd)
	;;
	*)
		echo "Unhandled client type '${CLIENT_TYPE}'" 1>&2
		exit 1
	;;
esac

# Packages common to all profiles.
PACKAGES_TO_INSTALL+=(krb5-user)
PACKAGES_TO_INSTALL+=(cron rsyslog)

# Used for testing purposes.
export TESTING_PACKAGES_TO_INSTALL=()
TESTING_PACKAGES_TO_INSTALL+=(openssl)
TESTING_PACKAGES_TO_INSTALL+=(sshpass ssh)

# Remove packages in the testing list that are already in the main list. Usage of 'IFS' variable is to sort the arrays.
IFS=$'\n'
TESTING_PACKAGES_TO_INSTALL=( $(comm -13 <(sort <<< "${PACKAGES_TO_INSTALL[*]}") <(sort <<< "${TESTING_PACKAGES_TO_INSTALL[*]}")) )
unset IFS

# For debugging purposes
if [ ${O_DUMP_DEBCONF_CHOICES} -ne 0 ] ; then
	PACKAGES_TO_INSTALL+=(debconf-utils)
fi

