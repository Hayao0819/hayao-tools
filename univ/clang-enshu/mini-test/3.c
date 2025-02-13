#include <stdio.h>

int formula(int x, int y)
{
    if (x == 0)
        return 1;
    int ans = x * x * formula(x - 1, y) % y;
    //printf("%d, %d -> %d\n", x, y, ans);
    return ans;
}

int main()
{
    printf("%d\n", formula(9, 13));
    return 0;
}
