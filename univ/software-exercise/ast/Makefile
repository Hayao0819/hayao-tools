###
###  Makefile: 構文解析プログラムの Makefile
###

# コンパイル フラグ
#CC = cc 
CC = gcc 
CFLAGS = -g -Wall -pedantic
#YFLAGS = -d         # ヘッダファイルを作成する．
#LIBRARIES = 

# 省略形
OBJS = main.o lexer.o parse.o
TARGET = kadai2

# 依存関係とターゲットの構築ルール
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET) $(LIBRARIES)

parse.o: regmatch.h 
lexer.o: regmatch.h 
main.o: regmatch.h 

clean: 
	rm -f $(OBJS) *~ $(TARGET) 
