/*
 * main.c
 *
 *   regex プログラムのメインルーチン
 *
 *
 */

#include <stdbool.h> /* bool */
#include <stdio.h>   /* fprintf */
#include <stdlib.h>  /* exit */

#include "regmatch.h"

void fatal_error(char* s); /* エラーメッセージを表示して終了 */

bool debug = true; /* デバッグ情報を表示する(true)/しない(false) */

int main(int argc, char* argv[]) {
    /*debug = 1;*/

    if (argc != 2) {
        if (argc > 2) {
            fprintf(stderr, "Too many arguments\n");
        } else {
            fprintf(stderr, "Usage: %s <regex>\n", argv[0]);
        }
        fprintf(stderr, "Usage: %s <regex>\n", argv[0]);
        return 1;
    }

    if (debug) {
        printf("Regular expression: %s\n", argv[1]);
    }

    Lexer* lexer = new_lexer(argv[1]);
    lexer_do(lexer);
    lexer_close(lexer);
    return 0;
}

/* fatal_error: エラーメッセージを表示して終了 */
void fatal_error(char* s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}
