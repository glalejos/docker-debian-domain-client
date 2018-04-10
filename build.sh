#! /bin/bash

# Compile from vim
# !shellcheck *.sh *.conf && ./build.sh --client-type sssd && docker run -it domain/client-sssd:1.0 /bin/bash

source docker-domain-common.sh

# Thanks to https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash for directions on how to parse command line parameters in Bash.
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

# 1. Read and validate input parameters.
case $key in
	-t|--client-type)
	CLIENT_TYPE="$2"
	shift # past argument
	shift # past value
	;;
	*)    # unknown option
	echo "Unrecognized parameter '$1'" 1>&2
	POSITIONAL+=("$1") # save it in an array for later
	shift # past argument
	;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

function print_usage_and_exit
{
	echo "Usage:" 1>&2
	echo "	build.sh --client-type <standard | sssd>" 1>&2
	exit 1
}

# 1.1. Validate CLIENT_TYPE
validate_client_type "print_usage_and_exit"

# 2. Run the build process.
docker build \
	--build-arg CLIENT_TYPE="${CLIENT_TYPE}" \
	--tag "domain/client-${CLIENT_TYPE}:1.0" .

