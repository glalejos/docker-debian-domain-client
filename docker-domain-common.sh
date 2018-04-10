#! /bin/bash

function validate_client_type {
	ERROR_FUNCTION=$1
	ERROR=0

	if [ "${CLIENT_TYPE}x" = "x" ] ; then
		echo "'CLIENT_TYPE' environment variable is undefined." 1>&2
		ERROR=1
	else
		case ${CLIENT_TYPE} in
			standard|sssd)
				echo "Using client type '${CLIENT_TYPE}'"
			;;
			*)
				echo "Invalid client type '${CLIENT_TYPE}'" 1>&2
				ERROR=1
			;;
		esac
	fi

	if [ ${ERROR} = 1 ] ; then
		if [ "${ERROR_FUNCTION}x" != "x" ] ; then
			eval "${ERROR_FUNCTION}"
		fi
		exit 1
	fi
}

# Determines whether the given name corresponds to a defined variable.
function assert_defined {
	var_name=$1

	if [[ "${!var_name}x" == "x" ]] ; then
		echo "'${var_name}' variable is missing." >&2
		return 1
	fi
	return 0
}



export -f  validate_client_type
export -f  assert_defined

