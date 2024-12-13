#include <stdio.h>
#include <stdlib.h>

// 教科書 p.21～22 に対応
#define N 10  // テキストでは小文字の n だが，C 言語では通常マクロは大文字で定義

// 隣接行列用のデータ構造の定義
#define boolean int  // C 言語には boolean 型がないので，ここで (無理矢理) 宣言
#define true 1       // C 言語で真偽値を扱う場合，0 が偽，非 0 が真となるが，
#define false 0      // テキストに合わせて true, false を定義しておく
typedef boolean
    Adjmatrix[N][N];  // テキストでは変数定義になっているが，ここでは型として宣言

// 隣接リスト用のデータ構造の定義
typedef int Vindex;

typedef struct Edgecell {   // 有向辺のデータ構造
    Vindex destination;     // 有向辺の終点 destination
    struct Edgecell* next;  // 始点を同じくする，他の有向辺へのポインタ
} Edgecell;

typedef Edgecell* Vertices[N];

// テキストを参考にしたのはここまで

typedef struct {     // グラフのデータ構造
    int vertex_num;  // 頂点数
    int edge_num;    // 辺の数
    Vertices vtop;   // 頂点のデータ構造
} Graph;

void dfs(Graph* g, Vindex v, int reachable[]);

// 隣接行列をファイル datafile から読み込む
int read_adjacency_matrix(char* datafile, Adjmatrix mat) {
    FILE* fp;  // 入力データのファイルポインタ
    int vertex_num;
    Vindex src, dest;
    fp = fopen(datafile, "r");        // ファイルを開く
    fscanf(fp, "%d\n", &vertex_num);  // 頂点数 の読み込み
    if (vertex_num > N) {
        fprintf(
            stderr,
            "##### このプログラムが扱えるのは頂点数が%d までのグラフです\n", N);
        exit(1);
    }
    for (src = 0; src < vertex_num; src++) {
        for (dest = 0; dest < vertex_num; dest++) {
            fscanf(
                fp, "%d\n", &mat[src][dest]);  // 隣接行列の要素を１つずつ読み込む
        }
    }
    fclose(fp);  // ファイルを閉
    return vertex_num;
}

// 辺の追加 辺は頂点番号 src から dest へ向う
void add_edge(Graph* g, Vindex src, Vindex dest) {
    Edgecell* edge = (Edgecell*)malloc(sizeof(Edgecell));
    edge->destination = dest;
    edge->next = g->vtop[src];
    g->vtop[src] = edge;
}

// 隣接行列からグラフを作成 (テキスト指定のデータ構造)
void translate_into_graph(Adjmatrix mat, Graph* g, Graph* rg) {
    int edge_num = 0;
    for (Vindex src = 0; src < g->vertex_num; src++) {
        for (Vindex dest = 0; dest < g->vertex_num; dest++) {
            if (mat[src][dest] == 1) {
                add_edge(g, src, dest);
                add_edge(rg, dest, src);
                edge_num++;
            }
        }
    }
    g->edge_num = edge_num;
}

void print_graph(Graph* g) {
    Vindex v;
    printf("digraph G {\n");
    printf(
        "  size=\"11.5,8\"; node[fontsize=10,height=0.01,width=0.01]; edge["
        "len=3.0];\n");
    for (v = 0; v < g->vertex_num; v++) {
        Edgecell* edge;
        for (edge = g->vtop[v]; edge != NULL; edge = edge->next) {
            printf("  %d -> %d;\n", v + 1, edge->destination + 1);
        }
    }
    printf("}\n");
}

// グラフ g の使用しているメモリを解放
void free_graph(Graph* g) {
    Vindex v;
    for (v = 0; v < g->vertex_num; v++) {
        Edgecell *edge, *next_edge;
        for (edge = g->vtop[v]; edge != NULL; edge = next_edge) {
            next_edge = edge->next;
            free(edge);
        }
    }
}

int is_strongly_connected(Graph* g, Graph* rg) {
    int reachable[N];
    for (Vindex v = 0; v < g->vertex_num; v++) {
        reachable[v] = 0;
    }
    dfs(g, 0, reachable);

    int reverse_reachable[N];
    for (Vindex v = 0; v < g->vertex_num; v++) {
        reverse_reachable[v] = 0;
    }
    dfs(rg, 0, reverse_reachable);

    for (Vindex v = 0; v < g->vertex_num; v++) {
        if (reachable[v] == 0 || reverse_reachable[v] == 0) {
            return 0;
        }
    }

    return 1;
}

void dfs(Graph* g, Vindex v, int reachable[]) {
    Edgecell* edge;
    reachable[v] = 1;
    for (edge = g->vtop[v]; edge != NULL; edge = edge->next) {
        if (reachable[edge->destination] == 0) {
            dfs(g, edge->destination, reachable);
        }
    }
}

int main(int argc, char* argv[]) {
    char* datafile;  // 入力データのファイル名
    Adjmatrix a;     // テキストでは大文字 A で定義
    Graph g, rg;


    

    if (argc <= 1) {
        fprintf(stderr, "##### ファイル名を指定してください\n");
        return 1;
    }
    datafile = argv[1];  // ファイル名の取得
    g.vertex_num = read_adjacency_matrix(datafile, a);
    translate_into_graph(a, &g, &rg);
    // print_graph(&g);
    int result = is_strongly_connected(&g, &rg);
    if (result) {
        printf("強連結です\n");
    } else {
        printf("強連結ではありません\n");
    }
    free_graph(&g);  // グラフのデータ格納場所を解放
    free_graph(&rg);
    return 0;
}
