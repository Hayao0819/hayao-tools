extern int printf(const char* __restrict __format, ...);

int main() {
    int a = 5;
    int b = 10;
    int c = a + b;

    printf("The sum of %d and %d is %d\n", a, b, c);

    return 0;
}
