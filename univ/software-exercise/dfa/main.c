/*
 * main.c
 *
 *   正規表現構文解析プログラムのメインルーチン
 *
 *
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "regmatch.h"

bool debug = true; /* デバッグ情報を表示する(1)/しない(0) */
char* reg_string;  /* 正規表現文字列 */
char* option;

int main(int argc, char* argv[]) {
    if (argc > 3) {
        fprintf(stderr, "Too many arguments\n");
        return 1;
    }

    int d_option = -1;

    for (int i = 1; i < argc; ++i) {
        char* arg = argv[i];
        if (strncmp(arg, "-d", 2) == 0 && strlen(arg) == 3) {
            char digit = arg[2];
            if (digit == '0' || digit == '1' || digit == '2' || digit == '3' || digit == '4') {
                d_option = digit - '0';
            } else {
                fprintf(stderr, "Unknown option: %s\n", arg);
                print_usage(argv);
                return 1;
            }
        } else if (arg[0] == '-') {
            fprintf(stderr, "Unknown option: %s\n", arg);
            return 1;
        } else {
            if (reg_string != NULL) {
                fprintf(stderr, "Too many arguments\n");
                return 1;
            }
            reg_string = arg;
        }
    }

    if (reg_string == NULL || d_option == -1) {
        print_usage(argv);
        return 1;
    }

    switch (d_option) {
        case 0:
            printf("%s\n", reg_string);
            break;
        case 1:
            printf("トークン列(字句解析結果)\n");
            lexer();
            break;
        case 2:
            printf("構文木(構文解析結果)\n");
            parse();
            break;
        case 3:
            printf("NFA\n");
            make_nfa();
            break;
        case 4:
            printf("DFA(決定性有限オートマトン)\n");
            make_dfa();
            break;
    }

    return 0;
}

/* fatal_error: エラーメッセージを表示して終了 */
void fatal_error(char* s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

void print_usage(char* argv[]) {
    fprintf(stderr, "Usage: %s [-d0|-d1|-d2|-d3|-d4] <regex>\n", argv[0]);
}
