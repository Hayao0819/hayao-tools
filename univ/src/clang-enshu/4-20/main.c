#include <stdio.h>

int main()
{
    int x;
    int count = 0;

    printf("input positive integer: ");
    scanf("%d", &x);
    for (int i = 1; i <= x; i++)
    {
        if (x % i == 0)
        {
            printf("%d\n", i);
            count++;
        }
    }
    printf("count: %d\n", count);
}
