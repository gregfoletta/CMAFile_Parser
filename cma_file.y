%{
#include <stdio.h>        
%}

%token OPEN_PAREN CLOSE_PAREN
%token NODE_NAME
%token QUOTED_TEXT UNQUOTED_TEXT

%%

leaf
    : NODE_NAME OPEN_PAREN UNQUOTED_TEXT CLOSE_PAREN
    | NODE_NAME OPEN_PAREN QUOTED_TEXT CLOSE_PAREN
    ;

%%

int main(int argc, char **argv) {
    yyparse();
}

int yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}


