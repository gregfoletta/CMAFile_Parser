%option noyywrap
%{
 #include "cma_file.tab.h"
%}


%%
"(" { return OPEN_PAREN; }
")" { return CLOSE_PAREN; }
":"[-a-zA-Z0-9\._]* { return NODE_NAME; }

"\""[^"]*"\"" { return QUOTED_TEXT; }
[-a-zA-Z0-9\._@]* { return UNQUOTED_TEXT; }

[[:space:]+] { }

%%
