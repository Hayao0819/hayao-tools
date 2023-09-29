#!/usr/bin/env bash
# shellcheck disable=SC2034

#-- Configs --#
# Server
mk_api_services="/api/services"

# m3u8 playlist
# %CH%: 物理的なチャンネル番号
# %SEVICE%: serviceId
# %CH_TYPE%: GR | CS | BS
# %CH_TYPE_JP%: 地上波 | CS | BS
# %CH_NAME%: チャンネル名
# %MK_IP%: Miraurun IP
pl_m3u8_header="#EXTM3U\n#EXTVLCOPT:network-caching=1000"
pl_m3u8_content="#EXTINF:-1,%CH_TYPE_JP% - %CH_NAME%\nhttp://%MK_IP%/api/channels/%CH_TYPE%/%CH%/services/%SERVICE%/stream/"


#-- Script config --#
set -e -u -E -o pipefail

#-- Set up global vars --#
: "${ch_filter:="false"}"
: "${pl_path:="./tv_playlist.m3u8"}"
: "${mk_ip:="localhost"}"
: "${mk_port:="40772"}"


#-- Functions --#
# get_from_json <variable name> <jq args...>
# example: get_from_json api_services
get_from_json(){
    local _var="$1"
    shift 1 || true
    jq -r "$@" <<< "$(eval "echo \"\${${_var}}\"")" || return $?
}

# get_json <entry point>
get_json(){
    curl --no-progress-meter -L -f "http://$mk_ip:$mk_port${1}"
}

chtype_to_text(){
    case "$1" in
        "GR") 
            echo "地上波"
            ;;
        *)
            echo "$1"
            ;;
    esac
}

# parse_template VAR=VALUE
# stdin: text
parse_template(){
    local _sed_args=() i
    for i in "$@"; do
        _sed_args+=("-e" "s|%$(cut -d "=" -f 1 <<< "$i")%|$(cut -d "=" -f 2 <<< "$i")|g")
    done
    sed "${_sed_args[@]}"
}

scirpt_usage(){
    cat << "EOF"
Generate m3u8 playlist from Mirakurun API

Usage: $0 [IP]

Options:
    -i | --ip IP      Specify mirakurun IP address  (DEFAULT=localhost)
    -p | --port PORT  Specify mirakurun port (DEFAULT=40772)
    -l | --list FILE  Specify the path of the playlist to ganarate
    -f | --filter     Exclude same channels
    -h | --help       Show this help message.
EOF
}

#-- Entry point --#
main(){
    local mk_api_services_json=""

    _parse_args(){
        local _no_args=()

        # usage: hasarg "${2}"
        hasarg(){
            [[ "${1-""}" ]] || {
                echo "Spedify args. Please reas the usage."
                exit 1
            }
        }

        while [[ -n "${1-""}" ]]; do
            case "$1" in
                "-l" | "--list")
                    hasarg "${2-""}" && pl_path="$2"
                    shift 2
                    ;;
                "-p" | "--port")
                    hasarg "${2-""}" && mk_port="$2"
                    shift 2
                    ;;
                "-i" | "--ip")
                    hasarg "${2-""}" && mk_ip="$2"
                    shift 2
                    ;;
                "-f" | "--filter")
                    ch_filter=true
                    shift 1
                    ;;
                "-h" | "--help")
                    scirpt_usage
                    exit 0
                    ;;
                *)
                    _no_args+=("$1")
                    shift 1
                    ;;
            esac
        done

        mk_ip="${_no_args[0]:-"$mk_ip"}"
    }

    _prepare_json(){
        mk_api_services_json="$(get_json "$mk_api_services")"
    }

    _filter_json(){
        local channel_list=() ch
        readarray -t channel_list < <(get_from_json mk_api_services_json -c ".[].channel.channel" | sort -n | uniq)

        _make_filtered_json(){
            {
                printf "["
                for ch in "${channel_list[@]}"; do
                    get_from_json mk_api_services_json -rc ".[] | select(.channel.channel == \"$ch\")" | head -n 1
                    printf ","
                done
                printf "]"
            } | sed "s/,]$/]/g"
        }

        
        mk_api_services_json="$(_make_filtered_json | jq "sort_by(.remoteControlKeyId)")"
    }

    _generate_playlist(){
        echo "Generating playlist to $pl_path ..."
        
        {
            echo -e "$pl_m3u8_header"
            while read -r json_per_ch; do
                echo -e "$(parse_template \
                    MK_IP="$mk_ip" \
                    CH="$(get_from_json json_per_ch ".channel.channel")" \
                    SERVICE="$(get_from_json json_per_ch ".serviceId")" \
                    CH_TYPE="$(get_from_json json_per_ch ".channel.type")" \
                    CH_TYPE_JP="$(chtype_to_text "$(get_from_json json_per_ch ".channel.type")")" \
                    CH_NAME="$(chtype_to_text "$(get_from_json json_per_ch ".name")")" \
                    <<< "$pl_m3u8_content")"
            done < <(get_from_json mk_api_services_json -c ".[]")
        } > "$pl_path"
    }

    _parse_args "$@"
    _prepare_json
    "${ch_filter}" && _filter_json
    _generate_playlist
}

#-- Start --#
main "$@"
