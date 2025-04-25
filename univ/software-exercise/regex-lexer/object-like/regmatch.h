/*
 * regmath.h
 *
 *   正規表現の字句解析ルーチンヘッダファイル
 *
 */

#include <stdbool.h> /* bool */

/* トークン */
typedef enum TokenID {
    NULLCHAR,  // \0
    ESCAPE,    // \e
    AST,       // *
    CONC,      // .
    LPAR,      // (
    RPAR,      // )
    VERT,      // |
    LETTER,    // a-zA-Z0-9
    EOREG,     // 正規表現の終端

    // いつか対応したい
    // RSQU,  // [
    // LSQU,  // ]
    // HYPHEN,  // -
    // CARET,  // ^
    // DOLLAR,  // $
    // BANG,  // !
    // QUEST,  // ?
} TokenID;

typedef struct Token {
    TokenID id; /*トークンID */
    char val;   /* トークンの意味値 */
} Token;

/* lexer: 字句解析して結果を表示 */
typedef struct Lexer {
    char* reg_string;     /* 正規表現文字列 */
    char* current_lexing; /* 現在の字句解析位置 */
    Token current_token;  /* 1番最近に読んだトークン */
} Lexer;

/* from main.c */
extern bool debug;                /* デバッグ情報を表示する(1)/しない(0) */
extern void fatal_error(char* s); /* エラーメッセージを表示して終了 */

/* from lexer.c */
extern Lexer* new_lexer(const char* input);
extern int lexer_do(Lexer* lexer);
extern void lexer_close(Lexer* lexer);
extern void get_token(Lexer* lexer);                  /* 字句解析ルーチン */
extern void print_token(Token tok, char c);           /* token を表示する */
extern void print_token_from_id(TokenID tok, char c); /* token を表示する */
