/*
・問題12-4 構造体で生徒を定義する
・問題13-4 ファイルから情報を読み取る

```jiro.txt
name=jiro
age=14
```

```taro.txt
name=taro
age=18
```

```bash
$ ./a.out studentfile.txt
```
*/

#include <stdio.h>

typedef struct
{
    char name[32];
    int age;
} Student;

Student read_from_file(char *path);

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s <filename> ...\n", argv[0]);
        return 1;
    }

    for (int i = 1; i < argc; i++)
    {
        Student student = read_from_file(argv[i]);
        printf("name=%s, age=%d\n", student.name, student.age);
    }

    return 0;
}

Student read_from_file(char *path)
{
    FILE *fp;
    Student student;

    if ((fp = fopen(path, "r")) == NULL)
    {
        fprintf(stderr, "Error: Cannot open %s\n", path);
        return student;
    }

    fscanf(fp, "name=%s\n", student.name);
    fscanf(fp, "age=%d\n", &student.age);

    fclose(fp);

    return student;
}
