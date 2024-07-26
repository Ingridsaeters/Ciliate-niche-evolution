#######################
#     Scale tree      # 
#######################
library(phytools)

# Set working directory
setwd("~/Documents/OneDrive/Postdoc/Projects/Ciliate-niche-evolution/00_phylogenies/03_macrobes_phylogenies/")

# Read your tree from a Newick file
tree <- read.tree("p19.tre")

# How many tips in the tree?
k <- length(tree$tip.label)
k

# Get age of MRCA
tot_time <- max(node.depth.edgelength(tree))
tot_time

# Define function to scale tree
## From http://blog.phytools.org/2012/02/quicker-way-to-rescale-total-length-of.html
rescaleTree<-function(tree,scale){
  tree$edge.length <- tree$edge.length/max(nodeHeights(tree)[,2])*scale
  return(tree)
}

# Define scale
scale <- tot_time/10

# Scale tree
tree2 <- rescaleTree(tree, scale)

# Check age of tree2
max(node.depth.edgelength(tree2))

# Save the scaled tree
write.tree(tree2, file="p19.scaled.10.tre")

