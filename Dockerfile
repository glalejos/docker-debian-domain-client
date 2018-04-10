
FROM debian:9.3

# Client type is mandatory.
ARG CLIENT_TYPE
ENV CLIENT_TYPE ${CLIENT_TYPE}

# Set-up the working directory.
ENV DOMAIN_CLIENT_INSTALL_DIR /opt/domain
ENV DOMAIN_CLIENT_CONF_ABS ${DOMAIN_CLIENT_INSTALL_DIR}/domain-client-installer.conf
WORKDIR ${DOMAIN_CLIENT_INSTALL_DIR}

# COPY instructions are delayed as much as possible to make the most of Docker cache.
COPY domain-client-installer-packages.sh ./
COPY docker-domain-common.sh ./
COPY domain-client-installer.conf ${DOMAIN_CLIENT_CONF_ABS}

# Packages download.
COPY domain-client-installer-1.sh .
RUN ./domain-client-installer-1.sh

# DebConf choices.
COPY domain-client-installer-2.sh .
RUN ./domain-client-installer-2.sh

# Packages installation.
COPY domain-client-installer-3.sh .
RUN ./domain-client-installer-3.sh

# Post installation steps.
COPY domain-client-installer-4.sh .
RUN ./domain-client-installer-4.sh

# Install run script.
ENV DOMAIN_CLIENT_INIT_SCRIPT_NAME docker-domain-client-run.sh
COPY ${DOMAIN_CLIENT_INIT_SCRIPT_NAME} .
ENV DOMAIN_CLIENT_INIT_SCRIPT_ABS ${DOMAIN_CLIENT_INSTALL_DIR}/${DOMAIN_CLIENT_INIT_SCRIPT_NAME}
RUN chmod u+x *.sh

COPY domain-client-test.sh domain-client-test-credentials.conf ./
RUN ["/bin/bash", "-c", "./domain-client-test.sh"]
RUN ["/bin/bash", "-c", "rm domain-client-test*"]

# Yes, the "null" is necessary to make sure that all parameters provided by the caller are used (otherwise $0 is lost, see https://unix.stackexchange.com/questions/144514/add-arguments-to-bash-c)
ENTRYPOINT ["/bin/bash", "-c", "${DOMAIN_CLIENT_INIT_SCRIPT_ABS} $@", "null"]

