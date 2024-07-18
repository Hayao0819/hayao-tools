#include <stdio.h>

void bsort(int a[5][2])
{
    for (int i = 5; i > 0; i--)
    {
        for (int j = 1; j < i; j++)
        {
            if (a[j - 1][1] > a[j][1])
            {
                int tmp[2] = {
                    a[j][0],
                    a[j][1]};
                a[j][0] = a[j - 1][0];
                a[j][1] = a[j - 1][1];

                a[j - 1][0] = tmp[0];
                a[j - 1][1] = tmp[1];
            }
        }
    }
}

int main(void)
{
    // (179,'E'), (175,'P'), (178,'L'), (173,'P'), (163,"A")
    int input[5][2] = {
        {179, 'E'},
        {175, 'P'},
        {178, 'L'},
        {173, 'P'},
        {163, 'A'}};

    for (int i = 0; i < 5; i++)
    {
        for (int j = 0; j < 2; j++)
        {
            printf("%d\n", input[i][j]);
        }
    }

    return 0;
}
