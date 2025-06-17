package univ.java.src.main;

public class Hello {
    static int sayHello(String[] args) {
        System.out.println("Hello, World!");
        return 0;
    }

    public static void main(String[] args) {
        System.exit(sayHello(args));
    }
}
