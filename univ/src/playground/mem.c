#include <stdio.h>

int main()
{
    int x[] = {2, 4, 6, 8};
    printf("x = {2,4,6,8}\n");
    printf("x[0]: %d\n", x[0]);
    printf("x[1]: %d\n", x[1]);
    printf("x[2]: %d\n", x[2]);
    printf("x[3]: %d\n", x[3]);

    printf("sizeof(x[0]): %lu\n", sizeof(x[0]));
    printf("sizeof(x): %lu\n", sizeof(x));
    printf("x: %p\n", x);
    printf("&(x[0]): %p\n", &(x[0]));
    printf("&(x[1]): %p\n", &(x[1]));
    printf("x[0]: %d\n", x[0]);
}

// printf("%d\n", *(int*)(void*)(x+sizeof(int)*1));
