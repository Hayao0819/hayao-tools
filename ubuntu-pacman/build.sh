#!/usr/bin/env bash

set -eu -o pipefail

current_dir="$(cd "$(dirname "$0")" || exit 1; pwd)"
work_dir="$current_dir/work"
build_dir="$work_dir/src"
pacman_repo="https://gitlab.archlinux.org/pacman/pacman.git"
checkout_branch=""

pacman_build_depends=(meson doxygen fakeroot libarchive-dev cmake pkg-config libcrypto++-dev libcurl4-openssl-dev libgpgme-dev libssl-dev asciidoc-base libarchive-tools)
destdir="/"

uninstall=false

if [[ "${1-""}" = "uninstall"  ]]; then
    uninstall=true
else
    checkout_branch="${1:-"master"}"
fi

# config for pacman.conf
config_rootdir="/var/chroot/arch"
config_localstatedir="/var"
config_sysconfdir="/etc"

# config for makepkg.conf
export CARCH="x86_64"
config_carch="$CARCH"
config_chost=""
config_carchflags=""

backup_files=(
    "${destdir}/$config_sysconfdir/pacman.conf"
    "${destdir}/$config_sysconfdir/makepkg.conf"
    "$destdir/$config_sysconfdir/pacman.d/mirrorlist"
)


get_installed_pkglist(){
    dpkg --get-selections | awk '{ if( $2 = "install" ){print $1} }' | cut -d ":" -f 1
}

# define installed pkg list
readarray -t installed_pkglist < <(get_installed_pkglist)

# command_check <command> <package>
command_check(){
    local _cmd="$1"
    local _pkg="${2:-"${_cmd}"}"
    if ! type "$_cmd" 1>/dev/null 2>&1; then
        echo "$_cmd comamnd is not available. Please run: sudo apt install $_pkg" >&2
        exit 1
    fi
}


# pkg_check
pkg_check(){
    #[[ "${installed_pkglist[*]}" =~ $1 ]]

    if printf '%s\n' "${installed_pkglist[@]}" | grep -x -- "$1" > /dev/null; then
    #if get_installed_pkglist | grep -x "$1" > /dev/null; then
        #echo "$1 is installed." 1>&2
        return 0
    fi
    msg_err "$1 is not installed."
    return 1
}

msg_err(){
    echo "ERROR: $*" >&2
}


# main functions
make_check_os(){
    if (( UID == 0 )); then
        msg_err "Do not run this script as root."
        exit 1
    fi

    if ! type apt 2> /dev/null 1>&2; then
        msg_err "You should run this script on Ubuntu."
        exit 1
    fi

    if [[ "$(uname -m)" != "x86_64" ]]; then
        msg_err "You should run this script on x86_64."
        exit 1
    fi

    if ! [[ -e "$current_dir/makepkg.conf.in" ]]; then
        msg_err "makepkg.conf.in is not found."
        exit 1
    fi
}
make_check_command_deps(){
    command_check git
    command_check sudo
    command_check curl
}
make_install_deps(){
    local pkglist_to_install=()
    for pkg in "${pacman_build_depends[@]}" doxygen; do
        if ! pkg_check "$pkg"; then
            pkglist_to_install+=("$pkg")
        fi
    done
    if (( "${#pkglist_to_install[@]}" > 0 )); then
        sudo apt install "${pkglist_to_install[@]}"
    fi
}
make_envconf(){
    case "$CARCH" in
        "x86_64")
            config_chost="x86_64-pc-linux-gnu"
            config_carchflags="-march x86-64 -mtune=generic"
        ;;
    esac
}
make_prepare(){
    mkdir -p "$build_dir/build"

    if [[ -n "$(ls "$build_dir" 2> /dev/null)" ]]; then
        (
            cd "$build_dir" || return 1
            git pull
        )
    else
        git clone "$pacman_repo" "$build_dir"
    fi
    git -C "$build_dir" checkout "$checkout_branch"
}

make_build(){
    cd "$build_dir" || return 1
    mkdir -p ./build
    cd ./build || return 1

    meson --prefix=/usr --buildtype=plain  \
        -Ddoc=enabled -Duse-git-version=true \
        -Dscriptlet-shell=/bin/bash \
        -Dldconfig=/usr/sbin/ldconfig \
        -Dkeyringdir=keyrings \
        ../
    ninja
}
make_backup(){
    local file
    for file in "${backup_files[@]}"; do
        if [[ -e "$file" ]]; then
            sudo cp -a "$file" "$file.bak"
        fi
    done
}
make_install(){
    cd "$build_dir/build" || return 1
    sudo DESTDIR="$destdir" ninja install
}
make_uninstall(){
    cd "$build_dir/build" || return 1
    sudo DESTDIR="$destdir" ninja uninstall
    sudo rm -rf "${destdir}/$config_sysconfdir/pacman.conf"
    sudo rm -rf "${destdir}/$config_sysconfdir/makepkg.conf"
    sudo rm -rf "$destdir/$config_sysconfdir/pacman.d/mirrorlist"
}
make_pacmanconf(){
    cd "$build_dir" || return 1
    sudo mkdir -p "${destdir}/$config_sysconfdir/pacman.d"

    sed \
        -e "s|@ROOTDIR@|$config_rootdir|g" \
        -e "s|@localstatedir@|$config_localstatedir|g" \
        -e "s|@sysconfdir@|$config_sysconfdir|g" "$current_dir/pacman.conf.in" | \
    sudo install -m644 /dev/stdin "${destdir}/$config_sysconfdir/pacman.conf"
}
make_makepkgconf(){
    cd "$build_dir" || return 1
    sudo mkdir -p "${destdir}/$config_sysconfdir"


    sed \
        -e "s|@CARCH@|$config_carch|g" \
        -e "s|@CHOST@|$config_chost|g" \
        -e "s|@CARCHFLAGS@|$config_carchflags|g" "$current_dir/makepkg.conf.in" | \
    sudo install -m644 /dev/stdin "${destdir}/$config_sysconfdir/makepkg.conf"
}
make_mirrorlist(){


    #if [[ -e "$destdir/$config_sysconfdir/pacman.d/mirrorlist" ]]; then
    #   sudo mv "$destdir/$config_sysconfdir/pacman.d/mirrorlist" "$destdir/$config_sysconfdir/pacman.d/mirrorlist.old"
    #fi
    sudo curl -L -o "$destdir/$config_sysconfdir/pacman.d/mirrorlist" "https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&ip_version=6" 


}
make_backup_restore(){
    local file
    for file in "${backup_files[@]}"; do
        if [[ -e "$file.bak" ]]; then
            sudo mv "$file.bak" "$file"
        fi
    done
}


make_check_os
make_check_command_deps
make_install_deps
make_envconf
make_prepare
if [[ "$uninstall" = true ]]; then
    make_uninstall
else
    make_build
    make_backup
    make_install
    make_pacmanconf
    make_makepkgconf
    make_mirrorlist
    make_backup_restore
fi
