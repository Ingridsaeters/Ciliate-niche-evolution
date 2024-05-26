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
library(ecodist)
library(readr)
library(adephylo)

## Set working directory
setwd()

# Read trees and data ----
#________________
## List tree files
trees <- list.files("/path/to/tree/folder")

## Read data
trait_data <- read_tsv("trait_data.tsv")

## Assign traits for analysis
traits<-c("trait1", "trait2", "trait3", "etc")

# Perform mantel test ----
#_________________________
# Loop through trees
for (tree_file in trees) {
  # Read tree
  tree_path <- file.path("/path/to/tree/folder", tree_file)
  tree<-read.tree(tree_path)

  # Make a distance object
  dist_phylo<-distTips(tree)
  tip_labels<-tree$tip.label

  # Extract tree name from file path
  tree_name <- basename(tree_file)

  # Loop through traits
  for (trait in traits) {
    
    # read trait data
    trait_column<-trait_data[[trait]]
    df<-data.frame(ASV = trait_data$ASV, trait = trait_column)
    rownames_df<-trimws(df$ASV)
    df_reordered<-df[match(tip_labels, rownames_df), , drop = FALSE]
    df_final<-df_reordered[-1]
    rownames(df_final)<-df_reordered$ASV
    
    # Make a distance object
    dist <- distance(df_final, method = "euclidean")

    # Perform mantel test with 1000 permutations
    mantel<-ecodist::mantel(dist_phylo ~ dist, nperm = 1000)

    # Store results
    result_name <- paste(tree_name, trait, sep = "_")
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
}

