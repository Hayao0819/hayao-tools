#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define SMALL_N 50

#define TIME

#ifdef TIME
double gettime() {
    struct timeval tp;
    double ret;
    gettimeofday(&tp, NULL);
    ret = (double)(tp.tv_sec & 0x00ffffff) + (double)tp.tv_usec / 1000000;
    return ret;
}
#endif

void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

void bubble_sort(int* arr, int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                swap(&arr[j], &arr[j + 1]);
            }
        }
    }
}

int median_of_five(int* arr) {
    bubble_sort(arr, 5);
    return arr[2];
}

int l_select(int* A, int n, int k) {
    if (n < SMALL_N) {
        bubble_sort(A, n);
        return A[k - 1];
    }

    int num_groups = (n + 4) / 5;
    int* M = (int*)malloc(num_groups * sizeof(int));
    if (M == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        exit(1);
    }

    for (int i = 0; i < num_groups; i++) {
        int group_size = (i == num_groups - 1) ? n - i * 5 : 5;
        if (group_size == 5) {
            M[i] = median_of_five(A + i * 5);
        } else {
            bubble_sort(A + i * 5, group_size);
            M[i] = A[i * 5 + group_size / 2];
        }
    }

    int m = l_select(M, num_groups, (num_groups + 1) / 2);
    free(M);

    int* S1 = (int*)malloc(n * sizeof(int));
    if (S1 == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        exit(1);
    }
    int* S2 = (int*)malloc(n * sizeof(int));
    if (S2 == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        exit(1);
    }
    int* S3 = (int*)malloc(n * sizeof(int));
    if (S3 == NULL) {
        fprintf(stderr, "##### メモリ確保に失敗しました\n");
        exit(1);
    }
    int s1_count = 0, s2_count = 0, s3_count = 0;

    for (int i = 0; i < n; i++) {
        if (A[i] < m) {
            S1[s1_count++] = A[i];
        } else if (A[i] == m) {
            S2[s2_count++] = A[i];
        } else {
            S3[s3_count++] = A[i];
        }
    }

    int result;
    if (k <= s1_count) {
        result = l_select(S1, s1_count, k);
    } else if (k <= s1_count + s2_count) {
        result = m;
    } else {
        result = l_select(S3, s3_count, k - s1_count - s2_count);
    }

    free(S1);
    free(S2);
    free(S3);

    return result;
}

int main(int argc, char* argv[]) {
    char* datafile;
    FILE* fp;
    int n;
    int* data;
    int k;
    int i;
    double time_start, time_end;
    int answer;

    if (argc <= 1) {
        fprintf(stderr, "#### ファイルを指定してください");
        return 1;
    }
    datafile = argv[1];

    if (argc <= 2) {
        fprintf(stderr, "#### データ数を指定してください");
        return 1;
    }
    n = atoi(argv[2]);

    if (argc <= 3) {
        fprintf(stderr, "#### 何番目のデータを選ぶのか指定してください");
        return 1;
    }
    k = atoi(argv[3]);

    data = (int*)malloc(n * sizeof(int));
    if (data == NULL) {
        fprintf(stderr, "#### メモリ確保に失敗しました\n");
        return 1;
    }
    fp = fopen(datafile, "r");
    if (fp == NULL) {
        fprintf(stderr, "#### ファイルを開けませんでした\n");
        free(data);
        return 1;
    }
    for (i = 0; i < n; i++) {
        if (fscanf(fp, "%d", &data[i]) != 1) {
            fprintf(stderr, "#### データの読み込みに失敗しました。行数: %d\n", i + 1);
            fclose(fp);
            free(data);
            return 1;
        }
    }
    fclose(fp);

    time_start = gettime();
    answer = l_select(data, n, k);
    time_end = gettime();
    printf("答え = %d\n", answer);
    fprintf(stderr, "k番目選択の実行時間 = %lf[秒]\n", time_end - time_start);

    free(data);

    return 0;
}
