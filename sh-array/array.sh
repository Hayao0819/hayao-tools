#!/bin/sh

set -eu

FSBLIB_LEGACYARRAY_COMMONNAME="__FSBLIB_LEGACYARRAY_"
FSBLIB_LEGACYARRAY_ARRAYLIST=""

# Array_New <Array Name>
Array_New(){
    FSBLIB_LEGACYARRAY_ARRAYLIST="${FSBLIB_LEGACYARRAY_ARRAYLIST:+"${FSBLIB_LEGACYARRAY_ARRAYLIST},"}$1"
    eval "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX"=-1
}

# Array_Push <Array Name> <String>
Array_Push(){
    if ! Array_DefinedList | grep -qx "$1"; then
        #echo "$1 is not defined" >&2
        #return 1
        Array_New "$1"
    fi
    eval "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX"=$((${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX+1))
    #eval eval "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_ITEM_\${${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX}=\"\\\"${2}\\\"\""
    eval Array_Set "$1" "\${${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX}" "$2"
}

# Array_Set <Array Name> <Index> <String>
Array_Set(){
    # Make new array if not defined
    if ! Array_DefinedList | grep -qx "$1"; then
        #echo "$1 is not defined" >&2
        #return 1
        Array_New "$1"
    fi

    # Update Index if out of bounds
    if [ "$2" -gt "$(eval echo "\${${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX}")" ]; then
        eval "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX"="$2"
    fi

    eval "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_ITEM_${2}=\"${3}\""
}

Array_Get(){
    eval echo "\${${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_ITEM_${2}-""}"
}

Array_Print(){
    #for i in $(seq 0 $((${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX))); do
    #    eval echo "\${${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_ITEM_${i}}"
    #done

    for i in $(seq 0 "$(( $(Array_Length "$1") - 1 ))"  ); do
        Array_Get "$1" "$i" 
    done 
}

Array_PrintWithIndex(){
    for i in $(seq 0 "$(( $(Array_Length "$1") - 1 ))"  ); do
        echo "$i| $(Array_Get "$1" "$i" )"
    done 
}

Array_Length(){
    eval echo "\$(( ${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX + 1 ))"
}

Array_DefinedList(){
    echo "$FSBLIB_LEGACYARRAY_ARRAYLIST" | tr "," "\n"
}

Array_Pop(){
    eval unset "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_ITEM_\${${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX}"
    eval "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX"=$((${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX-1))
}

Array_Last(){
    eval echo "\$$(eval echo "${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_ITEM_\${${FSBLIB_LEGACYARRAY_COMMONNAME}${1}_INDEX}")"
}

# Array_FromFile <Array Name> <File>
Array_FromFile(){
    [ -e "$2" ] 
    while read -r line; do
        Array_Push "$1" "$line"
    done < "$2"
}

