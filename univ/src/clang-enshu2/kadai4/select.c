#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define SMALL_N 50  // テキストp.82下から3行目の「小さい整数」．ここでは50と定義．

int debug = 0;  // debug モード時は1にする

// 関数 double gettime(): 前回配布した資料と同じ
double gettime() {
    struct timeval tp;
    double ret;
    gettimeofday(&tp, NULL);
    ret = (double)(tp.tv_sec & 0x00ffffff) + (double)tp.tv_usec / 1000000;
    return ret;
}

int gamm[SMALL_N];

// 関数 merge() と関数 m_sort(): 前回配布した資料と同じ
// 教科書 p.70 alpha[0, 1, ..., n−1], beta[0, 1, ..., m−1] をマージ
int* merge(int* alpha, int n, int* beta, int m) {
    int gamm_used = 0;
    int i, j;

    if (debug) {  // debugモード時は，ソート前のデータを表示
        printf("α[] = \n");
        for (i = 0; i < n; i++)
            printf("%d\n", alpha[i]);
        printf("\n");
        printf("β[] = \n");
        for (j = 0; j < m; j++)
            printf("%d\n", beta[j]);
        printf("\n");
    }

    i = 0;
    j = 0;
    while (i < n && j < m) {
        if (alpha[i] <= beta[j])
            gamm[gamm_used++] = alpha[i++];
        else
            gamm[gamm_used++] = beta[j++];
    }
    if (i < n && j >= m) {
        while (i < n)
            gamm[gamm_used++] = alpha[i++];
    }
    if (i >= n && j < m) {
        while (j < m)
            gamm[gamm_used++] = beta[j++];
    }
    // 教科書ではγそのものを return しているが，γは一時的な格納場所なのでαやβに書き戻す
    for (i = 0; i < n; i++)
        alpha[i] = gamm[i];
    for (j = 0; j < m; j++)
        beta[j] = gamm[n + j];

    if (debug) {  // debugモード時は，ソート後のデータを表示
        printf("γ[] = \n");
        for (i = 0; i < n + m; i++)
            printf("%d\n", gamm[i]);
        printf("\n");
    }

    return alpha;
}

// 教科書 p.70 a[i], a[i+1], ... a[j] をソートする
int* m_sort(int* a, int i, int j) {
    int k;
    if (i == j)
        return &a[i];
    k = (i + j - 1) / 2;
    return merge(m_sort(a, i, k), k - i + 1, m_sort(a, k + 1, j), j - (k + 1) + 1);
}

// テキストp.82～83 k番目に大きい要素を返す
int selectk(int* a, int n, int k) {
    int i, p, used;
    int u, v;
    int *U, *V;
    int answer;

    if (n < SMALL_N) {  // nが小さい整数だった時の処理
        m_sort(a, 0, n - 1);
        return a[k - 1];
    }

    p = a[random() % n];
    u = 0;
    v = 0;
    for (i = 0; i < n; i++) {
        if (a[i] < p)
            u++;
        if (a[i] <= p)
            v++;
    }
    if (k <= u) {
        U = (int*)malloc(u * sizeof(int));
        used = 0;
        for (i = 0; i < n; i++) {
            if (a[i] < p)
                U[used++] = a[i];
        }
        answer = selectk(U, u, k);
        free(U);
        return answer;
    }
    if (k <= v)
        return p;
    V = (int*)malloc((n - v) * sizeof(int));
    used = 0;
    for (i = 0; i < n; i++) {
        if (a[i] > p)
            V[used++] = a[i];
    }
    answer = selectk(V, n - v, k - v);
    free(V);
    return answer;
}

int main(int argc, char* argv[]) {
    char* datafile;  // 入力データのファイル名
    FILE* fp;        // 入力データのファイルポインタ
    int n;           // 入力データのデータ数
    int* data;       // 入力データの格納場所
    int k;           // 入力データの中から何番目に小さい数を選ぶのか
    int i;
    double time_start, time_end;
    int answer;

    if (argc <= 1) {
        fprintf(stderr, "#### ファイルを指定してください");
        return 1;
    }
    datafile = argv[1];  // ファイル名の取得

    if (argc <= 2) {
        fprintf(stderr, "#### データ数を指定してください");
        return 1;
    }
    n = atoi(argv[2]);  // データ数の取得

    if (argc <= 3) {
        fprintf(stderr, "何番目のデータを選ぶのか指定してください");
        return 1;
    }
    k = atoi(argv[3]);

    data = (int*)malloc(n * sizeof(int));  // データ格納場所の確保
    fp = fopen(datafile, "r");             // データファイルを開く
    for (i = 0; i < n; i++) {
        if (fscanf(fp, "%d", &data[i]) != 1)  // データを１つずつ読み込む。読み込みに失敗したときにはエラーメッセージを出力
        {
            fprintf(stderr, "データの読み込みに失敗しました。行数: %d\n", i + 1);
            fclose(fp);
            free(data);
            return 1;
        }
    }
    fclose(fp);

    time_start = gettime();        // 時間計測開始
    answer = selectk(data, n, k);  // k番目選択を実行
    time_end = gettime();          // 時間計測終了
    printf("答え = %d\n", answer);
    fprintf(stderr, "k番目選択の実行時間 = %lf[秒]\n", time_end - time_start);

    free(data);  // データ格納場所を解放

    return 0;
}
