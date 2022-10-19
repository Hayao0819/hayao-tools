#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


void usage(){
    puts("Usage: climenu [options]");
    printf("Options:");
    printf("  -h, --help\tShow this help message\n");
    return;
}

int main (int argc, char *argv[]) {

    // 引数解析
    int opt;
    while ((opt = getopt(argc, argv, "h")) != -1) {
        switch (opt) {
            case 'h':
                usage();
                break;
            default:
                break;
        }
    }
    char args[argc - optind];
    for (int i = 0; i < argc - optind; i++) {
        args[i] = *argv[optind + i];
        puts(&args[i]); // デバッグ用
    }

    // 矢印キーの入力をいつか実装すること
    char input[2];
    scanf("%3s", input);
    printf("input: %s" , &input[2]);

    return 0;
}
