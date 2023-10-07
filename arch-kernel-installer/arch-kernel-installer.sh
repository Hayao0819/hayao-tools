#!/usr/bin/env bash

set -eEuo pipefail

usage() {
    echo "$0 <options> PATH_TO_SRC NAME"
    echo
    echo "This script will install kernel and mkinitcpio preset"
    echo
    echo "1) Clone kernel source and edit config"
    echo "2) Compile kernel with \"make\""
    echo "3) Then run \"sudo make modules_install\""
    echo "4) Run this script to install files for Arch Linux"
    echo "5) Run \"mkinitcpio -P\" and update bootloader"
    echo
    echo "Options)"
    #echo "    --mflags  make command flags(defalut: -j$(npros))"
    echo "    --help    Show this message"
}

nproc=$(($(nproc) / 2))
filename="$(basename "$0")"
installed_files=()
make_args=""

run_make() {
    print_log "Run make" "$@"
    (
        cd "$srcdir" || exit 1
        #shellcheck disable=SC2086
        make $make_args "$@"
    ) || return 1
}

print_log() {
    echo "${filename}: ${*}" >&2
}

prepare() {
    if (("$nproc" < 1)); then
        nproc=1
    fi
    : "${make_args:-"-j $nproc"}"
}

#compile_kernel(){
#    run_make --
#}

install_bzimage() {
    local _bzimage="/boot/vmlinuz-$name"
    install -Dm644 "${srcdir}/$(run_make -s image_name)" "$_bzimage"
    installed_files+=("$_bzimage")
}

mkinitcpio_preset(){
    local _preset="/etc/mkinitcpio.d/${name}.preset"
    sed "s|%PKGBASE%|${name}|g" /usr/share/mkinitcpio/hook.preset > "$_preset"
    installed_files+=("$_preset")
}

finalize(){
    print_log "They are the files which are installed by this script."
    printf "$(print_log 2>&1)- %s\n" "${installed_files[@]}"
}

main() {
    prepare
    #compile_kernel
    install_bzimage
    mkinitcpio_preset

    finalize
}

noargs=()
while true; do
    case "${1-""}" in
    "--help")
        usage
        shift 1
        exit 0
        ;;
    -*)
        print_log "Unknown command line option: $1" >&2
        shift 1
        exit 1
        ;;
    "")
        break
        ;;
    *)
        noargs+=("$1")
        shift 1
        ;;
    esac
done

srcdir="${noargs[0]-""}"
name="${noargs[1]-""}"

if [ -z "${srcdir-""}" ]; then
    print_log "Please specify src path" >&2
    exit 1
fi

if [ -z "${name-""}" ]; then
    print_log "Please specify kernel name" >&2
    exit 1
fi

main "$@"
