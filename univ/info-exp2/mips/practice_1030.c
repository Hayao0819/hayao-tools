int lg;
int n;
int i;
int main() {
    print_string("Please input an integer: ");
    n = read_int();
    lg = 0;
    for (i = n; i > 1; i = i / 2) {
        lg = lg + 1;
    }
    print_string("Result = ");
    print_int(lg);
    print_string("\n");
    return 0;
}