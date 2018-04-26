%{
#include <stdio.h>        

#include "cma_tree.h"

//Forward declarations to remove warnings
int yylex();
int yyerror();

%}

%token OPEN_PAREN CLOSE_PAREN
%token <str> NAME
%token <str> QUOTED_TEXT UNQUOTED_TEXT

%union yyval {
	struct cma_node *node;	
	struct cma_leaf *leaf;
	struct cma_entity *ent;
	char *str;
}

%type <node> node;
%type <leaf> leaf;
%type <ent> branch;


%%

cma_file: OPEN_PAREN branch CLOSE_PAREN { print_entity_list($2); };

branch 	: { $$ = NULL; }
	| leaf branch { $$ = add_leaf($1, $2); }
	| node branch  { $$ = add_node($1, $2); }
	;

leaf
	: NAME OPEN_PAREN UNQUOTED_TEXT CLOSE_PAREN { printf("Node(%s -> %s)\n", $1, $3); $$ = create_leaf($1, $3); }
	| NAME OPEN_PAREN QUOTED_TEXT CLOSE_PAREN { printf("Node(%s -> %s)\n", $1, $3); $$ = create_leaf($1, $3); }
	;

node
	: NAME OPEN_PAREN branch CLOSE_PAREN { printf("Node(%s [%s])\n", $1, "-"); $$ = create_node($1, "", $3); }
	| NAME OPEN_PAREN QUOTED_TEXT branch CLOSE_PAREN { printf("Node(%s [%s])\n", $1, $3); create_node($1, $3, $4); }
	| NAME OPEN_PAREN UNQUOTED_TEXT branch CLOSE_PAREN { create_node($1, $3, $4); }
	;

%%

int main(int argc, char **argv) {
    yyparse();
}

int yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}


