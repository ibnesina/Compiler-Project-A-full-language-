main:
	bison -d sina.y 
	flex sina.l  
	gcc -o sina sina.tab.c lex.yy.c
	./sina