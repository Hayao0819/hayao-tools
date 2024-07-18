#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>

#define TARGET "RLFJHXDMKQVBWTIGZCEANYUSPOHLFJRXMKQBVITZECANYUSPOHLRFJXDKMQBWIGZECANYUSQOHLRFJXDKMQBVWITZECANYUSPOHLRFJXDKMQBVWITZECANYUSPOHLRFJXDKMQBWITZECANYUSPOHLRFJXDKMQBVWITZECANYUSPOHLRFJXDKMQBVWITZECANYUSPO"
#define ALPHABET "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

int main()
{
    // 配列として代入
    const char *str = TARGET;

    // 文字の出現回数を格納するための配列を初期化
    int count[26] = {0}; // アルファベットは26文字

    // 文字の出現回数をカウント
    for (int i = 0; str[i] != '\0'; i++)
    {
        printf("%d\n", str[i] - 'A');

        // AのASCIIコードは65
        // Aの場合、65 - 65 = 0
        count[str[i] - 'A']++;
    }

    // 最も多く出現する文字を求める
    int max_count = 0;
    char max_char;
    for (int i = 0; i < 26; i++)
    {
        if (count[i] > max_count)
        {
            max_count = count[i];
            max_char = ALPHABET[i];
        }
    }

    // 結果を出力
    printf("最も多く出現する文字: %c\n", max_char);
    printf("出現回数: %d\n", max_count);

    return 0;
}
