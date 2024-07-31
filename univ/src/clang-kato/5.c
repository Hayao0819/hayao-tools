#include <stdio.h>
#include <string.h>

int main(){
    char s1[20] = "abcd";
    char s2[20] = "abcD";
    int x,y;
    x = strncmp(s1, s2, 4);
    y = strncmp(s1,s2,3);
    printf("%d,%d\n");
    return 0;
}
