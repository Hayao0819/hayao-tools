%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>

int yylex(void);
void yyerror(char *msg);
void printAnswer(double val);
double execFunction1(char *func, double val);
double execFunction2(char *func, double val1, double val2);
int isFunction1(char *func);
int isFunction2(char *func);

int debug = 0;

double max(double a, double b) { return (a > b) ? a : b; }
double min(double a, double b) { return (a < b) ? a : b; }
double areaCircle(double r) { return M_PI * r * r; }

typedef struct {
  char *symbol;
  double (*func)(double);
} relation1;

typedef struct {
  char *symbol;
  double (*func)(double, double);
} relation2;

static relation1 table1[] = {
  { "log",  &log  },
  { "exp",  &exp  },
  { "sin",  &sin  },
  { "cos",  &cos  },
  { "tan",  &tan  },
  { "asin", &asin },
  { "acos", &acos },
  { "atan", &atan },
  { "areaCircle", &areaCircle }
};

static relation2 table2[] = {
  { "atan2", &atan2 },
  { "pow",   &pow   },
  { "max",   &max   },
  { "min",   &min   }
};

#define TABLE1_SIZE (sizeof(table1)/sizeof(relation1))
#define TABLE2_SIZE (sizeof(table2)/sizeof(relation2))
%}

%union {
  double number;
  char *symbol;
}

%token <number> NUMBER
%token <symbol> FUNCTION
%token PLUS MINUS TIMES DIV
%token LPAR RPAR COMMA
%token EOEXPR

%right EOEXPR
%left PLUS MINUS
%left TIMES DIV
%nonassoc SIGN

%type<number> expr

%%

start:
    start EOEXPR start
  | expr { printAnswer($1); }
  |
  ;

expr:
    expr PLUS expr     { $$ = $1 + $3; if (debug) printf("%lf = %lf + %lf\n", $$, $1, $3); }
  | expr MINUS expr    { $$ = $1 - $3; if (debug) printf("%lf = %lf - %lf\n", $$, $1, $3); }
  | expr TIMES expr    { $$ = $1 * $3; if (debug) printf("%lf = %lf * %lf\n", $$, $1, $3); }
  | expr DIV expr      { $$ = $1 / $3; if (debug) printf("%lf = %lf / %lf\n", $$, $1, $3); }
  | NUMBER             { $$ = $1; }
  | PLUS expr %prec SIGN { $$ = $2; }
  | MINUS expr %prec SIGN { $$ = -$2; }
  | LPAR expr RPAR     { $$ = $2; }
  | FUNCTION LPAR expr RPAR {
      if (isFunction1($1)) $$ = execFunction1($1, $3);
      else {
        fprintf(stderr, "function '%s' expects 2 arguments\n", $1);
        exit(1);
      }
    }
  | FUNCTION LPAR expr COMMA expr RPAR {
      if (isFunction2($1)) $$ = execFunction2($1, $3, $5);
      else {
        fprintf(stderr, "function '%s' expects 1 argument\n", $1);
        exit(1);
      }
    }
  ;

%%

void printAnswer(double val) {
  static int no = 0;
  printf(" [%d] %lf\n", ++no, val);
}

double execFunction1(char *func, double val) {
  for (int i = 0; i < TABLE1_SIZE; i++) {
    if (strcmp(func, table1[i].symbol) == 0) {
      if (debug) printf("call %s(%lf)\n", func, val);
      return table1[i].func(val);
    }
  }
  fprintf(stderr, "unknown function (function name = %s)\n", func);
  exit(1);
}

double execFunction2(char *func, double val1, double val2) {
  for (int i = 0; i < TABLE2_SIZE; i++) {
    if (strcmp(func, table2[i].symbol) == 0) {
      if (debug) printf("call %s(%lf, %lf)\n", func, val1, val2);
      return table2[i].func(val1, val2);
    }
  }
  fprintf(stderr, "unknown function (function name = %s)\n", func);
  exit(1);
}

int isFunction1(char *func) {
  for (int i = 0; i < TABLE1_SIZE; i++) {
    if (strcmp(func, table1[i].symbol) == 0) return 1;
  }
  return 0;
}

int isFunction2(char *func) {
  for (int i = 0; i < TABLE2_SIZE; i++) {
    if (strcmp(func, table2[i].symbol) == 0) return 1;
  }
  return 0;
}

void yyerror(char *msg) {
  fprintf(stderr, "parse error: %s\n", msg);
}
