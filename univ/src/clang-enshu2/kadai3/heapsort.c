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
    gettimeofday(&tp, NULL);
    ret = (double)(tp.tv_sec & 0x00ffffff) + (double)tp.tv_usec / 1000000;
    return ret;
}
#endif

// 要素を交換する関数
void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// ヒープを調整する関数
void heapify(int arr[], int n, int i) {
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;

    if (left < n && arr[left] > arr[largest])
        largest = left;

    if (right < n && arr[right] > arr[largest])
        largest = right;

    if (largest != i) {
        swap(&arr[i], &arr[largest]);
        heapify(arr, n, largest);
    }
}

// ヒープソート関数
void heapSort(int arr[], int n) {
    // ヒープを構築
    for (int i = n / 2 - 1; i >= 0; i--)
        heapify(arr, n, i);

    // ヒープから要素を1つずつ取り出す
    for (int i = n - 1; i > 0; i--) {
        swap(&arr[0], &arr[i]);
        heapify(arr, i, 0);

#ifdef DEBUG
        printf("ヒープソート途中経過 (i=%d):\n", i);
        for (int j = 0; j < n; j++) {
            printf("%d\n", arr[j]);
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

#ifdef TIME
    time_start = gettime();
#endif

    heapSort(data, n);

#ifdef TIME
    time_end = gettime();
    fprintf(stderr, "ヒープソートの実行時間 = %lf[秒]\n", time_end - time_start);
#else
    fprintf(stderr, "ヒープソート終了\n");
#endif

    for (int i = 0; i < n; i++) {
        printf("%d\n", data[i]);
    }

    free(data);

    return 0;
}
