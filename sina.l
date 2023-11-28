%{
	#include<stdio.h>
    #include<math.h>
    #include<stdlib.h>
    #include<string.h>
    
    #include "sina.tab.h"

    int yyerror(char *);
%}

letter [A-Za-z]+
id [A-Za-z_][A-Za-z0-9_]*
integer [+|-]?[0-9]+
number [+|-]?[0-9]+(.[0-9]+)?
ws [ \t\n]
delim ({ws})*

%%
{delim} {}

"#dep["{id}".hed]" {return HEADER;}

"integer" {return INT;}

"fraction" {return DOUBLE;}

"charac" {return CHAR;}

["].*["] {
    yytext++;
    int lenght = strlen(yytext);
    strcpy(yylval.string, yytext);
    yylval.string[lenght-1] = '\0';
    return STRING;
}

"back" {return RETURN;}

"exit" {return BREAK;}

"carryon" {return CONTINUE;}

"iff" {return IF;}

"elsif" {return ELIF;}

"els" {return ELSE;}

"width[".*"]" {printf("Size of any Variable\n");}

"go" {return SWITCH;}

"case" {return CASE;}

"empty" {return VOID;}

"start" {return MAIN;}

"floop" {return FOR;}

"wloop" {return WHILE;}

"<" {return LB;}

">" {return RB;}

"[" {return LP;}

"]" {return RP;}

"+" {return PLUS;}

"~" {return MINUS;}

"#" {return MUL;}

"/" {return DIV;}

"%" {return MODULUS;}

"++" {return INCREMENT;}

"~~" {return DECREMENT;}

"=" {return ASSIGN;}

"==" {return EQUAL;}

"!==" {return NOTEQUAL;}

"<<" {return LTHAN;}

">>" {return GTHAN;}

"<<=" {return LTE;}

"=>>" {return GTE;}

"input" {return SCAN;}

"output" {return PRINT;}

"default" {return DEFAULT;}

"sine" {return SIN;}

"cose" {return COS;}

"tang" {return TAN;}

"^" {return POW;}

"log" {return LOG;}

"ln" {return LN;}

"fact" {return FACTORIAL;}

"root" {return SQRT;}

"gcd" {return GCD;}

"min" {return MIN;}

"max" {return MAX;}

"&" {return AND;}

"|" {return OR;}

"!" {return NOT;}

"," {return COMMA;}

"yes" {printf("True");}

"no" {printf("No");}

"##"[^\n]* {return SCOMMENT;}
"//*"([ \t\n]*.[ \t\n]*)*"*//" {return COMMENT;}

"::" {return COLON;}

"arr "("integer"|"fraction"|"charac"){id}"["{number}"]" {printf("Array\n");}

{integer} { yylval.val = atoi(yytext); return INTEGER;}

{number} { yylval.val = atoi(yytext); return FLOAT;}

[@] {return DS;}

{id} {
    strcpy(yylval.string, yytext);
    return VARIABLE;
}

. {printf("Undefined syntax\n");}
%%

int yywrap(void){
	return 1;
}
