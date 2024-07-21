###############################################################################
#                                    Rscript pPCA                             #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 22.02.2024
# R v. 4.2.2
# Version 1
#=================#

# Setup ----
#___________

## Load packages
library(phytools)
library(phylobase)
library(adephylo)
library(fs)
library(utils)
library(tidyverse)
library(readr)

## Set working directory
setwd("C:/Users/path/to/directory")

# List tree files ----
#_____________________
trees<-list.files("/path/to/tree/folder")

# Read data ----
#_______________
data<-read_tsv()
### Make sure rownames of data is ASVs

## Subset into groups if needed
data_subset <- data %>% 
  dplyr::select("trait1", "trait2", "trait3", "etc")


# Perform pPCA ----
#__________________
## Make empty tibbles to store results
df <- tibble()
results_df <- tibble()

## Loop through all trees, perform pPCA and extract PC scores and percent variation
for (tree_file in trees) {
  # Read tree file
  tree_path <- path("/path/to/tree/folder", tree_file)
  tree<-read.newick(tree_path)
  tree_name<-basename(tree_file)
  tip_labels<-tree$tip.label

  # Reorder data so it is in the same order as the tree file
  data_reordered<-data[match(tip_labels, rownames(data)), , drop = FALSE]
  data_reordered<-as.matrix(data_reordered)
  
  # Perform phylogenetic PCA 
  pca <- phyl.pca(tree, data_reordered, method = "BM", mode = "cov") 
 
  # Percent of variation explained by the first five PC axes
  pc1<-pca$Eval[,1]/sum(pca$Eval)
  pc2<-pca$Eval[,2]/sum(pca$Eval)
  pc3 <- pca$Eval[,3]/sum(pca$Eval)
  pc4 <- pca$Eval[,4]/sum(pca$Eval)
  pc5 <- pca$Eval[,5]/sum(pca$Eval)
  pc1<-as.numeric(pc1[1])
  pc2<-as.numeric(pc2[2])
  pc3 <- as.numeric(pc3[3])
  pc4 <- as.numeric(pc4[4])
  pc5 <- as.numeric(pc5[5])
  
  # Store the results of percent variation in a tibble
  df <- tibble(
    tree = tree_name, 
    pc1 = pc1, 
    pc2 = pc2,
    pc3 = pc3, 
    pc4 = pc4, 
    pc5 = pc5
  )
  # Write out a file with percent variation
  results_df <- dplyr::bind_rows(results_df, df)
  write.csv(results_df, "name_of_file.csv")
  
  # Get PCA scores
  pca_scores<-data.frame(pca$S)
  
  # Write file with PC1 scores
  pc1_scores<- data.frame(pca_scores$PC1)
  colnames(pc1_scores)[1]<-tree_name
  rownames(pc1_scores)<-rownames(pca_scores)
  # Save PC1 scores to file
  write.table(pc1_scores, file = paste0("pc1_scores_", tree_name, ".tsv"), sep = "\t", row.names = TRUE, col.names = TRUE)

  # Write file with PC2 scores
  pc2_scores<- data.frame(pca_scores$PC2)
  colnames(pc2_scores)[1]<-tree_name
  rownames(pc2_scores)<-rownames(pca_scores)
  # Save PC2 scores to file
  write.table(pc2_scores, file = paste0("pc2_scores_", tree_name, ".tsv"), sep = "\t", row.names = TRUE, col.names = TRUE)

  # Write file with PC3 scores
  pc3_scores<- data.frame(pca_scores$PC3)
  colnames(pc3_scores)[1]<-tree_name
  rownames(pc3_scores)<-rownames(pca_scores)
  # Save PC3 scores to file
  write.table(pc3_scores, file = paste0("pc3_scores_", tree_name, ".tsv"), sep = "\t", row.names = TRUE, col.names = TRUE)
  
  # Write file with PC4 scores
  pc4_scores<- data.frame(pca_scores$PC4)
  colnames(pc4_scores)[1]<-tree_name
  rownames(pc4_scores)<-rownames(pca_scores)
  # Save PC4 scores to file
  write.table(pc4_scores, file = paste0("pc4_scores_", tree_name, ".tsv"), sep = "\t", row.names = TRUE, col.names = TRUE)
  
  # Write file with PC5 scores
  pc5_scores<- data.frame(pca_scores$PC5)
  colnames(pc5_scores)[1]<-tree_name
  rownames(pc5_scores)<-rownames(pca_scores)
  # Save PC5 scores to file
  write.table(pc5_scores, file = paste0("pc5_scores_", tree_name, ".tsv"), sep = "\t", row.names = TRUE, col.names = TRUE)
  
}
