
# docker-debian-domain-client

Debian-based Dockerfile and scripts for fully automated installation and configuration of LDAP and Kerberos clients.

This image is not intended to be used directly, but as a base for other services that require integration with LDAP and Kerberos servers for authorization and authentication. Note that both LDAP and Kerberos are required.

There are two integration options: PAM and SSSD. Both of them require the same configuration set.

## Usage

1. Configure.
2. Build.
3. [Optionally] Run.

### Configure
You *have to* configure three different files:
* domain-client-installer.conf
* domain-client-test.sh
* domain-client-test-credentials.conf

You can copy and paste the following examples in the corresponding files, and then make the appropriate modifications.

#### domain-client-installer.conf
```bash
#! /bin/bash

export O_DUMP_DEBCONF_CHOICES=0

export DOMAIN_NAME=example.net
export KERBEROS_ADMIN_SERVER=kerberos.example.net
export KERBEROS_REALM=EXAMPLE.NET
export KERBEROS_SERVERS=kerberos.example.net

export LDAP_HOST=ldap.example.net
export LDAP_STARTLS_PORT=389
export LDAP_STARTLS_URI=ldap://${LDAP_HOST}:${LDAP_STARTLS_PORT}

# SSL is deprecated. You should use TLS whenever possible.
export LDAP_SSL_PORT=636
export LDAP_SSL_URI=ldaps://${LDAP_HOST}:${LDAP_SSL_PORT}

export LDAP_BASE="dc=example,dc=net"
export LDAP_BASE_USERS="ou=Users,${LDAP_BASE}"
export LDAP_BASE_GROUPS="ou=Groups,${LDAP_BASE}"
export LDAP_BASE_MACHINES=""

export LDAP_CERTIFICATE_FILENAME=ldapcrt.pem
# LDAP certificate in base64 encoding.
# Example command to calculate it:
# base64 --wrap=0 /etc/ssl/certs/ldapcrt.pem >> domain-client-installer.conf
export LDAP_CERTIFICATE_BASE64=<long base64 string>

export CERTIFICATES_DIR=/etc/ssl/certs/
export LDAP_CERTIFICATE_ABS="${CERTIFICATES_DIR}${LDAP_CERTIFICATE_FILENAME}"
```

#### domain-client-test.sh
#### domain-client-test-credentials.conf

### Build


### Run

!shellcheck *.sh *.conf && ./build.sh --client-type sssd && docker run -it ewlan/client-sssd:1.0 /bin/bash
