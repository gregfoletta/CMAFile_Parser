%option noyywrap
%{
#include "cma_file.tab.h"
%}


%%
"(" { return OPEN_PAREN; }
")" { return CLOSE_PAREN; }
":"[-a-zA-Z0-9\._]* { yylval.str = strdup(yytext + 1); return NAME; }

"\""[^"]*"\"" { 
    char *text = yytext + 1; 
    text[strlen(text) - 1] = '\0';
     yylval.str = strdup(text); return QUOTED_TEXT; 
}

[-a-zA-Z0-9\._@]* { yylval.str = strdup(yytext); return UNQUOTED_TEXT; }

[[:space:]+] { }

%%
