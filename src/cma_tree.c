#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "cma_tree.h"

/* 
 * In a CMA file, each element is either a node, or a leaf.
 * A leaf is a single key,value pair, where-as a node is a key,list 
 * pair, where the list is one or more leafs or nodes.
 */


struct cma_node {
    char *secondary_key;
    struct list_head *list;
};

struct cma_leaf {
    char *value;
};

enum ENTITY_TYPE {
    NODE,
    LEAF
};

struct cma_entity {
    enum ENTITY_TYPE type;
	char *key;
    union {
        struct cma_node *n_val;
        struct cma_leaf *l_val;
    };
    struct list_head list;
};


/*
 * A leaf consists of a key-value pair.
 */

struct cma_entity *create_leaf(char *key, char *value) {
    struct cma_entity *ent = malloc(sizeof(*ent));
    if (!ent) { FATAL_ERROR("Could not allocate memory for leaf entity"); }
    
    ent->key = malloc(strlen(key) + 1);
    ent->l_val = malloc(sizeof(*ent->l_val));
    if (!ent->key || !ent->l_val) { FATAL_ERROR("Could not allocate memory for leaf entity members (key, l_val)"); }

    ent->l_val->value = malloc(strlen(value) + 1);
    if (!ent->l_val->value) { FATAL_ERROR("Could not allocate memory leaf value"); }

    ent->type = LEAF;
    memcpy(ent->key, key, strlen(key) + 1);
    memcpy(ent->l_val->value, value, strlen(value) + 1);

	fprintf(stderr, "Created leaf entity %s(%s)\n", ent->key, ent->l_val->value);
    
    return ent;
}

struct cma_entity *create_node(char *key, char *secondary_key, struct list_head *branch_list) {
    struct cma_entity *i;
    struct cma_entity *ent = malloc(sizeof(*ent));
    if (!ent) { FATAL_ERROR("Could not allocate memory for node entity"); }

    fprintf(stderr, "Creating node from %s [%s], branch_ptr %p\n", key, secondary_key, branch_list);

    ent->key = malloc(strlen(key) + 1);
    ent->n_val = malloc(sizeof(*ent->n_val));
    if (!ent->key || !ent->n_val) { FATAL_ERROR("Could not allocate memory for node entity members (key, n_val)"); }

    ent->n_val->secondary_key= malloc(strlen(secondary_key) + 1);
    if (!ent->n_val->secondary_key) { FATAL_ERROR("Could not allocate memory for node secondary key"); }

    ent->type = NODE;
    memcpy(ent->key, key, strlen(key) + 1);
    memcpy(ent->n_val->secondary_key, secondary_key, strlen(secondary_key) + 1);

	//Is the node empty? If so, it has no members to it's list is null
    ent->n_val->list = branch_list ? branch_list : NULL;

	fprintf(stderr, "Created node %s [%s], branch members: ", ent->key, ent->n_val->secondary_key);
    list_for_each_entry(i, branch_list, list) {
        fprintf(stderr, "(%s) -> ", i->key);
    }
    fprintf(stderr, "\n");

    return ent;
}


struct list_head *add_to_entity_list(struct cma_entity *new, struct list_head *branch_list) {
    fprintf(stderr, "Adding entity with key: '%s' to branch head ptr %p\n", new->key, branch_list);
    struct list_head *head = branch_list;
    struct cma_entity *i;

    //If this is the first entity for this level, init the head.
    if (!head) {
        head = malloc(sizeof(*head));
        fprintf(stderr, "%s is first member of branch, head initialised to %p\n", new->key, head);
		INIT_LIST_HEAD(head);
    }

    //Now we add the entity to the list have an active list for this branch, so add the entity to it.
    list_add(&new->list, head);

    //fprintf(stderr, "=== Current branch & children: ===\n");
    //print_entity_list(head, 0);
    //fprintf(stderr, "==================================\n");
    return head;
}

void PREPEND_CHAR(int x, char c) {
    int i;
    for (i = 0; i < x; i++ ) { printf("%c", c); }
}


void print_entity_list(struct list_head *e, int indent) {
    struct cma_entity *i;

	if (!e) { return; }

	list_for_each_entry(i, e, list) {
		if (i->type == LEAF) {
            PREPEND_CHAR(indent, '\t');
			printf("Leaf(%s -> %s)\n", i->key, i->l_val->value);
		} else if (i->type == NODE) {
            PREPEND_CHAR(indent, '\t');
			printf("Node(%s) [%s]\n", i->key, i->n_val->secondary_key);
            print_entity_list(i->n_val->list, indent + 1);
		} 
	}
}


json_t *print_json(struct list_head *e) {
    json_t *branch = json_array();
    json_t *object, *value;
    struct cma_entity *i;

	list_for_each_entry(i, e, list) {
        object = json_object();
		if (i->type == LEAF) {
            value = json_string(i->l_val->value);
            json_object_set(object, i->key, value);
            json_array_append(branch, object);
		} else if (i->type == NODE) {
            json_object_set(object, i->key, print_json(i->n_val->list));
            json_array_append(branch, object);
		} 
	}
    return branch;
}





void free_tree(struct list_head *root) {
    struct cma_entity *i, *next;

	if (!root) { return; }

	list_for_each_entry_safe(i, next, root, list) {
		if (i->type == LEAF) {
            free(i->l_val->value);
            free(i->l_val);
            free(i->key);
			list_del(&i->list);
            free(i);
		} else if (i->type == NODE) {
            free(i->n_val->secondary_key);
            free_tree(i->n_val->list);
            free(i->n_val);
            free(i->key);
			list_del(&i->list);
            free(i);
		}
		free(root); 
	}
}

void FATAL_ERROR(char *error_str) {
    fprintf(stderr, "[FATAL]: %s\n", error_str);
    exit(1);
}

