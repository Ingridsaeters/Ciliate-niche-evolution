###############################################################################
#                      		Rscript Mantel test    		              #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 17.03.2024
# Version 1
#=================#


# Load libraries
library(ape)
library(tidyverse)
library(vegan)
library(phytools)
library(philentropy)

# Function to perform Mantel test
perform_mantel_test <- function(data_file, trait_column, phylo_tree, permutations = 999) {
  # Load data
  data <- read_tsv(data_file)
  
  # Extract ASV and trait column
  data_trait <- data %>%
    dplyr::select("ASV", {{trait_column}})
  data_trait <- data.frame(data_trait)
  data_trait <- data_trait[-1]
  row.names(data_trait) <- data$ASV
  
  # Compute distance matrix
  dist_trait <- distance(data_trait, method = "euclidean")
  row.names(dist_trait) <- data$ASV
  colnames(dist_trait) <- as.character(unlist(data[1]))
  
  # Match the order in the phylogenetic tree
  dist_phylo_reordered <- phylo_tree[match(rownames(dist_trait), rownames(phylo_tree)), 
                                      match(colnames(dist_trait), colnames(phylo_tree))]
  
  # Perform Mantel test
  mantel_result <- mantel(xdis = dist_phylo_reordered, ydis = dist_trait, 
                          method = "spearman", permutations = permutations, na.rm = TRUE)
  
  return(mantel_result)
}

# Define paths
tree_path <- "/path/to/treefile1", 
	"/path/to/treefile2")
data_file <- "data.tsv"

# Read phylogenetic tree
tree <- read.newick(tree_path)

# Perform Mantel tests for different traits
trait1_mantel <- perform_mantel_test(data_file, "trait1", tree)
trait2_mantel <- perform_mantel_test(data_file, "trait2", tree)
trait3_mantel <- perform_mantel_test(data_file, "trait3", tree)

# Print results
print(trait1_mantel)
print(trait2_mantel)
print(trait3_mantel)
