%option noyywrap
%{
#include "cma_file.tab.h"
%}


%%
"(" { return OPEN_PAREN; }
")" { return CLOSE_PAREN; }
":"[-a-zA-Z0-9\._]* { yylval.str = strdup(yytext); return NAME; }

"\""[^"]*"\"" { yylval.str = strdup(yytext); return QUOTED_TEXT; }
[-a-zA-Z0-9\._@]* { yylval.str = strdup(yytext); return UNQUOTED_TEXT; }

[[:space:]+] { }

%%
