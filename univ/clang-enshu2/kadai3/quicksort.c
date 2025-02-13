#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

// #define DEBUG
#define TIME

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

// 配列の要素を交換する関数
void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// パーティション関数（ランダムピボット）
int partition(int arr[], int low, int high) {
    // ランダムなピボットを選択
    int random = low + rand() % (high - low + 1);
    swap(&arr[random], &arr[high]);

    int pivot = arr[high];
    int i = (low - 1);

    for (int j = low; j <= high - 1; j++) {
        if (arr[j] < pivot) {
            i++;
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[i + 1], &arr[high]);
    return (i + 1);
}

// クイックソート関数
void quickSort(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);

        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);

#ifdef DEBUG
        printf("部分ソート後 (low=%d, high=%d):\n", low, high);
        for (int i = low; i <= high; i++) {
            printf("%d\n", arr[i]);
        }
        printf("\n");
#endif
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
        fscanf(fp, "%d", &data[i]);
    }
    fclose(fp);

    srand(time(NULL));  // 乱数シードの初期化

#ifdef TIME
    time_start = gettime();
#endif

    quickSort(data, 0, n - 1);

#ifdef TIME
    time_end = gettime();
    fprintf(stderr, "クイックソートの実行時間 = %lf[秒]\n", time_end - time_start);
#else
    fprintf(stderr, "クイックソート終了\n");
#endif

    for (int i = 0; i < n; i++) {
        printf("%d\n", data[i]);
    }

    free(data);
    return 0;
}
