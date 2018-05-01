%{
#include <stdio.h>        
#include <string.h>

#include "cma_tree.h"

//Forward declarations to remove warnings
int yylex();
int yyerror();

%}

%token OPEN_PAREN CLOSE_PAREN
%token <str> NAME
%token <str> QUOTED_TEXT UNQUOTED_TEXT

%union yyval {
	struct cma_entity *ent;
    struct list_head *list;
	char *str;
}

%type <ent> node leaf
%type <list> branch

%%

cma_file: OPEN_PAREN branch CLOSE_PAREN { 
    dump_json($2);
    free_tree($2); 
}

branch 	
    : leaf { $$ = add_to_entity_list($1, NULL); }
	| node { $$ = add_to_entity_list($1, NULL); }
	| leaf branch { $$ = add_to_entity_list($1, $2); }
	| node branch  { $$ = add_to_entity_list($1, $2); }

	;

leaf
	: NAME OPEN_PAREN UNQUOTED_TEXT CLOSE_PAREN { $$ = create_leaf($1, $3); free($1); free($3); }
	| NAME OPEN_PAREN QUOTED_TEXT CLOSE_PAREN { $$ = create_leaf($1, $3); free($1); free($3); }
	| NAME OPEN_PAREN CLOSE_PAREN { $$ = create_leaf($1, ""); free($1); }
	;

node
	: NAME OPEN_PAREN branch CLOSE_PAREN { $$ = create_node($1, "", $3); }
	| NAME OPEN_PAREN QUOTED_TEXT branch CLOSE_PAREN { $$ = create_node($1, $3, $4); }
	| NAME OPEN_PAREN UNQUOTED_TEXT branch CLOSE_PAREN { $$ = create_node($1, $3, $4); }
	;

%%

int main(int argc, char **argv) {
	int x;
	for (x = 1; x < argc; x++) {
		if (!strcmp(argv[x], "-d")) {
			ENABLE_DEBUG();
        }
    }

    yyparse();
}

int yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}


