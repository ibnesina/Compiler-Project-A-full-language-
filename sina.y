%{
    #include<stdio.h>
	#include<stdlib.h>
	#include<math.h>
	#include<string.h>

    int yylex();
	int yyerror(char *s);

    extern int yyparse();
    extern FILE *yyin;
    extern FILE *yyout;

    //Coding Part Starts
    char varName[1000][1000];
	int store[1000];
	int count = 1;
    int flag, cvar;

	int isDeclared(char *now){
		for(int i=1; i<count; i++){
			if(strcmp(varName[i], now)==0){
				return i; 
			}
		}
		return 0;
	}

    int setVal(char *now, int v) {
		int id = isDeclared(now);
		store[id] = v;
	}

    int getVal(char *now) {
		return store[isDeclared(now)];
	}

    int addNewVar(char *now) {
		if(isDeclared(now) != 0) {
            return 0;
        }

		strcpy(varName[count], now);
		store[count]=0;
		count++;
	}
%}

%union {
    int val;
    char string[100];
}

%token<val> INTEGER FLOAT
%token<string>VARIABLE STRING
%type<val>expr
%type<val>stmt
%token HEADER VOID INT CHAR DOUBLE DS LTHAN GTHAN LTE GTE EQUAL COMMA COLON SCOMMENT COMMENT MODULUS CONTINUE AND OR NOT DECREMENT INCREMENT DIV MUL MINUS PLUS NOTEQUAL SCAN PRINT ASSIGN RP LP RB LB WHILE FOR CASE SWITCH IF ELSE ELIF RETURN BREAK MAIN DEFAULT SIN COS TAN POW LOG LN FACTORIAL SQRT GCD MIN MAX
%left SIN COS TAN GCD MIN MAX
%left AND OR NOT
%left EQUAL NOTEQUAL LTHAN GTHAN LTE GTE
%left PLUS MINUS
%left MUL DIV MODULUS
%left POW

%%
program: HEADER program { printf("Header File Added\n\n"); }
        | MAIN LB RB LP line RP { printf("Main Function Ends\n\n") }
        | function program
        | DS;

line: line stmt
        | line array
        | line character
        | line declare DS {printf("Variable declared\n\n");}
        | line arrayDeclare DS {printf("Array declared\n\n");}
        | ;

array: VARIABLE ASSIGN LB arrayExpr RB DS {
            printf("Array Value Assigned\n\n");
        }
        ;

arrayExpr: expr
            | expr COMMA arrayExpr;

character: VARIABLE ASSIGN LB expr RB DS {
            printf("Character Value Assigned\n\n");
        };

stmt: DS
        | expr DS { 
            printf("Value of expression = %d\n\n", $1); 
            $$ = $1; 
        }
        | VARIABLE ASSIGN expr DS {
            if(isDeclared($1) != 0) {
                setVal($1, $3);
                $$ = $3;
            }
            else {
                printf("Variable not declared\n\n");
            }
        } 
        | IF LB expr RB LP line RP {
            if($3) {
                printf("--- IF Condition Matched ---\n\n");
            }
            else {
                printf("--- Condition didn't Match ---\n\n");
            }
        } 
        | IF LB expr RB LP line RP ELSE LP line RP {
            if($3) {
                printf("--- IF Condition Matched ---\n\n");
            }
            else {
                printf("--- ELSE Condition Matched ---\n\n");
            }
        } 
        | IF LB expr RB LP line RP ELIF LB expr RB LP line RP ELSE LP line RP {
            if($3) {
                printf("--- IF Condition Matched ---\n\n");
            }
            if($10) {
                printf("--- ELSE IF Condition Matched ---\n\n");
            }
            else {
                printf("--- ELSE Condition Matched ---\n\n");
            }
        }
        | WHILE LB expr RB LP line RP {
            printf("--- While Loop Starts --- \n\n");
            if($3) {
                printf("Inside While Loop\n\n");
            }
            printf("--- While Loop Ends --- \n\n");
        }
        | FOR LB VARIABLE ASSIGN INTEGER COMMA VARIABLE relop INTEGER COMMA VARIABLE ASSIGN VARIABLE PLUS INTEGER RB LP line RP {
            for(int i = $5; i<= $9; i = i + $15) {
                printf("Expression value = %d\n", i);
            }
            printf("\n");
            printf("--- For Loop Ends --- \n\n");
        }
        | FOR LB VARIABLE ASSIGN INTEGER COMMA VARIABLE relop INTEGER COMMA VARIABLE ASSIGN VARIABLE MINUS INTEGER RB LP line RP {
            for(int i = $5; i>= $9; i = i - $15) {
                printf("Expression value = %d\n", i);
            }
            printf("\n");
            printf("--- For Loop Ends --- \n\n");
        }
        | PRINT LP expr RP DS {
            printf("Print: %d\n\n", $3);
        }
        | PRINT LP STRING RP DS {
            printf("Print: %s\n\n", $3);
        }
        | SCOMMENT {
            printf("This is Single Line Comment\n\n");
        }
        | COMMENT {
            printf("This is Multiple Line Comment\n\n");
        }
        | SWITCH LB caseval RB LP scase RP {
            printf("--- Switch Case ---\n\n");
        }
        ;

caseval: INTEGER {
            flag = 0;
            cvar = $1;
        } ;

scase: grammar
        | grammar d_grammar ;

grammar: grammar cnumber
        | ;
    
cnumber: CASE INTEGER COLON line BREAK DS {
            if(cvar == $2) {
                printf("Matched for Case: %d\n\n",$2);
				flag = 1;
            }
        } ;

d_grammar: DEFAULT COLON line {
            if(flag == 0) {
				printf("In default segement\n\n");
			}
        } ;

relop: EQUAL
        | NOTEQUAL
        | GTHAN
        | LTHAN
        | GTE
        | LTE ;

function: datatype VARIABLE LB param RB LP line RP {
                int tmp = addNewVar($2);
                if(tmp == 0) {
                    printf("Function is already Declared\n\n");
                    exit(-1);
                }
                else {
                     printf("--- User defined function ---\n\n");
                }
               
            }
            | ;

param: param COMMA paramDeclare
        | paramDeclare ;

paramDeclare: datatype VARIABLE
                | ;


declare: datatype ID ;

arrayDeclare: datatype ID LB INTEGER RB;

datatype: INT
            | DOUBLE
            | CHAR
            | VOID ;

ID: ID COMMA VARIABLE {
        int tmp = addNewVar($3);
        if(tmp == 0) {
            printf("Variable already Declared\n\n");
            exit(-1);
        }
    }
    | VARIABLE {
        int tmp = addNewVar($1);
        if(tmp == 0) {
            printf("Variable already Declared\n\n");
            exit(-1);
        }
    } ;

expr: INTEGER {$$ = $1;}
        | FLOAT {$$ = $1;}
        | VARIABLE {$$ = getVal($1);}
        | expr PLUS expr {printf("Addition: %d + %d = %d\n\n", $1, $3, $1+$3); $$ = $1 + $3;}
        | expr MINUS expr {printf("Subtraction: %d - %d = %d\n\n", $1, $3, $1-$3); $$ = $1 - $3;}
        | expr MUL expr {printf("Multiplication: %d x %d = %d\n\n", $1, $3, $1*$3); $$ = $1 * $3;}
        | expr DIV expr {
            if($3) {
                printf("Division: %d / %d = %d\n\n", $1, $3, $1/$3); 
                $$ = $1 / $3;
            }
            else {
                $$ = 0;
                printf("Divisor is zero\n\n");
            }
        }
        | expr MODULUS expr {
            if($3) {
                int x = $1, y = $3;
                printf("Modulus: %d mod %d = %d\n\n", x, y, x%y); 
                $$ = x % y;
            }
            else {
                $$ = 0;
                printf("Modulus by zero\n\n");
            }
        }
        | expr POW expr {
            int ans = pow($1, $3);
            printf("Power: %d ^ %d = %d\n\n", $1, $3, ans); 
            $$ = pow($1, $3);
        }
        | expr GTHAN expr {
            printf("Greater Than: %d > %d?\n", $1, $3); 
            $$ = $1 > $3;
            if($$) {
                printf("Yes, Greater\n\n"); 
            }
            else {
                printf("No, Not Greater\n\n"); 
            }
        }
        | expr LTHAN expr {
            printf("Less Than: %d < %d?\n", $1, $3); 
            $$ = $1 < $3;
            if($$) {
                printf("Yes, Lesser\n\n"); 
            }
            else {
                printf("No, Not Lesser\n\n"); 
            }
        }
        | expr GTE expr {
            printf("Greater Than or Equal: %d >= %d?\n", $1, $3); 
            $$ = $1 >= $3;
            if($$) {
                printf("Yes, Greater Than or Equal\n\n"); 
            }
            else {
                printf("No, Not Greater Than or Equal\n\n"); 
            }
        }
        | expr LTE expr {
            printf("Less Than or Equal: %d <= %d?\n", $1, $3); 
            $$ = $1 <= $3;
            if($$) {
                printf("Yes, Less Than or Equal\n\n"); 
            }
            else {
                printf("No, Not Less Than or Equal\n\n"); 
            }
        }
        | expr EQUAL expr {
            printf("Equal: %d == %d?\n", $1, $3); 
            $$ = $1 == $3;
            if($$) {
                printf("Yes, Equal\n\n"); 
            }
            else {
                printf("No, Not Equal\n\n"); 
            }
        }
        | expr NOTEQUAL expr {
            printf("Not Equal: %d != %d?\n", $1, $3); 
            $$ = $1 != $3;
            if($$) {
                printf("Yes, Not Equal\n\n"); 
            }
            else {
                printf("No, Equal\n\n"); 
            }
        }
        | expr AND expr {
            $$ = $1 && $3;
            if($$) {
                printf("Logically True\n\n");
            }
            else {
                printf("Logically False\n\n");
            }
        }
        | expr OR expr {
            $$ = $1 && $3;
            if($$) {
                printf("Logically True\n\n");
            }
            else {
                printf("Logically False\n\n");
            }
        }
        | expr INCREMENT {
            $$ = $1 + 1;
            printf("Incremented Value = %d\n\n", $$);
        }
        |expr DECREMENT {
            $$ = $1 - 1;
            printf("Decremented Value = %d\n\n", $$);
        }
        | SIN LB expr RB {
            printf("sin(%d) = %.2lf\n\n", $3, sin(3.1416 * $3 / 180));
            $$ = sin(3.1416 * $3 / 180);
        }
        | COS LB expr RB {
            printf("cose(%d) = %.2lf\n\n", $3, cos(3.1416 * $3 / 180));
            $$ = cos(3.1416 * $3 / 180);
        }
        | TAN LB expr RB {
            printf("tan(%d) = %.2lf\n\n", $3, tan(3.1416 * $3 / 180));
            $$ = tan(3.1416 * $3 / 180);
        }
        | LOG LB expr RB {
            printf("log(%d) = %.6lf\n\n", $3, log($3) / log(10.0));
            $$ = log($3) / log(10.0);
        }
        | LN LB expr RB {
            printf("ln(%d) = %.6lf\n\n", $3, log($3));
            $$ = log($3);
        }
        | FACTORIAL LB expr RB {
            int fact = 1;
            for(int i = 1; i<=$3; i++) {
                fact *= i;
            }
            $$ = fact;
            printf("Factorial of %d = %d\n\n", $3, fact);
        }
        | SQRT LB expr RB {
            printf("Square Root of %d = %.4lf\n\n", $3, sqrt($3 * 1.0));
            $$ = sqrt($3 * 1.0);
        }
        | GCD LB expr COMMA expr RB {
            int a = $3, b = $5;

            while (b != 0) {
                int temp = b;
                b = a % b;
                a = temp;
            }

            printf("GCD of %d and %d = %d\n\n", $3, $5, a);
            $$ = a;
        }
        | MAX LB expr COMMA expr RB {
            int a = $3, b = $5;

            if(a>b) {
                printf("%d is big between %d and %d\n\n", a, a, b);
                $$ = a;
            }
            else if(a<b){
                printf("%d is big between %d and %d\n\n", b, a, b);
                $$ = b;
            }
            else {
                printf("%d and %d are Equal\n\n", a, b);
                $$ = a;
            }
        }
        | MIN LB expr COMMA expr RB {
            int a = $3, b = $5;

            if(a>b) {
                printf("%d is small between %d and %d\n\n", b, a, b);
                $$ = b;
            }
            else if(a<b){
                printf("%d is small between %d and %d\n\n", a, a, b);
                $$ = a;
            }
            else {
                printf("%d and %d are Equal\n\n", a, b);
                $$ = a;
            }
        }
        | LP expr RP {$$ = $2;};

%%

int yyerror(char *s) 
{
    fprintf(stderr, "error: %s\n", s);
}

int main() 
{
    freopen("input.txt", "r", stdin);
	freopen("output.txt", "w", stdout);

    yyparse();
    return 0;
}