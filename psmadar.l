/*Programmed by Parinaz Soltanzadeh*/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    void yyerror(char const *s);
    #include "psmadar.tab.h"
%}

white        [ \t]+
letter       [a-zA-Z]
digit        [0-9]
integer      {digit}+
 
Operator     ":" 

%%
{white} { }
{integer} { yylval=atoi(yytext); return NUMBER;}
("R"|"r")  { return Resistor; } 
("L"|"l")  { return Inductor; }
("C"|"c")  { return Capacitor; }
{Operator} {return OP;}

"AND" { return SeriOp;}
"OR" { return MovaziOp;}

"\n" return END;

"//".*
. { yyerror("Unrecognized character"); }
%%

int yywrap(void){
    return 1;
}