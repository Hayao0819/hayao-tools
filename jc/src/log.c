#include <stdio.h>

void PrintError(char* data) {
    printf("Error: %s\n", data);
}

void PrintInfo(char* data) {
    printf("Success: %s\n", data);
}

void PrintDebug(char* data) {
// #ifdef DEBUG
    printf("Debug: %s\n", data);
// #endif
}
