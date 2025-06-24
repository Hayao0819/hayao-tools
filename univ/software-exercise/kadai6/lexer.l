%option nounput
%option noinput
%{

/* 四則演算用の字句解析 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parse.h"

extern int debug;

%}

%%

[0-9\.]+ {  /* 数字 */
  yylval.number = atof(yytext);
  if (debug) printf("NUMBER(%lf)\n", yylval.number);
  return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]* {
  yylval.symbol = strdup(yytext);
  if (debug) printf("FUNCTION(%s)\n", yylval.symbol);
  return FUNCTION;
}

\+ { return PLUS; }
\- { return MINUS; }
\* { return TIMES; }
\/ { return DIV; }
\( { return LPAR; }
\) { return RPAR; }
\, { return COMMA; }

\n { return EOEXPR; }

[ ] {} /* スペースは読み飛ばす */

 /* それ以外の予期しない入力 */
. { printf("unknown token %s (in heximal form, 0x%02x)\n", yytext, yytext[0]); }

%%
