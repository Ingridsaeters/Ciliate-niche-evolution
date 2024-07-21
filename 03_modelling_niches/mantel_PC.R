###############################################################################
#                               Rscript Mantel test PC                        #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution
# EDGE group, Natural history museum, University of Oslo
# 17.03.2024
# Version 1
# R v. 4.2.2
#=================#

# Setup ----
#___________
## Load libraries
library(ape)
library(ecodist)
library(readr)
library(adephylo)

## Set working directory
setwd()

# Read trees and data ----
#_________________________
## List tree files
trees <- list.files("/path/to/tree/folder")

## List PC files
traits <- list.files("/path/to/PC/folder")

# Perform mantel test 
#_____________________
## Make an empty list to store results
results<-list()

## Make a loop through the first tree file in the tree folder and the first PC file in the PC folder. Then repeat for the second and so on. 
for (i in seq_along(trees)) {
  # Read tree
  tree_path <- file.path(tree_directory, trees[[i]])
  tree<-read.tree(tree_path)
  
  # Make a distance object
  dist_phylo<-distTips(tree)
  tip_labels<-tree$tip.label
  
  # Extract tree name from file path
  tree_name <- basename(trees[[i]])
  
  # Read trait data (PC scores)
  trait<-read.csv(file.path("/path/to/PC/folder", traits[[i]]), sep = "\t")
 
  # Reorder by order in tree
  trait_reordered<-trait[match(tip_labels, rownames(trait)), , drop = FALSE]
  
  # Make a distance object  
  dist <- distance(trait_reordered, method = "euclidean")
  
  # Perform a mantel test with 1000 permutations
  mantel<-ecodist::mantel(dist_phylo ~ dist, nperm = 1000)
                    
# Store results
result_name <- paste(tree_name)
mantelr<-mantel[1]
pval1<-mantel[2]
pval2<-mantel[3]
pval3<-mantel[4]
llim<-mantel[5]
ulim<-mantel[6]
                    
results[[result_name]]<-list(Mantel_r = mantelr, pval1 = pval1, pval2 = pval2, pval3=pval3, llim = llim, ulim = ulim)

# Combine results into a data frame
results_df <- do.call(rbind.data.frame, results)

# Write results to a CSV file
write.csv(results_df, "name_of_file.csv", row.names = TRUE)
}
