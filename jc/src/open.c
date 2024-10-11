#include <stdio.h>
#include <stdlib.h>

#include "log.h"
#include "struct.h"

long GetFileSize(FILE* file) {
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);
    return size;
}

JSONFile ReadFullData(char* name) {
    JSONFile json;
    json.name = name;

    FILE* file = fopen(name, "r");
    if (file == NULL) {
        PrintError("Failed to open file");
        return json;
    }

    long size = GetFileSize(name);

    char* data = malloc(size + 1);
    if (data == NULL) {
        PrintError("Failed to allocate memory");
        exit(1);
    }

    fscanf(file, "%s\n", data);
    fclose(file);

    printf("Data: %s\n", data);
    return json;
}
