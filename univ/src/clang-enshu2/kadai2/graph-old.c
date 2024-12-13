#include <stdarg.h>
#include <stdbool.h> // 有効化するとセグフォが起こる
#include <stdio.h>
#include <stdlib.h>

// #ifndef __STDBOOL_H  // stdbool.h が存在しない場合
// #define bool int
// #define true 1
// #define false 0
// #endif

#define N 100                  // 頂点数の最大値
typedef bool AdjMatrix[N][N];  // 隣接行列用のデータ構造の定義

#define DIGRAPH_HEADER "digraph G {\n  size=\"11.5,8\"\n  node[fontsize=10,height=0.01,width=0.01]\n  edge[len=3.0];\n"
#define DIGRAPH_FOOTER "}\n"

typedef int Vindex;  // 隣接リスト用のデータ構造の定義

typedef struct EdgeCell {   // 有向辺のデータ構造
    Vindex destination;     // 有向辺の終点 destination
    struct EdgeCell* next;  // 始点を同じくする，他の有向辺へのポインタ
} EdgeCell;

typedef EdgeCell* Vertices[N];

typedef struct {     // グラフのデータ構造
    int vertex_num;  // 頂点数
    int edge_num;    // 辺の数
    Vertices vtop;   // 頂点のデータ構造
} Graph;

// Declares
int read_adjacency_matrix(char* datafile, AdjMatrix mat);
void add_edge(Graph* g, Vindex src, Vindex dest);
void translate_into_graph(AdjMatrix mat, Graph* g, Graph* rg);
void print_graph(Graph* g);
bool is_strongly_connected(Graph* g, Graph* rg);
void free_graph(Graph* g);
void check_nullptr(void* p, const char* format, ...);

void check_nullptr(void* p, const char* format, ...) {
    if (p != NULL) return;

    // 可変引数の処理の準備
    va_list args;
    va_start(args, format);
    // エラーメッセージを表示
    vfprintf(stderr, format, args);
    putchar('\n');
    va_end(args);
    // プログラムを終了
    exit(EXIT_FAILURE);
}

// ファイルパスを指定して隣接行列を読み込む
int read_adjacency_matrix(char* filepath, AdjMatrix mat) {
    FILE* fp;
    int vertex_num;
    Vindex src, dest;

    // ファイルを開く
    fp = fopen(filepath, "r");
    check_nullptr(fp, "#### ファイル %s の読み込みに失敗しました", filepath);

    // 頂点数 の読み込み
    fscanf(fp, "%d\n", &vertex_num);
    if (vertex_num > N) {
        fprintf(stderr, "##### このプログラムが扱えるのは頂点数が %d までのグラフです", N);
        exit(1);
    }

    // 隣接行列の要素を１つずつ読み込む
    for (src = 0; src < vertex_num; src++) {
        for (dest = 0; dest < vertex_num; dest++) {
            int i;
            fscanf(fp, "%d\n", &i);
            mat[src][dest] = i == 0 ? false : true;
        }
    }

    // ファイルを閉じる
    fclose(fp);

    return vertex_num;
}

// src から dest への有向辺を追加
void add_edge(Graph* g, Vindex src, Vindex dest) {
    EdgeCell* edge = (EdgeCell*)malloc(sizeof(EdgeCell));
    check_nullptr(edge, "メモリ確保に失敗しました");
    edge->destination = dest;
    edge->next = g->vtop[src];
    g->vtop[src] = edge;
    g->edge_num++;
}

// 隣接行列からグラフを作成 (テキスト指定のデータ構造)
// 隣接行列の要素が 1 なら有向辺があるということ → 有向辺を追加 (関数 add edge を使う)
void translate_into_graph(AdjMatrix mat, Graph* g, Graph* rg) {
    for (Vindex src = 0; src < g->vertex_num; src++) {
        for (Vindex dest = 0; dest < g->vertex_num; dest++) {
            if (mat[src][dest]) {
                // printf("(%d,%d) is true\n", src, dest);
                add_edge(g, src, dest);
                if (rg != NULL) add_edge(rg, dest, src);
            }
        }
    }
}

void print_graph(Graph* g) {
    Vindex v;
    printf(DIGRAPH_HEADER);
    for (v = 0; v < g->vertex_num; v++) {
        EdgeCell* edge;
        for (edge = g->vtop[v]; edge != NULL; edge = edge->next) {
            printf("  %d -> %d;\n", v + 1, edge->destination + 1);
        }
    }
    printf(DIGRAPH_FOOTER);
}

void dfs(Graph* g, Vindex v, int reachable[]) {
    EdgeCell* edge;
    reachable[v] = 1;
    for (edge = g->vtop[v]; edge != NULL; edge = edge->next) {
        // 既に到達している頂点はスキップ
        if (reachable[edge->destination]) continue;
        dfs(g, edge->destination, reachable);
    }
}

bool is_strongly_connected(Graph* g, Graph* rg) {
    // 正の方向について接続を確認
    int reachable[N];
    for (Vindex v = 0; v < g->vertex_num; v++) {
        reachable[v] = 0;
    }
    dfs(g, 0, reachable);

    // 逆方向について接続を確認
    int reverse_reachable[N];
    for (Vindex v = 0; v < g->vertex_num; v++) {
        reverse_reachable[v] = 0;
    }
    dfs(rg, 0, reverse_reachable);

    // すべての頂点が到達可能かどうかを確認
    for (Vindex v = 0; v < g->vertex_num; v++) {
        if (reachable[v] == 0 || reverse_reachable[v] == 0) {
            return false;
        }
    }

    return true;
}

// グラフの使用しているメモリを解放
void free_graph(Graph* g) {
    Vindex v;
    for (v = 0; v < g->vertex_num; v++) {
        EdgeCell *edge, *next_edge;
        for (edge = g->vtop[v]; edge != NULL; edge = next_edge) {
            next_edge = edge->next;
            if (edge != NULL) free(edge);
        }
    }
}

bool check_args(int argc, char* argv[]) {
    if (argc > 1) return true;
    fprintf(stderr, "##### ファイル名を指定してください\n");
    return false;
}

int main(int argc, char* argv[]) {
    AdjMatrix a;
    Graph g, rg;

    if (!check_args(argc, argv)) return EXIT_FAILURE;
    g.vertex_num = read_adjacency_matrix(argv[1], a);

    translate_into_graph(a, &g, &rg);
    // print_graph(&g);

    int result = is_strongly_connected(&g, &rg);
    printf(result ? "強連結です\n" : "強連結ではありません\n");

    // グラフのメモリを開放
    free_graph(&g);
    free_graph(&rg);
    return EXIT_SUCCESS;
}
