cma_parse: cma_file.l cma_file.y
	bison -d cma_file.y
	flex cma_file.l
	gcc -o $@ cma_file.tab.c lex.yy.c -lfl

clean: rm -f cma_file.tab.c cma_file.tab.h cma_parse lex.yy.c
