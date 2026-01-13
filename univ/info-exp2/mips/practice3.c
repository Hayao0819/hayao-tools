int a, b;
int x, f;

int linear(int a, int b, int x) {
    int v1, f;
    v1 = a * x;
    f = v1 + b;
    return f;
}

int main() {
    print_string("a = ");
    a = read_int();
    print_string("b = ");
    b = read_int();
    for (x = 0; x < 10; x++) {
        f = linear(a, b, x);
        print_int(f);
        print_string("\n");
    }
    return 0;
}
