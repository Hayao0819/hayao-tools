#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeu

#ArchNewsRSSURL="https://www.archlinux.jp/feeds/news.xml"
ArchNewsRSSURL="https://archlinux.org/feeds/news/"
CachePath="${XDG_STATE_HOME-"$HOME/.local/state"}/archnews.latest"
AutoStartPath="${XDG_CONFIG_HOME-"${HOME}/.config"}/autostart/archnews.desktop"
RSSXML=()
IgnoreCache=false
ShowMode="ZENITY"

FSBLIB_PATHLIST=(
    "/usr/lib/archnews.sh" 
    #"$HOME/Git/FasBashLib/fasbashlib.sh"
)

LoadLib(){
    local _Err=false
    for File in "${FSBLIB_PATHLIST[@]}"; do
        # shellcheck source=/dev/null
        [[ -e "$File" ]] && source "$File"
    done

    if [[ -z "${FSBLIB_VERSION-""}" ]]; then
        Msg.Err "Failed to load FasBashLib"
        _Err=true
    fi

    if ! Array.Includes FSBLIB_LIBLIST "Parsrs"; then
        Msg.Err "FasBashLibをParsrsを含めてビルドしてください"
        _Err=true
    fi

    if [[ "$_Err" = true ]]; then
        
    fi
}

GetLatestNewsURL(){ PrintArray "${RSSXML[@]}" | grep "^/rss/channel/item/link.*" | URL.Path | head -n 1; }

GetNews(){
    local Line CurrentTitle CurrentLink InTarget=false
    while read -r Line; do
        case "$Line" in
            "/rss/channel/item/title "*)
                CurrentTitle="$(cut -d " " -f 2- <<< "$Line")"
                continue
                ;;
            "/rss/channel/item/link "*)
                CurrentLink="$(cut -d " " -f 2- <<< "$Line" | URL.Path)"
                if [[ "$CurrentLink" = "$1" ]]; then
                    InTarget=true
                    echo "$CurrentTitle"
                else
                    InTarget=false
                fi
                continue
                ;;
            "/rss/channel/item")
                InTarget=false
                continue
                ;;
            *)
                if [[ "$InTarget" = true ]]; then
                    cut -d " " -f 2- <<< "$Line"
                fi
                ;;
        esac
    done < <(PrintArray "${RSSXML[@]}" | grep "^/rss/channel/item.*")
}


FormatXML(){
    sed -e 's|\\n| |g' -e 's|\&lt;|<|g' -e 's|\&gt;|>|g' -e 's|\&amp;|&|g' -e 's|\&quot;|"|g' -e 's|\&apos;||g' | sed -e "s|<[^>]*>||g" | sed -e "s|lt;p>||g"
}


Main(){
    # XMLを解析して配列に格納
    ArrayAppend RSSXML < <(curl -sL "$ArchNewsRSSURL" | Parsrs.Xml)
    { (( "${#RSSXML[@]}" < 1 )) || [[ -z "${RSSXML[*]}" ]]; } && {
        Msg.Err "RSSの取得に失敗しました"
        exit 1
    }

    local LatestNewsURL
    LatestNewsURL="$(GetLatestNewsURL)"
    if [[ -z "$LatestNewsURL" ]]; then
        Msg.Err "最新のニュースの取得ができませんでした"
        exit 1
    fi

    if [[ -e $CachePath ]] && ! Bool "IgnoreCache" && [[ "$(cat "$CachePath")" = "$LatestNewsURL" ]]; then
        Msg.Info "最新のニュースは既に確認済みです"
        exit 0
    fi

    # キャッシュを作成
    echo "$LatestNewsURL" > "$CachePath"

    # 最新ニュースを取得
    local LatestNews=()
    ArrayAppend LatestNews < <(GetNews "$(GetLatestNewsURL)")

    # ニュースを出力
    case "${ShowMode^^}" in
        "CLI")
            echo "<${LatestNews[0]}>"
            echo "${LatestNews[1]}" | FormatXML
            echo "(Last update: ${LatestNews[4]}  By ${LatestNews[3]}"
            ;;
        "ZENITY")
            zenity --info \
                --title="ArchNews - ${LatestNews[0]}" \
                --text="$(FormatXML <<< "${LatestNews[1]}")"
            ;;
    esac
    return 0
}

LoadLib

ParseArg LONG="help,force,cli,gui,english,japanese,clean,startup" SHORT="hfcgej" -- "${@}"
eval set -- "${OPTRET[*]}"
while true; do
    case "${1-""}" in
        "-c" | "--cli")
            ShowMode="CLI"
            shift
            ;;
        "-g" | "--gui")
            ShowMode="ZENITY"
            shift 1
            ;;
        "-e" | "--english")
            ArchNewsRSSURL="https://archlinux.org/feeds/news/"
            shift 1
            ;;
        "-j" | "--japanese")
            ArchNewsRSSURL="https://www.archlinux.jp/feeds/news.xml"
            shift 1
            ;;
        "-h" | "--help")
            echo "Usage: $0 "
            echo "  -g, --gui       : GUIモード"
            echo "  -c, --cli       : CLIモード"
            echo "  -f , --force    : 強制的に表示"
            echo "  -h, --help      : ヘルプを表示"
            echo "  --clean         : 一時データを削除して終了"
            echo "  --startup       : スタートアップのオンオフ "
            exit 0
            ;;
        "-f" | "--force")
            IgnoreCache=true
            shift 1
            ;;
        "--clean")
            [[ -e "$CachePath" ]] && rm -f "$CachePath"
            exit 0
            ;;
        "--startup")
            if [[ -e "$AutoStartPath" ]]; then
                rm -f "$AutoStartPath"
                Msg.Info "Disable autostart"
                exit 0
            elif [[ -e "/usr/share/applications/show-archnews.desktop" ]]; then
                cp "/usr/share/applications/show-archnews.desktop" "$AutoStartPath"
                Msg.Info "Enable autostart"
                exit 0
            else
                Msg.Err "You must install ArchNews with pacman to enable autostart."
                exit 1
            fi
            shift 1
            ;;
        "--")
            shift 1 || true
            break
            ;;
        *)
            break
            ;;
    esac
done

Main
