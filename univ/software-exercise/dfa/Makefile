###
###  Makefile: dfa プログラムの Makefile
###

# コンパイル フラグ
#CC = cc 
CC = gcc 
CFLAGS = -g -Wall -pedantic
#YFLAGS = -d         # ヘッダファイルを作成する．
#LIBRARIES = -lm # math

OBJS = main.o lexer.o parse.o nfa.o dfa.o
TARGET = kadai4

# 依存関係とターゲットの構築ルール
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET) $(LIBRARIES)

main.o: regmatch.h 
lexer.o: regmatch.h 
parse.o: regmatch.h 
nfa.o: regmatch.h 
dfa.o: regmatch.h 

clean: 
	rm -f $(OBJS) *~ $(TARGET) 

