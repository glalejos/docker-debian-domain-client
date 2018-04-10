#! /bin/bash

# 1. DOWNLOAD PACKAGES
######################

source docker-domain-common.sh
validate_client_type ""
source domain-client-installer-packages.sh

# Validate required variables.
if [ "${PACKAGES_TO_INSTALL[*]}x" == "x" ] ; then
	echo "Variable 'PACKAGES_TO_INSTALL' is not defined. Aborting."
	exit 1
fi

# Update and download
export DEBIAN_FRONTEND=noninteractive

apt-get update --quiet
if [ ! $? -eq 0 ] ; then
	echo "Unable to update apt." >&2
	exit 1
fi

apt-get install --quiet --quiet --download-only --yes "${PACKAGES_TO_INSTALL[@]}" "${TESTING_PACKAGES_TO_INSTALL[@]}"
if [ ! $? -eq 0 ] ; then
	echo "Unable to download packages." >&2
	exit 1
fi

