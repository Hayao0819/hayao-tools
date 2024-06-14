#include <stdio.h>

int formula(int x, int y)
{
    if (x==0) return 1;
    return x * x * formula(x - 1, y) % y;
}

int main()
{
    printf("%d\n", formula(6, 13));
    return 0;
}
