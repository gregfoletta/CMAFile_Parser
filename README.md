# CheckPoint CMA File Parser

This program takes CheckPoint CMA files and translates them into JSON. 


## CMA Files

Each CMA file is made up of either nodes or leaves. Leaves contain either an unquoted or quoted string which holds a value. Nodes contains leaves and other nodes.

## Node TranslationA

### Prefix Named Nodes

```
(
    :node_a(
        :leaf_a (leaf_value)
    )
)

```json
{
 "node_a": {
  "leaf_a": "leaf_value"
 }
}
```

### Postfix Named Nodes
```
(
	:globals (
		: (not_applicable
			:leaf (value)
		)
	)
)
```

```json
{
 "globals": {
  "not_applicable": {
   "not_applicable": {
    "leaf": "value"
   }
  }
 }
}
```

### Doubly Named Nodes
```
(
	:version (5.9)
	:rule-base ("##star_local_v3"
		:AdminInfo (
			:chkpf_uid ("{0E5CE4FE-895E-48E0-BDCE-44C7BF71A042}")
		)
	)
)
```

```json
{
 "version": "5.9",
 "rule-base": {
  "##star_local_v3": {
   "AdminInfo": {
    "chkpf_uid": "{0E5CE4FE-895E-48E0-BDCE-44C7BF71A042}"
   }
  }
 }
}
```

### Duplicate Keys
```
(
	:node ( 
		:dup_node(
			:leaf_a (leaf_a_val)
		)
		:dup_node(
			:leaf_b (leaf_b_val)  
		)
	)
)
```

```json
{
 "node": {
  "dup_node": [
   {
    "leaf_a": "leaf_a_val"
   },
   {
    "leaf_b": "leaf_b_val"
   }
  ]
 }
}
```


## Leaf Translation

Leafs are translated directly into key/value pairs, and are members of an object which is their parent node.

```
(
	:leaf_a (unquoted_value_a)
	:leaf_b ("quoted value b")
)
```

```json
{
 "leaf_a": "unquoted_value_a",
 "leaf_b": "quoted value b"
}
```

