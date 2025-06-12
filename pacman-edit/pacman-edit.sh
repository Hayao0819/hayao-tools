#!/usr/bin/env bash

set -euo pipefail

target_pkgname=''
editor="${EDITOR-""}"
exec_target=''

parse_args() {
    while getopts "e:hr" opt; do
        case "$opt" in
        e)
            editor="$OPTARG"
            ;;
        h)
            echo "Usage: $0 [-e <editor>] [-r] package_name" 1>&2
            echo "  -e <editor>       : Specify the editor to use (default: \$EDITOR)" 1>&2
            echo "  -r                : Remove backup file and exit" 1>&2
            echo "  -h                : Show this help message" 1>&2
            exit 0
            ;;
        r)
            exec_target='remove_backup'
            ;;
        *)
            echo "Usage: $0 [-e <editor>] package_name" 1>&2
            exit 1
            ;;
        esac
    done
    shift $((OPTIND - 1))
    target_pkgname="$1"

}

remove_backup() {
    local backupfile="$1.bak"
    if [ -e "$backupfile" ]; then
        rm -f "$backupfile" || {
            echo "Error: Failed to remove backup file '$backupfile'." 1>&2
            return 1
        }
        echo "Backup file '$backupfile' removed successfully."
    else
        echo "No backup file found to remove."
    fi
}

is_target_remove_backup() {
    [[ "$exec_target" == "remove_backup" ]]
}

check_env() {

    if ((UID != 0)); then
        echo "Error: This script must be run as root." 1>&2
        return 1
    fi

    if ! is_target_remove_backup; then
        if [ -z "$editor" ]; then
            echo "Error: No editor specified. Please set the EDITOR environment variable or use the -e option." 1>&2
            return 1
        fi

        if ! type pacman &>/dev/null; then
            echo "Error: pacman is not installed or not found in PATH." 1>&2
            return 1
        fi

        if ! type "$editor" &>/dev/null; then
            echo "Error: Editor '$editor' not found." 1>&2
            return 1
        fi
    fi

    if [ -z "$target_pkgname" ]; then
        echo "Error: Package name is required." 1>&2
        return 1
    fi

    if ! pacman -Qq "$target_pkgname" >/dev/null 2>&1; then
        echo "Error: Package '$target_pkgname' is not installed." 1>&2
        return 1
    fi
}

check_file_perm() {
    local file="$1"
    if [ ! -e "$file" ]; then
        echo "Error: File '$file' does not exist." 1>&2
        return 1
    fi
    if [ ! -r "$file" ]; then
        echo "Error: File '$file' is not readable." 1>&2
        return 1
    fi
    if [ ! -w "$file" ]; then
        echo "Error: File '$file' is not writable." 1>&2
        return 1
    fi
}

exec_editor() {
    exec "$editor" "$1" || {
        echo "Error: Failed to open '$1' with editor '$editor'." 1>&2
        return 1
    }
}

create_backup() {
    local file="$1"
    local backupfile="$file.bak"
    if [ -e "$backupfile" ]; then
        echo "Warning: Backup file '$backupfile' already exists. Overwriting." 1>&2
    fi
    cp "$file" "$backupfile" || {
        echo "Error: Failed to create backup for '$file'." 1>&2
        return 1
    }
}

main() {
    parse_args "$@"
    check_env || return 1

    # Assemble the path to the package description file
    local dbpath
    dbpath="$(pacman-conf DBPath)"
    local dirname
    dirname=$(pacman -Q "$target_pkgname" | tr " " "-")
    local descfile="$dbpath/local/$dirname/desc"

    if is_target_remove_backup; then
        remove_backup "$descfile" || return 1
        return 0
    fi

    check_file_perm "$descfile" || return 1
    create_backup "$descfile" || return 1
    exec_editor "$descfile" || return 1
}

main "$@"
