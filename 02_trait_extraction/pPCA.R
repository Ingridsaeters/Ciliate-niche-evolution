###############################################################################
#                         Rscript pPCA Niche Evolution                        #
###############################################################################

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

# Read tree ----
#_______________
tree<-readNewick("name_of_tree_file.nwk", convert.edge.length = TRUE)
plot(tree)

# Read data ----
#_______________
data<-read.table("name_of_traits_file.tsv", header = TRUE, sep = "\t")
data<-data[-2] #Taxon is not a variable to be included in PCA analysis
row.names(data)<-data$ASV
data<-data[-1]

# Combine tree and data ----
#___________________________
combine_tree_data <- phylobase::phylo4d(tree, data)

# Perform phylogenetic PCA ----
#______________________________
pca <- adephylo::ppca(combine_tree_data, scale = FALSE, scannf = FALSE, nfposi = 2, method = "Abouheif") 
### This takes a while....
print(pca)

# Extract PCA scores ----
#________________________
pca_scores<-pca$li
pca_scores["ASV"]<-row.names(pca_scores)
row.names(pca_scores)<-NULL

# Write file ----
#________________
write_tsv(pca_scores, "name_of_output_file.tsv")



