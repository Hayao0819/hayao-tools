#!/bin/sh

Size="${1-"20"}"

HidariUe="┏"
HidariSita="┗"
MigiUe="┓"
MigiSita="┛"
Yoko="━"
#Tate="┃"
AidaUe="┳"
AidaSita="┻"
AidaHidari="┣"
AidaMigi="┫"
Cross="╋"


Width="$Size"
Height="$Size"


startcolor(){
    printf "\033[30;47m"
}

endcolor(){
    printf "\033[0m"
    printf "\n"
}


startcolor
{
    printf "%s" "${HidariUe}"
    for _ in $(seq $(( Width -1 ))); do
        printf "%s" "${Yoko}${AidaUe}"
    done
    printf "%s" "$Yoko$MigiUe"
}
endcolor



for __ in $(seq $((Height-1))); do
    startcolor
    {
        printf "%s" $AidaHidari
        for _ in $(seq $((Width-1))); do
            printf "%s" "$Yoko${Cross}"
        done
        printf "%s" "$Yoko$AidaMigi"
    }
    endcolor
done


startcolor
{
    printf "%s" "${HidariSita}"
    for _ in $(seq $(( Width -1 ))); do
        printf "%s" "${Yoko}${AidaSita}"
    done
    printf "%s" "$Yoko$MigiSita"
}
endcolor
