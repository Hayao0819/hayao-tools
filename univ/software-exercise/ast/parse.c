/*
 * parse.c
 *
 *     正規表現の構文解析ルーチン
 *
 *     構文解析
 *     expr ::= term | term VERT expr
 *     term ::= factor | factor CONC term
 *     factor ::= primary | primary AST
 *     primary ::= EMPTY | EPSILON | LETTTER | LPAR expr RPAR
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "regmatch.h"

int parse(void);        /* 構文解析して正規表現を評価 */
void parse_error(void); /* 構文エラーで終了 */

PTree* eval_expr(void);    /* expr を評価 */
PTree* eval_term(void);    /* term を評価 */
PTree* eval_factor(void);  /* factor を評価 */
PTree* eval_primary(void); /* primary を評価 */

PTree* make_ptree(Token tok, char val, PTree* left, PTree* right); /* 構文木を作成 */
void print_ptree(PTree* root);                                     /* 構文木を表示 */
static void print_ptree_n(int n, PTree* root);                     /* print_ptree に使う補助関数 */

/* parse: 正規表現を構文解析して構文木を生成，表示 */
int parse(void) {
    PTree* root;

    get_token();
    root = eval_expr();

    if (curr_token == EOREG) {
        print_ptree(root);
    } else {
        parse_error();
    }

    free_ptree(root);
    return 0;
}

/* parse_error: 構文エラーで終了 */
void parse_error() {
    fatal_error("syntax error");
}

/* eval_expr: expr を評価 */
PTree* eval_expr() {
    PTree* root;

    root = eval_term();

    if (curr_token == VERT) {
        get_token();
        root = make_ptree(VERT, 0, root, eval_expr());
    }

    return root;
}

/* eval_term: term を評価 */
PTree* eval_term() {
    PTree* root;

    root = eval_factor();

    if (curr_token == CONC) {
        get_token();
        root = make_ptree(CONC, 0, root, eval_term());
    } else if (curr_token == NULLCHAR || curr_token == ESCAPE || curr_token == LETTER || curr_token == LPAR) {
        root = make_ptree(CONC, 0, root, eval_term());
    }

    return root;
}

/* eval_factor: factor を評価 */
PTree* eval_factor() {
    PTree* root;

    root = eval_primary();

    if (curr_token == AST) {
        get_token();
        root = make_ptree(AST, 0, root, NULL);
    }

    return root;
}

/* eval_primary: primary を評価 */
PTree* eval_primary() {
    PTree* root;

    if (curr_token == NULLCHAR) {
        root = make_ptree(curr_token, 0, NULL, NULL);
        get_token();
    } else if (curr_token == ESCAPE) {
        root = make_ptree(curr_token, 0, NULL, NULL);
        get_token();
    } else if (curr_token == LETTER) {
        root = make_ptree(curr_token, token_val, NULL, NULL);
        get_token();
    } else if (curr_token == LPAR) {
        get_token();
        root = eval_expr();

        if (curr_token != RPAR) {
            parse_error();
        }
        get_token();
    } else {
        parse_error();
    }

    return root;
}

/* make_ptree: 構文木を作成 */
PTree* make_ptree(Token tok, char val, PTree* left, PTree* right) {
    PTree* root;

    if ((root = (PTree*)malloc(sizeof(PTree))) == NULL) {
        fatal_error("malloc error");
    }

    root->tok = tok;
    root->val = val;
    root->left = left;
    root->right = right;

    return root;
}

/* print_ptree: 構文木を表示 */
void print_ptree(PTree* root) {
    print_ptree_n(0, root);
}

/* print_ptree_n: print_ptree に使う補助関数 */
void print_ptree_n(int n, PTree* root) {
    int i;
    if (root == NULL)
        return;

    print_ptree_n(n + 1, (PTree*)root->left);

    for (i = 0; i < n; i++)
        printf("   ");
    print_token(root->tok, root->val);

    print_ptree_n(n + 1, (PTree*)root->right);
}

void free_ptree(PTree* root) {
    if (root->left)
        free_ptree((PTree*)root->left);
    if (root->right)
        free_ptree((PTree*)root->right);
    free(root);
}
