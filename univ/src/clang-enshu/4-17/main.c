#include <stdio.h>

int main()
{
    int max;
    printf("input positive integer: ");
    scanf("%d", &max);
    for (int i = 1; i <= max; i = i + 2)
    {
        printf("%d ", i);
        printf("\n");
    }
    return 0;
}
