#! /bin/bash

# 2. DEBCONF DEFINITIONS
########################

# Inspect the DebConfChoices
# id=$(docker create domain/client) && docker cp $id:/root/DebConfChoices - > DebConfChoices.tar && docker rm -v $id && tar fx DebConfChoices.tar | cat DebConfChoices | less

# [1] http://www.microhowto.info/howto/perform_an_unattended_installation_of_a_debian_package.html

source docker-domain-common.sh
validate_client_type ""
source domain-client-installer.conf

# 2.1. CONFIGURATION VALIDATION
###############################

# Validate required variables.
CONFIGURATION_KO=0

case ${CLIENT_TYPE} in
	standard)
		# Make sure all mandatory parameters are provided.
		for config_var in LDAP_CERTIFICATE_FILENAME LDAP_SSL_URI LDAP_BASE LDAP_CERTIFICATE_BASE64
		do
			assert_defined $config_var
			if [ $? = 1 ] ; then
				CONFIGURATION_KO=1
			fi
		done
	;;
	sssd)
		# Nothing to do here.
	;;
	*)
		echo "Unhandled client type '${CLIENT_TYPE}'" 1>&2
		exit 1
	;;
esac

# Configuration common to all profiles.
for config_var in KERBEROS_REALM KERBEROS_SERVERS KERBEROS_ADMIN_SERVER
do
	assert_defined $config_var
	if [ $? = 1 ] ; then
		CONFIGURATION_KO=1
	fi
done

# Terminate the program if anything went wrong with parameter processing.
if [[ ${CONFIGURATION_KO} == 1 ]] ; then
	echo "One or more configuration parameters is invalid or missing. Aborting." >&2
	exit 1
fi

# 2.2. PRE-CONFIGURATION
########################
# Deploy the LDAP certificate.
mkdir -p "${CERTIFICATES_DIR}"
if [ ! $? -eq 0 ] ; then
	echo "Unable to create certificates directory '${CERTIFICATES_DIR}'." >&2
	exit 1
fi
echo "${LDAP_CERTIFICATE_BASE64}" | base64 --decode > "${LDAP_CERTIFICATE_ABS}"
if [[ "${PIPESTATUS[@]}" =~ [^0\ ] ]] ; then
	echo "Unable to deploy LDAP certificate." >&2
	exit 1
fi

# 2.4. DEBCONF CONFIGURATION
############################
# Seed debconf with the selections.
# Format:
# 	* Use only one separation tab between columns, otherwise the parameter won't be properly processed.
echo "Setting DebConf selections."
case ${CLIENT_TYPE} in
	standard)
debconf-set-selections <<_TEXT_BLOCK
libpam-runtime	libpam-runtime/profiles		multiselect	krb5, unix, systemd, capability
nslcd	nslcd/ldap-uris	string	${LDAP_SSL_URI}
nslcd	nslcd/ldap-base	string	${LDAP_BASE}
nslcd	nslcd/ldap-cacertfile	string	${LDAP_CERTIFICATE_ABS}
libnss-ldapd	libnss-ldapd/nsswitch	multiselect	passwd, group, shadow, hosts, networks, ethers, protocols, services, rpc, netgroup, aliases
libnss-ldapd:amd64	libnss-ldapd/nsswitch	multiselect	passwd, group, shadow, hosts, networks, ethers, protocols, services, rpc, netgroup, aliases
_TEXT_BLOCK
	;;
	sssd)
		# Nothing to do here.
	;;
	*)
		echo "Unhandled client type '${CLIENT_TYPE}'" 1>&2
		exit 1
	;;
esac

# Debconf configurations common to all profiles.
debconf-set-selections <<_TEXT_BLOCK
krb5-config	krb5-config/add_servers		boolean	true
krb5-config	krb5-config/add_servers_realm	string	${KERBEROS_REALM}
krb5-config	krb5-config/default_realm	string	${KERBEROS_REALM}
krb5-config	krb5-config/kerberos_servers	string	${KERBEROS_SERVERS}
krb5-config	krb5-config/admin_server	string	${KERBEROS_ADMIN_SERVER}
_TEXT_BLOCK

if [ ! $? -eq 0 ] ; then
	echo "Unable to set DebConf selections." >&2
	exit 1
fi

