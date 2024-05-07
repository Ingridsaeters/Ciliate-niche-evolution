from ete3 import Tree

# Load the tree from a file
tree = Tree("path/to/treefile")

# Initialize counters
total_nodes = 0
nodes_over_50 = 0

# Traverse the tree and count nodes
for node in tree.traverse():
    total_nodes += 1
    if node.support is not None and node.support > 50:
        nodes_over_50 += 1

print("Total number of nodes:", total_nodes)
print("Number of nodes with support over 50%:", nodes_over_50)
