#! /bin/bash

# 4. POST INSTALLATION
######################

source docker-domain-common.sh
validate_client_type ""
source domain-client-installer.conf

case ${CLIENT_TYPE} in
	standard)
		# Make sure all mandatory parameters are provided.
		for config_var in LDAP_HOST LDAP_STARTLS_PORT LDAP_CERTIFICATE_ABS
		do
			assert_defined $config_var
		done

cat > /etc/ldap/ldap.conf <<_TEXT_BLOCK
HOST ${LDAP_HOST}
PORT ${LDAP_STARTLS_PORT}
TLS_CACERT ${LDAP_CERTIFICATE_ABS}
TLS_REQCERT demand
_TEXT_BLOCK

	;;
	sssd)
		# Make sure all mandatory parameters are provided.
		for config_var in DOMAIN_NAME KERBEROS_REALM KERBEROS_SERVERS KERBEROS_ADMIN_SERVER LDAP_CERTIFICATE_ABS LDAP_STARTLS_URI LDAP_BASE LDAP_CERTIFICATE_BASE64
		do
			assert_defined $config_var
		done

cat > /etc/sssd/sssd.conf <<_TEXT_BLOCK
[sssd]
domains = ${DOMAIN_NAME}
services = nss, pam
config_file_version = 2
debug_level=7

[nss]
filter_groups = root
filter_users = root

[pam]

[domain/${DOMAIN_NAME}]
debug_level=10
id_provider = ldap
ldap_uri = ${LDAP_STARTLS_URI}
ldap_search_base = ${LDAP_BASE}
ldap_tls_cacert = ${LDAP_CERTIFICATE_ABS}
ldap_id_use_start_tls = true

auth_provider = krb5
#chpass_provider = krb5
krb5_server = ${KERBEROS_ADMIN_SERVER}
krb5_realm = ${KERBEROS_REALM}

enumerate = false
_TEXT_BLOCK
		# The configuration file must be accessible only to its owner and must belong to root:root.
		chown root:root /etc/sssd/sssd.conf
		chmod 400 /etc/sssd/sssd.conf
	;;
	*)
		echo "Unhandled client type '${CLIENT_TYPE}'" 1>&2
		exit 1
	;;
esac


# For debugging purposes
if [ ${O_DUMP_DEBCONF_CHOICES} -ne 0 ] ; then
	debconf-get-selections | tee /root/DebConfChoices
fi

