#!/usr/bin/python

## Mahwash Jamy
## Nov 2023

## This script takes a list of taxa and retains those tips in the tree, while dropping all others. 

## Usage: python prune.py [tree newick file] [list of taxa] [output file] 

from ete3 import Tree
import sys

IN=sys.argv[1]
NAMES=sys.argv[2]
OUT=sys.argv[3]

# read tree
t = Tree( IN )

# read user supplied tip labels
with open(NAMES) as f:
    TIPS = f.read().splitlines()

## prune the tree to remove everything else
t.prune(TIPS, preserve_branch_length=True)

# write sub-tree. Format 5 indicates that you want internal and leaf branches + leaf names
t.write(format=5, outfile=OUT)
