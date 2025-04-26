/*
 * lexer.c
 *
 *   正規表現の字句解析ルーチン
 *
 */
#include <ctype.h>  /* isdigit */
#include <stdio.h>  /* fprintf */
#include <stdlib.h> /* atoi */
#include <string.h>

#include "regmatch.h"

Lexer* new_lexer(const char* input) {
    Lexer* lexer = (Lexer*)malloc(sizeof(Lexer));
    if (!lexer) return NULL;

    lexer->reg_string = strdup(input);  // 入力文字列のコピー
    lexer->current_lexing = lexer->reg_string;

    // トークンの初期化
    lexer->current_token.id = 0;
    lexer->current_token.val = 0;

    return lexer;
}

int lexer_do(Lexer* lexer) {
    while (lexer->current_token.id != EOREG) {
        get_token(lexer);
        print_token(lexer->current_token, lexer->current_token.val);
    }
    return 0;
}

void lexer_close(Lexer* lexer) {
    free(lexer->reg_string);
    free(lexer);
}

/* get_token: 字句解析ルーチン */
void get_token(Lexer* lexer) {
    char c = *lexer->current_lexing;
    lexer->current_token.val = *lexer->current_lexing;

    if (c == '\0') {
        // curr_token = EOREG;
        lexer->current_token.id = EOREG;
        return;
    }
    if (c == '\\') {
        lexer->current_lexing++;
        c = *lexer->current_lexing;
        lexer->current_token.val = *lexer->current_lexing;

        switch (c) {
            case 'e':
                // curr_token = ESCAPE;
                lexer->current_token.id = ESCAPE;
                break;
            case '0':
                // curr_token = NULLCHAR;
                lexer->current_token.id = NULLCHAR;
                break;
            case '*':
                // curr_token = LETTER;
                lexer->current_token.id = AST;
                break;
            case '.':
                // curr_token = LETTER;
                lexer->current_token.id = CONC;
                break;
            case '(':
                // curr_token = LETTER;
                lexer->current_token.id = LPAR;
                break;
            case ')':
                // curr_token = LETTER;
                lexer->current_token.id = RPAR;
                break;
            case '|':
                // curr_token = LETTER;
                lexer->current_token.id = VERT;
                break;
            default:
                fatal_error("Invalid escape sequence");
        }
        lexer->current_lexing++;
        return;
    }

    switch (c) {
        case '*':
            // curr_token = AST;
            lexer->current_token.id = AST;
            break;
        case '.':
            // curr_token = CONC;
            lexer->current_token.id = CONC;
            break;
        case '(':
            // curr_token = LPAR;
            lexer->current_token.id = LPAR;
            break;
        case ')':
            // curr_token = RPAR;
            lexer->current_token.id = RPAR;
            break;
        case '|':
            // curr_token = VERT;
            lexer->current_token.id = VERT;
            break;
        default:
            if (isalpha(c) || isdigit(c)) {
                // curr_token = LETTER;
                lexer->current_token.id = LETTER;
            } else {
                fatal_error("Invalid character");
            }
            break;
    }

    // reg_string++;
    lexer->current_lexing++;
}

void print_token(Token tok, char c) {
    print_token_from_id(tok.id, c);
}

/* print_token: token を表示する */
void print_token_from_id(TokenID tok, char c) {
    switch (tok) {
        case NULLCHAR:
            printf("NULLCHAR\n");
            break;
        case ESCAPE:
            printf("ESCAPE\n");
            break;
        case AST:
            printf("AST\n");
            break;
        case CONC:
            printf("CONC\n");
            break;
        case LPAR:
            printf("LPAR\n");
            break;
        case RPAR:
            printf("RPAR\n");
            break;
        case VERT:
            printf("VERT\n");
            break;
        case LETTER:
            printf("LETTER(%c)\n", c);
            break;
        case EOREG:
            printf("EOREG\n");
            break;
        default:
            fatal_error("Invalid token");
            break;
    }
}
