#ifndef REGMATCH_H
#define REGMATCH_H

/*
 * regmath.h
 *
 *   正規表現の字句解析ルーチンヘッダファイル
 *
 */

#include <stdbool.h> /* bool */

/* トークン */
typedef enum Token {
    NULLCHAR,  // \0
    ESCAPE,    // \e
    AST,       // *
    CONC,      // .
    LPAR,      // (
    RPAR,      // )
    VERT,      // |
    LETTER,    // a-zA-Z0-9
    EOREG,     // 正規表現の終端

    // いつか実装したい
    // RSQU,      // [
    // LSQU,      // ]
    // HYPHEN,    // -
    // CARET,     // ^
    // DOLLAR,    // $
    // BANG,      // !
    // QUEST,     // ?
} Token;

typedef struct PTree { /* 構文木 */
    Token tok;
    char val;
    struct PTree* left;
    struct PTree* right;
} PTree;

/* from main.c */
extern bool debug;                     /* デバッグ情報を表示する(1)/しない(0) */
extern char* reg_string;               /* 正規表現文字列 */
extern void fatal_error(char* s);      /* エラーメッセージを表示して終了 */
extern void print_usage(char* argv[]); /* 使用法を表示する */

/* from lexer.c */
extern Token curr_token;                    /* 1番最近に読んだトークン */
extern char token_val;                      /* トークンの意味値 */
extern int lexer(void);                     /* 字句解析結果を表示 */
extern void get_token(void);                /* 字句解析ルーチン */
extern void print_token(Token tok, char c); /* token を表示する */

/* from parse.c */
extern int parse(void);        /* 構文解析して正規表現を評価 */
extern void parse_error(void); /* 構文エラーで終了 */
extern void free_ptree(PTree* root);
extern PTree* eval_expr(void); /* expr を評価 */

/* nfa.c */
extern int make_nfa(void); /* NFA を生成して表示する */

typedef struct elist {
    int node;
    int label;
    struct elist* next;
} elist;

#define MAX_NVNUM 100

extern void free_ptree(PTree* root);


/* from nfa.c */
extern elist *nvlist[MAX_NVNUM]; /* NFAの頂点リスト */
extern int nvnum;                /* nvlist 中の有効なエントリ数 */
extern int make_nfa(void);       /* NFA を生成して表示する */
extern void gen_nfa(PTree *tp);  /* 構文木から NFA を生成 */
extern void print_nfa(void);     /* NFA(頂点リスト，初期頂点，終了頂点)を表示 */
extern int epsilon;

/*****  決定的オートマトンへの変換ルーチン *****/

typedef struct dvertex { /* DFA の頂点 */
  unsigned char *nvset; /* NFAの頂点集合 */
  elist *elp;  /* 辺リストポインタ */
  char check;  /* 遷移先はチェック済みか */
  char final;  /* 終了状態か */
} dvertex;

extern int initial_nv;             /* 初期頂点 */
extern int final_nv;               /* 終了頂点 */
extern int make_dfa(void);   /* 決定的有限オートマトンを生成して表示 */
extern void gen_dfa(void);   /* 決定的有限オートマトンを生成 */
extern void print_dfa();     /* 決定的有限オートマトンを表示 */

extern void free_ptree(PTree *root);
extern void free_nfa();
extern void free_dfa();


#endif /* REGMATCH_H */
