#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    char *str = (char *)malloc(13 * sizeof(char));
    if (str == NULL)
    {
        return 1;
    }

    str = strcpy(str, "This is too long string.");

    printf("str: %s\n", str);
    printf("strlen(str): %lx\n", strlen(str));
    printf("sizeof(str): %lx\n", sizeof(str));

    free(str);

    return 0;
}
