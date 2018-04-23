%{
#include <stdio.h>        

//Forward declarations to remove warnings
int yylex();
int yyerror();

%}

%token OPEN_PAREN CLOSE_PAREN
%token NODE_NAME
%token QUOTED_TEXT UNQUOTED_TEXT

%%

cma_file: OPEN_PAREN branch CLOSE_PAREN { printf("{root}"); };

branch
	: 
	| leaf branch
	| node branch

node
	: NODE_NAME OPEN_PAREN QUOTED_TEXT branch CLOSE_PAREN { printf("{quoted node}"); }
	| NODE_NAME OPEN_PAREN UNQUOTED_TEXT branch CLOSE_PAREN { printf("{unquoted node}"); }
	| NODE_NAME OPEN_PAREN branch CLOSE_PAREN { printf("{node}"); };

leaf
	: NODE_NAME OPEN_PAREN UNQUOTED_TEXT CLOSE_PAREN { printf("{leaf unquoted}"); }
	| NODE_NAME OPEN_PAREN QUOTED_TEXT CLOSE_PAREN { printf("{leaf quoted}"); };
%%

int main(int argc, char **argv) {
    yyparse();
}

int yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}


