%.o: %.c
	$(CC) -o $@ $(CPPFLAGS) $(CFLAGS) -c $<
%.c: %.l
	$(LEX) -o$@ $*.l
%.c: %.y
	$(YACC) -d --defines=$*.h -o $@ $<

CC       = gcc #-O2
CCLINK    = gcc
CPPFLAGS  =
CFLAGS    = -Wall -g
LDFLAGS   = 
LEX = flex
YACC = bison
LINKLIBS = -lfl -lm

TARGET = calc

OBJS = parse.o lexer.o calc.o
SOURCES = $(OBJS:.o=.c)

$(TARGET): $(FRC) $(OBJS)
	$(CCLINK) $(LDFLAGS) -o $@ $(OBJS) $(LINKLIBS)

all: $(TARGET)

clean:
	rm -f $(OBJS) *~ parse.c lexer.c
realclean:
	rm -f $(OBJS) *~ parse.c lexer.c $(TARGET)

lexer.c: parse.h
