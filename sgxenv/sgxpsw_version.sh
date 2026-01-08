#!/usr/bin/env bash

set -eEuo pipefail

# sgxpsw_aesm_version_info binary_dir
sgxpsw_aesm_version_info() {
	find "$1" -type f -name "*.so" -print0 | xargs -0 strings | grep VERSION_ | sort | uniq
}

# systemd_load_env service
systemd_load_env() {
	while read -r _def; do
		eval export "$_def"
	done < <(systemctl cat aesmd | grep "^Environment" | cut -d= -f 2-)
}

aesmd_get_ld_path() {
	(
		systemd_load_env "aesmd"
		echo "${LD_LIBRARY_PATH-""}"
	)
}

sgxpsw_aesm_version_info "$(aesmd_get_ld_path)"
