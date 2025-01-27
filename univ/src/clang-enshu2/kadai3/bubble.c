#include <malloc.h>
#include <stdbool.h>
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
}
#endif

// 教科書 p.65 バブルソートのプログラム
void bubble(int* a, int n) {
    int i, j;

    for (i = 1; i < n; i++) {
        for (j = n - 1; j >= i; j--) {
            if (a[j - 1] > a[j]) {
                int x = a[j - 1];
                a[j - 1] = a[j];
                a[j] = x;
            }
        }

#ifdef DEBUG
        //  デバッグモード時は，各ステップの処理後のデータを表示
        for (j = 0; j < n; j++) {
            printf("%d\n", a[j]);
        }
        printf("\n");
#endif
    }
}

int main(int argc, char* argv[]) {
    char* dataFile;  // ファイル名
    FILE* fp;        // ファイルポインタ
    int n;           // データ数
    int* data;       // 代入先アドレス
    int i;
    double time_start, time_end;

    if (argc <= 1) {
        fprintf(stderr, "##### ファイルを指定してください\n");
        return 1;
    }
    dataFile = argv[1];  // ファイル名の取得

    if (argc <= 2) {
        fprintf(stderr, "##### データ数を指定してください\n");
        return 1;
    }
    n = atoi(argv[2]);  // データ数の取得

    // データ格納場所の確保
    data = (int*)malloc(n * sizeof(int));
    if (data == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        return 1;
    }

    // ファイルを開く
    fp = fopen(dataFile, "r");
    if (fp == NULL) {
        fprintf(stderr, "##### ファイルを開けませんでした\n");
        return 1;
    }

    // データを読み込む
    for (i = 0; i < n; i++) {
        fscanf(fp, "%d", &data[i]);  // データを１つずつ読み込む
    }
    fclose(fp);  // ファイルを閉じる

#ifdef TIME
    // 時間計測開始
    time_start = gettime();
#endif

    // バブルソートを実行
    bubble(data, n);
#ifdef TIME
    // 時間計測終了
    time_end = gettime();
    fprintf(stderr, "バブルソートの実行時間 = %lf[秒]\n", time_end - time_start);
#else
    fprintf(stderr, "バブルソート終了\n");
#endif

    // ソート結果の表示
    for (i = 0; i < n; i++) {
        printf("%d\n", data[i]);
    }

    // データ格納場所を解放
    free(data);

    return 0;
}
