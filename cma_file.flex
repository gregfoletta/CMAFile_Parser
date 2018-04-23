%{

#include <stdio.h>        

%}


%%
"(" { printf("OPEN_PAREN "); }
")" { printf(" CLOSE_PAREN"); }
":"[a-zA-Z0-9\._]* { printf("NODE_NAME{%s}", yytext); }

"\""[^"]*"\"" { printf("QUOTED_TEXT{%s}", yytext); }
[-a-zA-Z0-9\._@]* { printf("UNQUOTED_TEXT{%s}", yytext); }

%%


int main(int argc, char **argv) {
    yylex();
}

