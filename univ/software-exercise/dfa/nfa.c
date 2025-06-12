/*
 *  nfa.c
 *
 *  正規表現から非決定的有限オートマトンを生成し，表示する
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "regmatch.h"

int epsilon = -1;         /* 空遷移を表わすラベル */
elist* nvlist[MAX_NVNUM]; /* NFAの頂点リスト */
int nvnum = 0;            /* vlist 中の有効なエントリ数 */
int initial_nv;           /* 初期頂点 */
int final_nv;             /* 終了頂点 */

int make_nfa(void);      /* NFA を生成して表示する */
void gen_nfa(PTree* tp); /* 構文木から NFA を生成 */
void print_nfa(void);    /* NFA(頂点リスト，初期頂点，終了頂点)を表示 */

/* NFA を表す構造体 */
typedef struct nfa {
    int start;
    int end;
} nfa;

/* NFA を生成する関数群 */
static nfa ptree_to_nfa(PTree* tp);
static nfa gen_empty_nfa(void);
static nfa gen_epsilon_nfa(void);
static nfa gen_literal_nfa(char val);
static nfa gen_conc_nfa(nfa n1, nfa n2);
static nfa gen_vert_nfa(nfa n1, nfa n2);
static nfa gen_ast_nfa(nfa n1);

static int gen_nvertex(void);                       /* 新しい頂点を生成 */
static void add_nedge(int nv1, int nv2, int label); /* 辺を追加 */

/* NFAを作成し，表示する */
int make_nfa() {
    PTree* root;

    get_token();
    root = eval_expr();

    if (curr_token == EOREG) {
        gen_nfa(root);
        print_nfa();
    } else {
        parse_error();
    }

    free_ptree(root);
    free_nfa();

    return 0;
}

/* 構文木から，NFAを作成：公開用 */
void gen_nfa(PTree* tp) {
    nfa n;

    n = ptree_to_nfa(tp);
    initial_nv = n.start;
    final_nv = n.end;
}

/* NFA(頂点リスト，初期頂点，終了頂点)を表示 */
void print_nfa() {
    int i;
    elist* elp;

    for (i = 0; i < nvnum; i++) {
        for (elp = nvlist[i]; elp != NULL; elp = elp->next) {
            if (elp->label == -1)
                printf("\\e");
            else
                printf(" %c", elp->label);
            printf(": %3d => %3d\n", i, elp->node);
        }
    }
    printf("Initial state: %3d\n", initial_nv);
    printf("Final state: %3d\n", final_nv);
}

/*********************
NFA を生成する関数群
**********************/

/* 構文木から，NFAを作成：再帰用*/
nfa ptree_to_nfa(PTree* tp) {
    nfa n, n1, n2;

    switch (tp->tok) {
        case NULLCHAR:
            /* NULLCHARの処理を行う. */
            n = gen_empty_nfa();
            break;
        case ESCAPE:
            n = gen_epsilon_nfa();
            break;
        case LETTER:
            /* LETTERの処理を行う. */
            n = gen_literal_nfa(tp->val);
            break;
        case CONC:
            n1 = ptree_to_nfa(tp->left);
            n2 = ptree_to_nfa(tp->right);
            n = gen_conc_nfa(n1, n2);
            break;
        case VERT:
            /* VERTの処理を行う.*/
            n1 = ptree_to_nfa(tp->left);
            n2 = ptree_to_nfa(tp->right);
            n = gen_vert_nfa(n1, n2);
            break;
        case AST:
            /* ASTの処理を行う．*/
            n1 = ptree_to_nfa(tp->left);
            n = gen_ast_nfa(n1);
            break;
        default:
            fatal_error("unexpected error at ptree_to_nfa");
            break;
    }

    return n;
}

nfa gen_empty_nfa() {
    nfa n;

    /*
     * (1) 新たな頂点をgen_nvertex()で作成し，この頂点を初期状態n.startとする．
     * (2) 新たな頂点をgen_nvertex()で作成し，この頂点を終了状態n.endとする．
     */

    n.start = gen_nvertex();
    n.end = gen_nvertex();

    return n;
}

nfa gen_epsilon_nfa(void) {
    nfa n;

    n.start = gen_nvertex();
    n.end = gen_nvertex();
    add_nedge(n.start, n.end, epsilon);

    return n;
}

nfa gen_literal_nfa(char val) {
    nfa n;

    /*
     * (1) 新たな頂点をgen_nvertex()で作成し，この頂点を初期状態n.startとする．
     * (2) 新たな頂点をgen_nvertex()で作成し，この頂点を終了状態n.endとする．
     * (3) 作成した初期状態から終了状態へ，辺ラベルvalの辺を加える．
     */

    n.start = gen_nvertex();
    n.end = gen_nvertex();
    add_nedge(n.start, n.end, val);

    return n;
}

nfa gen_conc_nfa(nfa n1, nfa n2) {
    nfa n;

    n.start = n1.start;
    n.end = n2.end;
    add_nedge(n1.end, n2.start, epsilon);

    return n;
}

nfa gen_vert_nfa(nfa n1, nfa n2) {
    nfa n;

    /*
     * (1) 新たな頂点をgen_nvertex()で作成し，この頂点を初期状態n.startとする．
     * (2) 新たな頂点をgen_nvertex()で作成し，この頂点を終了状態n.endとする．
     * (3) nの初期状態n.startから，n1の初期状態n1.startとn2の初期状態n2.startへ空ラベルの辺を加える.
     * (4) n1の終了状態n1.endとn2の終了状態n2.endから，nの終了状態n.endへ空ラベルの辺を加える．
     */

    n.start = gen_nvertex();
    n.end = gen_nvertex();
    add_nedge(n.start, n1.start, epsilon);
    add_nedge(n.start, n2.start, epsilon);
    add_nedge(n1.end, n.end, epsilon);
    add_nedge(n2.end, n.end, epsilon);

    return n;
}

nfa gen_ast_nfa(nfa n1) {
    nfa n;

    /*
     * (1) n1の初期状態をnの初期状態n.startとする.
     * (2) 新たな頂点をgen_nvertex()で作成し，この頂点を終了状態n.endとする．
     * (3) n1の初期状態n1.startから新たな終了状態n.endに空ラベルの辺を加える.
     * (4) n1の終了状態n1.endからn1の初期状態へ空ラベルの辺を加える.
     */

    n.start = n1.start;
    n.end = gen_nvertex();
    add_nedge(n1.end, n1.start, epsilon);
    add_nedge(n1.start, n.end, epsilon);

    return n;
}

/* NFAの頂点を生成 */
int gen_nvertex() {
    if (++nvnum > MAX_NVNUM)
        fatal_error("too much NFA states");

    return nvnum - 1;
}

/* NFAの辺を追加 */
void add_nedge(int nv1, int nv2, int label) {
    elist *elp, *elp2;

    if ((elp = (elist*)malloc(sizeof(elist))) == NULL)
        fatal_error("malloc error");

    /*
     * 辺elpに到達先頂点番号nodeと辺のラベルlabelを代入する
     */

    elp->node = nv2;
    elp->label = label;
    elp->next = NULL;

    /* ノードnv1に辺があるかどうかを調べ
     * ない：辺elpをnvlistのノードnv1にリンクする
     * ある：リンクをたどり最後(次の辺に対するポインタがNULL)の
     * 辺に辺elpをリンクする
     */

    if (nvlist[nv1] == NULL) {
        nvlist[nv1] = elp;
    } else {
        for (elp2 = nvlist[nv1]; elp2->next != NULL; elp2 = elp2->next) {
        }
        elp2->next = elp;
    }
}

void free_nfa() {
    int i;
    elist *elp, *next;

    for (i = 0; i < nvnum; i++) {
        for (elp = nvlist[i]; elp != NULL; elp = next) {
            next = elp->next;
            free(elp);
        }
    }
}
