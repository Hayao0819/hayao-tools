#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

// #define MAX_VALUE 10000 // 想定する最大値
int max_value;

// #define DEBUG
#define TIME

// キューの要素を表す構造体
typedef struct QueueNode {
    int data;
    struct QueueNode* next;
} QueueNode;

// キューを表す構造体
typedef struct {
    QueueNode* front;
    QueueNode* rear;
} Queue;

// キューの初期化
void initQueue(Queue* q) {
    q->front = q->rear = NULL;
}

// キューに要素を追加
void enqueue(Queue* q, int value) {
    QueueNode* newNode = (QueueNode*)malloc(sizeof(QueueNode));
    newNode->data = value;
    newNode->next = NULL;

    if (q->rear == NULL) {
        q->front = q->rear = newNode;
    } else {
        q->rear->next = newNode;
        q->rear = newNode;
    }
}

// キューから要素を取り出す
int dequeue(Queue* q) {
    if (q->front == NULL)
        return -1;  // キューが空の場合

    QueueNode* temp = q->front;
    int value = temp->data;
    q->front = q->front->next;

    if (q->front == NULL) {
        q->rear = NULL;
    }

    free(temp);
    return value;
}

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

// バケットソート
void bucketSort(int* a, int n) {
    Queue* buckets = (Queue*)malloc((max_value + 1) * sizeof(Queue));
    if (buckets == NULL) {
        fprintf(stderr, "メモリ確保に失敗しました\n");
        exit(1);
    }

    for (int i = 0; i <= max_value; i++) {
        initQueue(&buckets[i]);
    }

    // 各要素をバケットに振り分ける
    for (int i = 0; i < n; i++) {
        enqueue(&buckets[a[i]], a[i]);
    }

    // バケットから順に取り出す
    int index = 0;
    for (int i = 0; i <= max_value; i++) {
        while (buckets[i].front != NULL) {
            a[index++] = dequeue(&buckets[i]);
        }

#ifdef DEBUG
        if (index > 0) {
            printf("バケット %d の処理後:\n", i);
            for (int j = 0; j < index; j++) {
                printf("%d\n", a[j]);
            }
            printf("\n");
        }
#endif
    }
    free(buckets);
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

    if (argc <= 3) {
        fprintf(stderr, "#### データの最大値を指定してください");
        return 1;
    }
    max_value = atoi(argv[3]);

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

    bucketSort(data, n);

#ifdef TIME
    time_end = gettime();
    fprintf(stderr, "バケットソートの実行時間 = %lf[秒]\n", time_end - time_start);
#else
    fprintf(stderr, "バケットソート終了\n");
#endif

    // ソート結果の表示
    for (int i = 0; i < n; i++) {
        printf("%d\n", data[i]);
    }

    // データ格納場所を解放
    free(data);

    return 0;
}
