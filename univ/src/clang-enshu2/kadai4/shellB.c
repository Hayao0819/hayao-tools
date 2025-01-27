#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define TIME
// #define DEBUG

#ifdef TIME
// gettime() : 1970/1/1 0:00 からの経過時刻を double 型で返す関数
double gettime() {
    struct timeval tp;
    double ret;
    gettimeofday(&tp, NULL);
    ret = (double)(tp.tv_sec & 0x00ffffff) + (double)tp.tv_usec / 1000000;
    return ret;
}
#endif

// Knuth版シェルソート関数
void shellB(int arr[], int n) {
    int k = 1;
    while (k < n)
        k = 3 * k + 1;
    k = k / 3;

    while (k > 0) {
        for (int i = k; i < n; i++) {
            int x = arr[i];
            int j = i - k;
            while (j >= 0 && x < arr[j]) {
                arr[j + k] = arr[j];
                j = j - k;
            }
            arr[j + k] = x;
        }

#ifdef DEBUG
        printf("部分ソート後 (k=%d):\n", k);
        for (int i = 0; i < n; i++) {
            printf("%d\n", arr[i]);
        }
        printf("\n");
#endif

        k = k / 3;
    }
}

int main(int argc, char* argv[]) {
    char* datafile;
    FILE* fp;
    int n;
    int* data;
    double time_start, time_end;

    if (argc <= 1) {
        fprintf(stderr, "##### ファイルを指定してください\n");
        return 1;
    }
    datafile = argv[1];

    if (argc <= 2) {
        fprintf(stderr, "##### データ数を指定してください\n");
        return 1;
    }
    n = atoi(argv[2]);

    data = (int*)malloc(n * sizeof(int));
    if (data == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        return 1;
    }

    fp = fopen(datafile, "r");
    if (fp == NULL) {
        fprintf(stderr, "##### ファイルを開けませんでした\n");
        return 1;
    }

    for (int i = 0; i < n; i++) {
        if (fscanf(fp, "%d", &data[i]) != 1) {
            fprintf(stderr, "データの読み込みに失敗しました。行数: %d\n", i + 1);
            fclose(fp);
            free(data);
            return 1;
        }
    }
    fclose(fp);

#ifdef TIME
    time_start = gettime();
#endif

    shellB(data, n);

#ifdef TIME
    time_end = gettime();
    fprintf(stderr, "シェルソートの実行時間 = %lf[秒]\n", time_end - time_start);
#endif

#ifdef DEBUG
    for (int i = 0; i < n; i++) {
        printf("%d\n", data[i]);
    }
#endif

    free(data);

    return 0;
}
