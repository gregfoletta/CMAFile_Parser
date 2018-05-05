#include "list.h"

struct cma_entity;

struct cma_entity *create_leaf(char *, char *);
struct cma_entity *create_node(char *, char *, struct list_head *);
struct list_head *add_to_entity_list(struct cma_entity *, struct list_head *);

void print_entity_list(struct list_head *, int); 
void dump_json(struct list_head *); 
void free_tree(struct list_head *);

void ENABLE_DEBUG(void);
void DISABLE_DEBUG(void);

	
