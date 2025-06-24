/*
 * main.c
 *
 *   オプション
 *
 *  -d1 : トークン列(字句解析)
 *  -d2 : 構文木(構文解析)
 *  -d3 : NFA (非決定性有限オートマトン)
 *  -d4 : DFA (決定性有限オートマトン)
 *  -s  : 行の先頭からマッチしたもののみ表示
 *  -v  : マッチした部分を強調表示
 *
 */

#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>
#include <ctype.h>

#include "regmatch.h"

bool debug = false;
char* reg_string;

static void do_grep(FILE* fp);
static void usage_exit(void);
static void show_region(char* p, char* from, char* to);
static char* match_line(char* str, char** cpp);
static char* match_string(char* str);

static bool vflag = false; /* マッチした部分を強調表示 */
static bool sflag = false; /* 行の先頭からのマッチだけを調べる */
static bool dflag = false; /* 正規表現の解析結果を表示 */
static char* progname;

int main(int argc, char* argv[]) {
    FILE* fp;
    char c, doption = '0';
    PTree* root;

    /* プログラム名の設定 (Usage 表示用) */
    if ((progname = strrchr(*argv, '/')) == NULL) {
        progname = *argv;
    } else {
        progname++;
    }

    /* オプションの解析 */
    while (--argc > 0 && (*++argv)[0] == '-') {
        while ((c = *++argv[0])) {
            switch (c) {
                case 'v':
                    vflag = 1;
                    break;
                case 's':
                    sflag = 1;
                    break;
                case 'd':
                    dflag = 1;
                    /* d の後は数字でないといけない */
                    if (!(isdigit(doption = *++argv[0]))) {
                        fatal_error("-dオプションの後には数字を指定すること");
                        usage_exit();
                    }
                    break;
                default:
                    fatal_error("オプションの指定に不備あり");
                    usage_exit();
                    break;
            }
        }
    }

    /* 次の引数を reg_string に設定 */
    if (argc-- < 1) {
        fatal_error("正規表現を指定すること");
        usage_exit();
    }

    reg_string = *argv++;

    if (dflag) {
        if (sflag || vflag) {
            /* dflag は -s や -v と一緒に指定できない．*/
            fatal_error("-dオプションと，-s,-vオプションを同時に指定することはできません");
            usage_exit();
        }
        switch (doption) {
            case '1':
                lexer();
                break;
            case '2':
                parse();
                break;
            case '3':
                make_nfa();
                break;
            case '4':
                make_dfa();
                break;
            default: /* d の後が他の数字のとき */
                fatal_error("-dオプションの後には 1〜4 までの数字を指定すること");
                usage_exit();
                break;
        }
        exit(0); /* d オプションの時は grep せずに終了 */
    }

    /* DFA の生成 */
    get_token();
    root = eval_expr();      /* 構文木を生成 */
    if (curr_token != EOREG) /* 構文エラーをチェック */
        parse_error();
    gen_nfa(root); /* NFA へ変換 */
    gen_dfa();     /* DFA へ変換 */

    /* grep の実行 */
    if (argc < 1) {
        /* 引数がなければ標準入力から */
        do_grep(stdin);
    } else {
        /* 引数が残っていれば，それらはファイル名 */
        /*
         * 課題6.1
         *
         *   2つ以上のファイルが指定されている場合には，
         *   "==> ファイル名 <==" という行を表示してから，
         *   grep の結果を表示すること
         */

        int is_mult_file = 0;

        if (argc > 1) {
            is_mult_file = 1;
        }

        while (argc-- > 0) {
            if ((fp = fopen(*argv++, "r")) == NULL) {
                fatal_error("ファイルを開けません");
                exit(1);
            }
            if (is_mult_file) {
                printf("==> %s <==\n", *(argv - 1));
            }
            do_grep(fp);
            fclose(fp);
        }
    }

    return 0;
}

/* 使用法を表示して終了する */
void usage_exit() {
    printf("Usage: %s [-sv] expr [file1 file2 ...]\n", progname);
    printf("       %s -d(1|2|3|4) expr\n", progname);
    printf("  -s          行の先頭からマッチしたもののみ表示．\n");
    printf("  -v          マッチした部分を強調表示．\n");
    printf("  -d(1|2|3|4) 字句解析結果(1)，構文解析結果(2)，NFA(3)，DFA(4)を表示．\n");
    exit(0);
}

/* fatal_error: エラーメッセージを表示 */
void fatal_error(char* s) {
    fprintf(stderr, "%s\n", s);
}

/* ファイル fp を grep する */
void do_grep(FILE* fp) {
    char buf[BUFSIZE];
    char *from, *to;

    /* それぞれの行がマッチすれば表示する */
    while (fgets(buf, sizeof(buf), fp) != NULL) {
        /* '\0' が付かなければ付加．警告を出してそれより後ろは無視 */
        if (strchr(buf, '\0') == NULL) {
            fprintf(stderr, "warning: line too long\n");
            buf[sizeof(buf) - 1] = '\0';
        }

        if ((from = match_line(buf, &to)) != NULL) {
            fputs(buf, stdout);
            if (vflag)
                show_region(buf, from, to);
        }
    }
}

/* 行 line に正規表現にマッチする文字列があるか */
char* match_line(char* line, char** end) {
    char* p;

    if (sflag) {
        /* 行頭からの文字列が正規表現にマッチするか */
        if ((*end = match_string(line)) != NULL) {
            return line;
        }
    } else {
        /* 正規表現にマッチする文字列が行にあるか */
        for (p = line; *p != '\0'; p++) {
            if ((*end = match_string(p)) != NULL) {
                return p;
            }
        }
    }
    return NULL;
}

/* str から始まる文字列が正規表現にマッチするか */
char* match_string(char* str) {
    /*
     * 課題6.2
     */
    int dv = 0;
    elist* elp;

    /* 以下を，受理頂点に達するか，文字列か終了するか，遷移先がなくなるまで繰り返す */
    /* DFA の頂点 0 (== dv) からスタートして，
       str によって示される文字列を，先頭から眺めていって，
       ラベルが一致するような遷移先が見つかったら，次の頂点に移る
       という操作の繰り返し */

    /* ループを出てきたとき受理頂点にいればマッチ */

    for (;;) {
        for (elp = dvlist[dv].elp;; elp = elp->next) {
            if (elp == NULL) {
                return NULL;
            }
            if (*str == elp->label) {
                dv = elp->node;
                if (dvlist[dv].nvset[final_nv] == 1) {
                    return ++str;
                }
                break;
            }
        }
        str++;
        if (str == NULL) {
            return NULL;
        }
    }
}

/* 行 p の from から to の前までに ^ を表示 */
void show_region(char* p, char* from, char* to) {
    for (; p != from; p++)
        printf(" ");
    for (; p != to; p++)
        printf("^");
    printf("\n");
}
