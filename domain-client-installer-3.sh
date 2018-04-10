#! /bin/bash

# 3. INSTALL PACKAGES
#####################

source docker-domain-common.sh
validate_client_type ""
source domain-client-installer-packages.sh

# Validate required variables.
if [ "${PACKAGES_TO_INSTALL[*]}x" == "x" ] ; then
	echo "Variable 'PACKAGES_TO_INSTALL' is not defined. Aborting."
	exit 1
fi

apt-get install --quiet --quiet --yes --ignore-missing --no-download -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "${PACKAGES_TO_INSTALL[@]}" "${TESTING_PACKAGES_TO_INSTALL[@]}"
if [ ! $? -eq 0 ] ; then
	echo "Unable to install packages." >&2
	exit 1
fi

apt-get clean
if [ ! $? -eq 0 ] ; then
	echo "Unable to clean apt cache." >&2
	exit 1
fi

