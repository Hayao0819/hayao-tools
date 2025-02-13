#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

// #define DEBUG
#define TIME

#ifdef TIME
// gettime() : 1970/1/1 0:00 からの経過時刻を double 型で返す関数
double gettime() {
    struct timeval tp;
    double ret;
    gettimeofday(&tp, NULL);  // 1970/1/1 0:00 からの経過時刻を取得
    ret = (double)(tp.tv_sec & 0x00ffffff) + (double)tp.tv_usec / 1000000;
    return ret;
}
#endif

int* gamm;  // γ: 一時的なデータ置き場(教科書 p.71 13 行目「余分の記憶容量」のこと)

// 教科書 p.70 alpha[0, 1, ..., n−1], beta[0, 1, ..., m−1] をマージ
int* merge(int* alpha, int n, int* beta, int m) {
    int gamm_used = 0;
    int i, j;

#ifdef DEBUG
    printf("α[] = \n");
    for (i = 0; i < n; i++)
        printf("%d\n", alpha[i]);
    printf("\n");
    printf("β[] = \n");
    for (j = 0; j < m; j++)
        printf("%d\n", beta[j]);
    printf("\n");
#endif

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

#ifdef DEBUG
    // debugモード時は，ソート後のデータを表示
    printf("γ[] = \n");
    for (i = 0; i < n + m; i++)
        printf("%d\n", gamm[i]);
    printf("\n");
#endif

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

int main(int argc, char* argv[]) {
    char* datafile;  // 入力データのファイル名
    FILE* fp;        // 入力データのファイルポインタ
    int n;           // 入力データのデータ数
    int* data;       // 入力データ格納場所
    int i;
    double time_start, time_end;

    // ファイル名の取得
    if (argc <= 1) {
        fprintf(stderr, "##### ファイルを指定してください\n");
        return 1;
    }
    datafile = argv[1];

    // データ数の取得
    if (argc <= 2) {
        fprintf(stderr, "##### データ数を指定してください\n");
        return 1;
    }
    n = atoi(argv[2]);

    // データ格納場所の確保
    data = (int*)malloc(n * sizeof(int));
    if (data == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        return 1;
    }

    // 一時的なデータ置き場の確保
    gamm = (int*)malloc(n * sizeof(int));
    if (gamm == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        return 1;
    }

    // ファイルを開く
    fp = fopen(datafile, "r");
    if (fp == NULL) {
        fprintf(stderr, "##### ファイルを開けませんでした\n");
        return 1;
    }

    // データを１つずつ読み込む
    for (i = 0; i < n; i++) {
        fscanf(fp, "%d", &data[i]);
    }
    fclose(fp);  // ファイルを閉じる

#ifdef TIME
    time_start = gettime();  // 時間計測開始
#endif

    // マージソートを実行
    m_sort(data, 0, n - 1);

#ifdef TIME
    time_end = gettime();  // 時間計測終了
    fprintf(stderr, "マージソートの実行時間 = %lf[秒]\n", time_end - time_start);
#else
    fprintf(stderr, "マージソート終了\n");
#endif

    // ソート結果の表示
    for (i = 0; i < n; i++) {
        printf("%d\n", data[i]);
    }

    free(data);  // データ格納場所を解放
    free(gamm);  // 一時的なデータ置き場を解放
    return 0;
}
