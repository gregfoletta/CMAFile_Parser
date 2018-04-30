#include "list.h"
#include <jansson.h>

struct cma_entity;

struct cma_entity *create_leaf(char *, char *);
struct cma_entity *create_node(char *, char *, struct list_head *);
struct list_head *add_to_entity_list(struct cma_entity *, struct list_head *);

void print_entity_list(struct list_head *, int); 
json_t *print_json(struct list_head *); 
void free_tree(struct list_head *);

void FATAL_ERROR(char *);

	
