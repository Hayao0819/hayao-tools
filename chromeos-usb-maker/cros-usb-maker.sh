#!/usr/bin/env bash
set -euo pipefail

cros_recovery_json_url=()
cros_recovery_json=()
cros_selected_json=""
work_dir="$HOME/.cros-usb-maker"
target_device=""


cros_recovery_json_url+=(https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.json)
cros_recovery_json_url+=(https://dl.google.com/dl/edgedl/chromeos/recovery/cloudready_recovery.json)

# cros_recovery_jsonを定義
get_json(){
    local url
    readarray -t cros_recovery_json < <(
        for url in "${cros_recovery_json_url[@]}"; do
            curl -s "$url" | jq ".[]"
        done | jq -c
    )
}

show_image_list(){
    local cros_values=() max_length=30 zenity_args=()
    mapfile -t cros_values < <(jq -r '.name, .chrome_version, .channel' <<< "${cros_recovery_json[@]}")
    
    # 長い文字を隠す
    for index in "${!cros_values[@]}"; do
        (( ${#cros_values["$index"]} > max_length )) || continue
        cros_values["$index"]="${cros_values[$index]:0:$max_length}..."
    done

    # インデックスを付与
    for index in "${!cros_values[@]}"; do
        (( index % 3 == 0 )) && zenity_args+=("$((index / 3))")
        zenity_args+=("${cros_values[$index]}")
    done

    local selected_index
    if ! selected_index=$(zenity \
        --list --title="Select Chrome OS Image" --text="Select Chrome OS Image" \
        --hide-column=1 --print-column=1 --mid-search \
        --column="Index" --column="Image" --column="Version" --column="Channel" "${zenity_args[@]}"); then

        exit 1
    fi

    cros_selected_json="${cros_recovery_json[$selected_index]}"
}

download_cros_img(){
    mkdir -p "$work_dir"
    local cros_zip_name cros_url cros_sha1sum cros_zip_filesize

    cros_url="$(jq -r '.url' <<< "$cros_selected_json")"
    cros_zip_name="$(basename "$cros_url")"
    cros_sha1sum="$(jq -r '.sha1' <<< "$cros_selected_json")"
    cros_zip_filesize="$(jq -r '.zipfilesize' <<< "$cros_selected_json")"

    {
        if [[ -e "$work_dir/$cros_zip_name" ]]; then
            exit 0
        fi
        curl -f -s "${cros_url}" -o "$work_dir/$cros_zip_name" || {
            kill -9 "$$"
            zenity --error --text="ダウンロードに失敗しました" &
            exit 1
        }
    } &
    sleep 1

    # show progress
    while true; do
        local cros_zip_filesize_now cros_zip_filesize_now_percent
        cros_zip_filesize_now="$(du -b "$work_dir/$cros_zip_name" | cut -f1)"
        cros_zip_filesize_now_percent="$((cros_zip_filesize_now * 100 / cros_zip_filesize))"
        echo "$cros_zip_filesize_now_percent"
        (( cros_zip_filesize_now_percent == 100 )) && break
        sleep 0.1
    done | zenity --progress --time-remaining --auto-close --auto-kill --title="Download Chrome OS Image" --text="Download Chrome OS Image"

    # check sha1sum
    zenity --info --text="ダウンロードしたファイルのチェックサムを確認しています。しばらくお待ちください..." &
    local pid="$!"
    calclated_sha1sum=$(sha1sum "$work_dir/$cros_zip_name" | cut -d' ' -f1)
    kill "$pid" 2> /dev/null || true

    #echo "$calclated_sha1sum"
    #echo "$cros_sha1sum"

    [[ "$calclated_sha1sum" = "$cros_sha1sum" ]] || {
        zenity --error --text="ダウンロードしたファイルのチェックサムが一致しませんでした" &
        exit 1
    }
    return 0
}

extract_zip(){
    local cros_bin_name cros_url cros_zip_name cros_bin_filesize
    cros_url="$(jq -r '.url' <<< "$cros_selected_json")"
    cros_zip_name="$(basename "$cros_url")"
    cros_bin_name="$(jq -r '.file' <<< "$cros_selected_json")"
    cros_bin_filesize="$(jq -r '.filesize' <<< "$cros_selected_json")"

    {
        if [[ -e "$work_dir/$cros_bin_name" ]]; then
            exit 0
        fi
        unzip -q "$work_dir/$cros_zip_name" -d "$work_dir" || {
            kill -9 "$$"
            zenity --error --text="解凍に失敗しました" &
            exit 1
        }

    } &

    sleep 1
    while true; do
        local cros_bin_filesize_now cros_bin_filesize_now_percent
        cros_bin_filesize_now="$(du -b "$work_dir/$cros_bin_name" | cut -f1)"
        cros_bin_filesize_now_percent="$((cros_bin_filesize_now * 100 / cros_bin_filesize))"
        echo "$cros_bin_filesize_now_percent"
        #echo "# $cros_bin_filesize_now / $cros_bin_filesize" >&2
        (( cros_bin_filesize_now_percent == 100 )) && break
        sleep 0.1
    done | zenity --progress --time-remaining --auto-close --auto-kill --title="Extract Chrome OS Image" --text="Extract Chrome OS Image"
}

get_usb_flash(){
    lsblk -l -o name,size,model,hotplug  | tr -s "\n "| tr -s " " | grep '1$' | grep -v 'sd.[0-9]'| grep sd | sed 's|^|/dev/|g' | sed 's/.$//'
}

select_usb_flash(){
    local device zenity_args
    while read -r device; do
        zenity_args+=("$(cut -d " " -f 1 <<< "$device")")
        zenity_args+=("$(cut -d " " -f 2 <<< "$device")")
        zenity_args+=("$(cut -d " " -f 3- <<< "$device")")
    done < <(get_usb_flash)

    local selected_device
    if ! selected_device=$(zenity \
        --list --title="Select USB Disk" --text="Select USB Disk" \
        --print-column=1 --extra-button="Update List"\
        --column="Device" --column="Size" --column="Model" "${zenity_args[@]}"); then

        if [[ "$selected_device" = "Update List" ]]; then
            select_usb_flash
            return
        fi
        exit 1
    fi

    if [[ "$selected_device" = "" ]]; then
        zenity --error --text="USB ディスクが選択されていません"
        select_usb_flash
        return
    fi

    zenity --question --text="USB ディスク $selected_device に書き込みますか？(${selected_device}の全てのデータは削除されます。)" || {
        select_usb_flash
        return
    }
    
    target_device="$selected_device"
    return 0
}

gksu(){
    pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" "$@"
}

run_dd(){
    local cros_bin_name
    cros_bin_name="$(jq -r '.file' <<< "$cros_selected_json")"

    cros_bin_filesize="$(du -b "$work_dir/$cros_bin_name" | cut -f1)"
    pv -p -s "${cros_bin_filesize}" < "$work_dir/$cros_bin_name" | gksu dd if=/dev/stdin of="${target_device}" bs=4M status=progress 2>&1 | zenity --progress --auto-close --pulsate --title="Write Chrome OS Image" --text="Writing Chrome OS Image. Please wait..." || {
        zenity --error --text="書き込みに失敗しました。"
        exit 1
    }

    

    zenity --info --text="書き込みが完了しました。"
}

get_json
show_image_list
download_cros_img
extract_zip
select_usb_flash
run_dd
