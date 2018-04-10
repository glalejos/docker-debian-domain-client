#! /bin/bash

source docker-domain-common.sh
validate_client_type ""

/usr/bin/docker run -it --rm "domain/client-${CLIENT_TYPE}" /bin/bash

