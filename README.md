# CheckPoint CMA File Parser

This program takes CheckPoint CMA files and translates them into JSON. 

## Version

Version 0.2

## Prerequisites

* [flex](https://github.com/westes/flex) and [bison](https://www.gnu.org/software/bison/).
* [jannson](http://www.digip.org/jansson/) JSON library.
	* `sudo apt install libjansson4` or `sudo yum install jansson-devel`

## Bug Reports

Please raise any bugs, issues or feature requests through the [issues page](https://github.com/gregfoletta/CMAFile_Parser/issues).

## Build and Installation

Use `make` to build the file. There's no installation per-se, the binary build is `cma_parse` and you can move it to wherever suits.

## Usage

The `./cma_parse` program reads input from stdin. So you can either redirect from a file (`./cma_parse < path/to/cma/object_5_0.C`), or the configuration can be pasted directly in to the terminal.

## Example

```
% ./cma_parse < objects_5_0.C
{
 "version": "8.0",
 "globals": {
  "not_applicable": {
   "AdminInfo": {
    "LastModified": {
     "Time": "Mon Nov 21 16:30:00 2011",
     "By": "CheckPoint",
     "From": "CheckPoint"
    },
    "chkpf_uid": "{A478A9E4-18FC-4204-AD0D-58EC143A5CE6}",
    "ClassName": "any_object",
    "table": "globals",
    "icon": "Rulebase/na"
   },
   "color": "black",
   "ID": "0",
   "display_name": "n/a",
   "description": "Not applicable for rule. Protection is relevant only for rule exception."
  },
  "predefined_interface_container": {
   "AdminInfo": {
    "chkpf_uid": "{9BEEA09C-AF03-42CE-964F-DAAB829A27C7}",
    "ClassName": "predefined_interface_container",
    "table": "globals",
    "LastModified": {
     "Time": "Mon Nov  8 15:42:15 2010",
     "last_modified_utc": "1289230935",
     "By": "Check Point Security Management Server Update Process",
     "From": "localhost"
    },
    "icon": "Unknown"
   },
... continues ...
```

## CMA File Conversion

This Each CMA file is made up of either nodes or leaves. Leaves hold actual settings, while nodes are contains that hold one or more leaves or nodes.

## Leaf Translation

Leafs are translated directly into key/value pairs, and are members of an object which is their parent node. We also see here that the CMA files start an end with
parenthesis which become the outer JSON object.

All values are considered JSON strings, so the quoted values have their quotes stripped. So :leaf ("A value.") becomes { "leaf": "A value." } rather than { "leaf": "\"A value.\"" }.
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

## Node Translation

There are a number of different types of nodes.

### Prefix Named Nodes

These nodes are named before the opening parenthesis.

```
(
    :node_a (
        :leaf_a (leaf_value)
    )
)
```

This results in a member of an object pointing to another object.

```json
{
 "node_a": {
  "leaf_a": "leaf_value"
 }
}
```

### Postfix Named Nodes

Some nodes have the name after the parenthesis, as we see with the 'not_applicable' node below:

```
(
	:globals (
		: (not_applicable
			:leaf (value)
		)
	)
)
```

These are converted to the same format as the prefix named nodes.

```json
{
 "globals": {
  "not_applicable": {
   "leaf": "value"
  }
 }
}
```

### Doubly Named Nodes

Some nodes have a name both before and after the parenthesis, as we see with the 'rule-base' & '##star_local_v3' node below:
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

In this instance, we create two nodes, with the 'rule-base' node pointing towards the '##star_local_v3' node:

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

Finally, there are instances where a node contains other nodes that have duplicate names. In the example below we see
a network object group which has members references in a different part of the file. These nodes are all named 'ReferenceObject'.

```
(
    : (All_Intranet_Gateways
        :AdminInfo (
            :ClassName (network_object_group)
            :table (network_objects)
        )
        : (ReferenceObject
            :Name (Berlin_Gateway)
            :Table (network_objects)
            :Uid ("{8AA12D62-B698-4B3B-8A0B-A4CE13A64CAC}")
        )
        : (ReferenceObject
            :Name (London_Gateway)
            :Table (network_objects)
            :Uid ("{1C2D9FFC-F412-49B3-85A1-43470D8B4580}")
        )                                                                                                                                                                                                                                
    )
) 
```

```json
{
 "All_Intranet_Gateways": {
  "AdminInfo": {
   "ClassName": "network_object_group",
   "table": "network_objects"
  },
  "ReferenceObject": [
   {
    "Name": "Berlin_Gateway",
    "Table": "network_objects",
    "Uid": "{8AA12D62-B698-4B3B-8A0B-A4CE13A64CAC}"
   },
   {
    "Name": "London_Gateway",
    "Table": "network_objects",
    "Uid": "{1C2D9FFC-F412-49B3-85A1-43470D8B4580}"
   }
  ]
 }
}
```



