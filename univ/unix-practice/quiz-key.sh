#!/usr/bin/env sh
# shellcheck disable=SC2034,SC3045

# question_n=<質問>,<正解>,<選択肢1>,<選択肢2>...
question_1="Ubuntu 18.04 LTSのコードネームは？,1,Bionic Beaver,Focal Fossa,Jammy Jellyfish"
question_2="Ubuntu 16.04 LTSで採用されていたデスクトップ環境は？,2,Xfce,Unity,Gnome"
question_3="現在Ubuntuで公式フレーバーが存在しないデスクトップ環境は？,1,Cinnamon,Xfce,Unity"
question_4="Bash 5で利用できる機能は？,4,無名関数,型宣言,オブジェクト継承,連想配列"
question_5="LinuxカーネルでNTFSを完全に読み書き可能になるドライバを書いた会社は？,2,Canonical,Paragon Software,RedHat,Oracle"
#question_2="∫cosxdx,2,-tanx+C,sinx+C,cosX+C"
#question_3="前橋から最も遠いのは？, "

set -e -u
print_eval(){
    eval "echo \${$1-""}"
}
get_csv(){
    print_eval "$1" | cut -d "," -f "${2-1}"
}
is_empty(){
    [ -z "$(print_eval "$1")" ]
}
get_csvline(){
    print_eval "$1" | tr "," "\n"
}
len_csv(){
    get_csvline "$1" | wc -l
}
get_choices(){
    get_csvline "$1" | tail -n "$(( $(len_csv "$1") - 2 ))"
}
get_answer(){
    get_choices "$1" | head -n "$( get_csv "$1" 2 )" | tail -n 1
}

capture_key(){
    IFS= read -r -n1 -s select
    if [ "$select" = "$(printf '\x1b')" ]; then
        read -r -n2 -s rest
        select="$select$rest"
    else
        if [ "$select" = '' ] ;then
            echo "Enter"
            return 0
        else
            read -r rest
            echo "$select$rest"
            return 0
        fi
    fi

    case $select in
        "$(printf '\x1b\x5b\x41')")
            echo "Up"
            ;;
        "$(printf '\x1b\x5b\x42')")
            echo "Down"
            ;;
        "$(printf '\x1b\x5b\x43')")
            echo "Right"
            ;;
        "$(printf '\x1b\x5b\x44')")
            echo "Left"
            ;;
        "$(printf '\x20')")
            echo "Space"
            ;;
    esac
    unset select
}

ask_question(){
    current=1
    choices_num="$(get_choices "$1" | wc -l)"
    while true; do
        lineno=0
        for line in $(seq 1 "${choices_num}" ); do
            lineno=$(( lineno+1 ))
            show=$(get_csv "$1" $(( 2+line )) | tr -d "\n")
            if [ "$lineno" = $current ]; then
                { printf "\033[4m" && printf "\033[1m" ;} >&2
                echo " > $show" >&2
            else
                echo "   $show" >&2
            fi
            printf "\033[0m" >&2
        done
        unset lineno line show
        key=$(capture_key)
        case "$key" in
            "Up")
                if [ "$current" != 1 ]; then
                    current=$(( current - 1 ))
                fi
                ;;
            "Down")
                #echo "$current:$choices_num"
                if [ $current != "$((choices_num))" ]; then
                    current=$(( current + 1 ))
                fi
                ;;
            "Enter")
                get_csv "$1" $(( 2+current )) | tr -d "\n"
                return 0
                ;;
        esac
        for line in $(seq 1 "${choices_num}" ); do
            { printf "\033[1A" && printf "\033[2K"; } >&2
        done 
    done
}

ask(){
        if [ "$(ask_question "$1")" = "$(get_answer "$1")" ]; then
            printf "\n正解です!\n\n" >&2
            return 0
        else
            printf "\nはずれです!\n\n" >&2
            return 1
        fi
}

main(){
    question_num=1
    while true; do
        is_empty "question_$question_num" && break
        get_csv question_$question_num 1
        if ask question_$question_num; then
            question_num=$(( question_num+1 ))
        fi
    done
}

main
