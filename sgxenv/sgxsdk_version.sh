#!/usr/bin/env bash

SGX_SDK="${SGX_SDK-"/opt/intel/sgxsdk"}"

if [[ -e "$SGX_SDK/environment" ]]; then
	# shellcheck source=/dev/null
	source "$SGX_SDK/environment"
fi

if [[ -z "${SGX_SDK-""}" ]]; then
	echo "SGX_SDK is not set. Please set SGX_SDK to the Intel SGX SDK path." >&2
	exit 1
fi

find "$SGX_SDK/lib64" -name "*.so" -type f -print0 |
	xargs -0 -L1 strings |
	grep SGX | grep -v SGX_ERROR | grep VERSION |
	rev | cut -d "_" -f 1 | rev | sort | uniq
