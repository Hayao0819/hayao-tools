#!/usr/bin/env sh
set -e -u
echo "Ubuntu 18.04 LTSのコードネームは？"
echo "a: Bionic Beaver | b: Focal Fossa | c: Jammy Jellyfish"
printf "%s" ":"
read -r answer
case "$(echo "$answer" | tr "[:upper:]" "[:lower:]")" in
    b|c)
        echo "はずれです!"
        ;;
    a)  
        echo "正解です!"
        ;;
    *)
        echo "abcのいずれかを入力して下さい"
        ;;
esac
