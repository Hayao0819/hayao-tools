###
###  Makefile: regex プログラムの Makefile
###

# コンパイル フラグ
#CC = cc 
CC = gcc 
CFLAGS = -g -Wall -pedantic

OBJS = main.o lexer.o
TARGET = regex

# 依存関係とターゲットの構築ルール
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET) $(LIBRARIES)

main.o: regmatch.h 
lexer.o: regmatch.h 

clean: 
	rm -f $(OBJS) *~ $(TARGET) 

