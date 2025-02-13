#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool debug = true;

struct cell {
    double item;
    struct cell* next;
};

struct cell* stk;

bool is_empty_stack() {
    return stk == NULL;
}

void init_stack() {
    stk = NULL;
}

// スタックからデータを取得 (解放はしない)
double top() {
    return stk->item;
}

// スタックに x を追加
void push(double x) {
    printf("push %.2lf\n", x);
    struct cell* p = malloc(sizeof(struct cell));  // C 言語では malloc() で領域確保
    p->item = x;
    p->next = stk;
    stk = p;
}

// スタックからデータを取得 (格納していた領域は解放)
double pop() {
    double x;
    struct cell* next;
    if (is_empty_stack()) {
        fprintf(stderr, "##### スタックが空になっています\n");
        return 0;
    }
    x = stk->item;
    next = stk->next;
    free(stk);
    stk = next;
    return x;
}

bool is_valid_ope(char* ope) {
    if (strlen(ope) != 1) return 0;
    switch (ope[0]) {
        case '+':
        case '-':
        case '*':
        case '/':
            return true;
        default:
            return false;
    }
}

void print_stack() {  // スタックの中身の表示
    struct cell* p;
    printf("スタック ( ");
    for (p = stk; p != NULL; p = p->next) {
        printf("%.2lf ", p->item);
    }
    printf(")\n");
}

int main(int argc, char* argv[]) {
    char* input = argv[1];  // コマンドライン引数
    char curr_string[100];

    if (argc <= 1) {
        fprintf(stderr, "##### コマンドライン引数で逆ポーランド記法を入力してください\n");
        return 1;
    }

    init_stack();

    while (strlen(input) > 0) {  // コマンドライン引数の末尾に至るまで
        int ret = sscanf(input, "%s", curr_string);
        if (ret == EOF) break;
        input += strlen(curr_string);

        // 空白を読み飛ばす
        while (input[0] == ' ') {
            if (debug) printf("<- ' ' (空白)\n");
            input++;
        }

        if (isdigit(curr_string[0])) {       // 数字の場合
            double num = atof(curr_string);  // その数字を切り出して
            if (debug) printf("<- %.2lf (数値)\n", num);
            push(num);  // スタックに追加
        } else {        // 演算子の場合
            double num1, num2, answer;
            if (!is_valid_ope(curr_string)) {
                fprintf(stderr, "##### '%s' は未知の演算子です\n", curr_string);
                return 1;
            }

            if (debug) printf("<- \"%s\" (演算子)\n", curr_string);
            num1 = pop();
            num2 = pop();

            switch (curr_string[0]) {
                case '+':
                    answer = num2 + num1;
                    break;
                case '-':
                    answer = num2 - num1;
                    break;
                case '*':
                    answer = num2 * num1;
                    break;
                case '/':
                    if (num1 == 0) {
                        fprintf(stderr, "##### 0 で割ることはできません\n");
                        return 1;
                    }
                    answer = num2 / num1;
                    break;
            }
            push(answer);
            if (debug) print_stack();
        }
    }
    printf("答え%.2f\n", top());

    return 0;
}
