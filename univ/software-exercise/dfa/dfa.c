/*
 *
 *  dfa.c: 非決定的有限オートマトンから，
 *         決定的有限オートマトンを生成し，表示する
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "regmatch.h"

#define MAX_DVNUM 100      /* DFA の頂点数の最大 */
dvertex dvlist[MAX_DVNUM]; /* DFAの頂点リスト */
int dvnum = 0;             /* dvlist 中の有効なエントリ数 */
int make_dfa(void);        /* 決定的有限オートマトンを生成して表示 */
void gen_dfa(void);        /* 決定的有限オートマトンを生成 */
void print_dfa(void);      /* 決定的有限オートマトンを表示 */

#define NOT_FOUND -1

static int gen_dvertex(void);
static int search_dvertex(unsigned char* nvset);
static int get_dvertex(void);
static void check_dvertex(int dv1);
static void add_dedge(int dv1, int dv2, int lab);

typedef struct etable_entry {
    int label;                      /* ラベル */
    unsigned char nvset[MAX_NVNUM]; /* NFAの頂点集合 */
} etable_entry;

#define MAX_ETABLE_ENUM 100
static etable_entry etable[MAX_ETABLE_ENUM];
static int etable_enum = 0;

static void add_etable_entry(int lab, int dv);
static void print_etable(void);

static unsigned char* gen_nvset(void);
static void set_nvset(int dv, unsigned char* nvset);
static int iseq_nvset(unsigned char* nvset1, unsigned char* nvset2);
static void print_nvset(unsigned char* nvset);
static void enhance_nvset(int nv, unsigned char* nvset);

int make_dfa() {
    PTree* root;
    /*  debug = 1; */

    get_token();
    root = eval_expr(); /* 構文木を生成 */

    if (curr_token == EOREG) {
        gen_nfa(root); /* NFA へ変換 */
        gen_dfa();     /* DFA へ変換 */
        print_dfa();   /* DFA を表示 */
    } else {
        parse_error();
    }

    free_ptree(root);
    free_nfa();
    free_dfa();

    return 0;
}

/* 決定的有限オートマトンを生成 */
void gen_dfa() {
    int dv;

    dv = gen_dvertex(); /* dv == 0 */
    enhance_nvset(initial_nv, dvlist[dv].nvset);

    while ((dv = get_dvertex()) != NOT_FOUND) {
        check_dvertex(dv);
        dvlist[dv].check = 1; /* チェック済みの印をつける */
    }
}

/* 決定的有限オートマトンを表示 */
void print_dfa() {
    int i;
    elist* elp;

    printf("Number of DFA states: %1d\n", dvnum);
    printf("Initial state: %1d\n", 0);

    for (i = 0; i < dvnum; i++) {
        for (elp = dvlist[i].elp; elp != NULL; elp = elp->next) {
            if (elp->label == -1)
                printf("warning: an epsilon transition is found in DFA.\n");
            else
                printf("(%c) %1d => %1d\n", elp->label, i, elp->node);
        }
    }

    printf("Final states:");
    for (i = 0; i < dvnum; i++) {
        if (dvlist[i].nvset[final_nv] == 1)
            printf(" %1d", i);
    }
    printf("\n");
}

/* DFA 頂点を生成する */
int gen_dvertex() {
    if (dvnum >= MAX_DVNUM)
        fatal_error("too much DFA states");

    dvlist[dvnum].nvset = gen_nvset();
    dvnum++;

    if (debug)
        printf("new dvertex(%1d):", dvnum - 1);

    return dvnum - 1;
}

/* 状態集合が nvset と同じDFA頂点があるか調べ，
   あればその頂点インデックス返し，なければ NOT_FOUND を返す */
int search_dvertex(unsigned char* nvset) {
    int i;

    /* DFA のそれぞれの登録されている頂点について，頂点集合が同じか調べる */
    for (i = 0; i < dvnum; i++) {
        if (iseq_nvset(nvset, dvlist[i].nvset))
            return i;
    }

    return NOT_FOUND;
}

/* まだ，チェック済みでないDFA頂点があるか調べ，
   あればその頂点インデックス返し，なければ NOT_FOUND を返す */
int get_dvertex() {
    for (int i = 0; i < dvnum; i++) {
        if (!dvlist[i].check) {
            return i;
        }
    }

    return NOT_FOUND;
}

/* DFA 頂点をチェックする */
void check_dvertex(int dv1) {
    int i, j, dv2;
    elist* elp;

    if (debug)
        printf("We now check DFA vertex %1d.\n", dv1);

    /* 辺テーブルの作成 */
    for (i = 0; i < nvnum; i++) {
        if (dvlist[dv1].nvset[i]) { /*  dv の 頂点集合に含まれる i について */
            for (elp = nvlist[i]; elp != NULL; elp = elp->next) {
                if (elp->label != epsilon) { /*  i からの非空遷移をテーブルに登録 */
                    add_etable_entry(elp->label, elp->node);
                }
            }
        }
    }

    if (debug)
        print_etable();

    /* DFA 頂点／辺の登録 */
    for (i = 0; i < etable_enum; i++) {
        dv2 = search_dvertex(etable[i].nvset);
        if (dv2 == NOT_FOUND) {
            dv2 = gen_dvertex();
            set_nvset(dv2, etable[i].nvset);
        }
        add_dedge(dv1, dv2, etable[i].label);
    }

    /* 使用した辺テーブルの掃除 */
    for (i = 0; i < etable_enum; i++) {
        for (j = 0; j < nvnum; j++) {
            etable[i].nvset[j] = 0;
        }
        etable[i].label = 0;
    }
    etable_enum = 0;
}

/* DFA の辺を追加する */
void add_dedge(int dv1, int dv2, int lab) {
    elist* elp;

    if ((elp = (elist*)malloc(sizeof(elist))) == NULL)
        fatal_error("malloc error");

    elp->next = dvlist[dv1].elp;
    elp->node = dv2;
    elp->label = lab;
    dvlist[dv1].elp = elp;

    if (debug)
        printf("new edge: (%c)%1d => %1d\n", lab, dv1, dv2);
}

/* 辺テーブル(etable)にエントリを追加 */
void add_etable_entry(int lab, int dv) {
    int i;

    /* ラベルがすでに登録されていたら，nvset に追加して終了 */
    for (i = 0; i < etable_enum; i++) {
        if (etable[i].label == lab) {
            enhance_nvset(dv, etable[i].nvset);
            return;
        }
    }

    /* ラベルが登録されていなかったら新しいエントリを追加 */
    if (etable_enum >= MAX_ETABLE_ENUM)
        fatal_error("too much etable entries");

    etable[etable_enum].label = lab;
    enhance_nvset(dv, etable[etable_enum].nvset);

    etable_enum++;
}

/* 辺テーブル(etable)を表示 */
void print_etable() {
    int i;

    printf("Printing etable: ...\n");

    for (i = 0; i < etable_enum; i++) {
        printf("label(%c): ", etable[i].label);
        print_nvset(etable[i].nvset);
    }

    printf("... end of etable.\n");
}

/* 頂点集合 nvset を生成する */
unsigned char* gen_nvset() {
    unsigned char* nvset;

    if (debug)
        printf("new nvset\n");

    if ((nvset = (unsigned char*)
             calloc(nvnum, sizeof(unsigned char))) == NULL) {
        fatal_error("malloc error");
    }

    return nvset;
}

/* DFA 頂点 dv の NFA 頂点集合を nvset に設定する */
void set_nvset(int dv, unsigned char* nvset) {
    for (int i = 0; i < nvnum; i++) {
        dvlist[dv].nvset[i] = nvset[i];
    }
}

/* 2つの NFA 頂点集合が等しいか判定する */
int iseq_nvset(unsigned char* nvset1, unsigned char* nvset2) {
    for (int i = 0; i < nvnum; i++) {
        if (nvset1[i] != nvset2[i]) {
            return 0;
        }
    }

    return 1;
}

/* NFA 頂点集合 nvset を表示 */
void print_nvset(unsigned char* nvset) {
    int j;

    for (j = 0; j < nvnum; j++) {
        printf("%1d[%1d]", j, nvset[j]);
    }
    printf("\n");
}

/* NFA 頂点集合 nvset に NFA 状態 nv とその epsilon 閉包を追加 */
void enhance_nvset(int nv, unsigned char* nvset) {
    elist* elp;

    if (nvset[nv] == 1) /* nv がもう登録されているなら終了 */
        return;

    nvset[nv] = 1; /* nv を登録 */

    /* 状態 nv から空遷移で行ける状態を再帰的に追加 */
    for (elp = nvlist[nv]; elp != NULL; elp = elp->next) {
        if (elp->label == epsilon) {
            enhance_nvset(elp->node, nvset);
        }
    }
}

void free_dfa() {
    int i;
    elist *elp, *next;

    for (i = 0; i < dvnum; i++) {
        if (dvlist[i].nvset)
            free(dvlist[i].nvset);

        for (elp = dvlist[i].elp; elp != NULL; elp = next) {
            next = elp->next;
            free(elp);
        }
    }
}
