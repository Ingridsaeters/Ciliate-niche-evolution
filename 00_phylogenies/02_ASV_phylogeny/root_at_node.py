#!/usr/bin/python

## Mahwash Jamy
## Oct 2020

## This script roots a tree at a specified node. The node is specified as the ancestor of two tips 

## Usage: python root_at_node.py [tree newick file] [list of taxa] [output file] 

from ete3 import Tree
import sys

IN=sys.argv[1]
NAMES=sys.argv[2]

# read tree
t = Tree( IN )

# Set random tip as root to circumvent the "cannot set myself as outgroup" error, 
# following https://groups.google.com/g/etetoolkit/c/ls1sa6BT3CQ

t.set_outgroup("MK507765_Eukaryota|Diaphoretickes|Sar|Alveolata|Ciliophora|Postciliodesmatophora|Karyorelictea|core-Kary|Loxodida|Loxodidae|g_Loxodes|Loxodes+rex|strain=FL1")

# Get the node/subtree that contains both the specified leaves
with open(NAMES) as f:
    TIPS = f.read().splitlines()

ancestor = t.get_common_ancestor(TIPS)

t.set_outgroup(ancestor)

OUT=sys.argv[3]

# write sub-tree. Formtat 5 indicates that you want internal and leaf branches + leaf names
t.write(format=5, outfile=OUT)
