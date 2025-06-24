###
###  Makefile: regmatch プログラムの Makefile
###

# コンパイル フラグ
CC = gcc 
CFLAGS = -g -Wall -pedantic
#CFLAGS = -O2
OBJS = lexer.o parse.o nfa.o dfa.o main.o
TARGET = kadai5

# 依存関係とターゲットの構築ルール
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET) $(LIBRARIES)

lexer.o: regmatch.h 
parse.o: regmatch.h 
nfa.o: regmatch.h 
dfa.o: regmatch.h 
main.o: regmatch.h 

clean: 
	rm -f $(OBJS) *~ $(TARGET) 

