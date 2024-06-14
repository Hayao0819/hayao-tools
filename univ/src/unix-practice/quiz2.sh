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

ask_question(){
    {
        get_choices "$1" | grep -nE "." | sed "s|:| |"
        printf "> "
    } >&2
    read -r _input
    if ! seq 1 "$(get_choices "$1" | wc -l)" | grep -x "$_input" 2> /dev/null 1>&2; then
        echo "回答は$(seq 1 "$(get_choices "$1" | wc -l)" | tr "\n" "," | sed "s|,$||")を入力してください" >&2
        return 1
    fi
    get_csv "$1" $(( _input + 2 ))
}

ask(){
        rel="$(ask_question "$1")"
        if [ "$rel" = "$(get_answer "$1")" ]; then
            printf "正解です!\n\n" >&2
            return 0
        elif [ -z "${rel-""}" ]; then
            echo
            return 1
        else
            printf "はずれです!\n\n" >&2
            return 1
        fi
}

main(){
    question_num=1
    while true; do
        is_empty "question_$question_num" && break
        get_csv question_$question_num 1
        #ask question_$question_num || true
        if ask question_$question_num; then
            question_num=$(( question_num+1 ))
        fi
    done
}

main
