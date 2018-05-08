cma_parse: src/cma_file.l src/cma_file.y src/cma_tree.c 
	bison -d src/cma_file.y
	flex src/cma_file.l
	gcc -g -o $@ cma_file.tab.c lex.yy.c src/cma_tree.c -lfl -ljansson

clean: 
	rm -f cma_file.tab.c cma_file.tab.h cma_parse lex.yy.c
