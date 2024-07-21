###############################################################################
#                         Rscript Model comparison PC                         #
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
## Load packages
library(devtools)
library(RPANDA)
library(phytools)
library(tidyverse)
library(readr)

## Set working directory
setwd()

# Read trees and data ----
#_________________________
## List trees
trees <- list.files("/path/to/tree/folder")

## List files with PC scores
traits <- list.files("/path/to/PC/folder")

# List files with measurement errors (see proceedure from Drury et al. 2018 to calculate measurement errors for PC scores)
mes <- list.files("/path/to/me/folder")

# Perform model test ----
#________________________
## Make an empty tibble to store results
results_df<-tibble()

## Make a loop though the first tree file in the tree folder, the first PC file in the PC folder and first me file in me folder. 
## Then repeat for the second and so on.
for (i in seq_along(trees)) {
  tree_path <- file.path("/path/to/tree/folder", trees[[i]])
  tree <- read.tree(tree_path)
  tree_filename<- basename(trees[[i]])
  tip_labels<- tree$tip.label
  
  # Read me file
  me <- read.csv(file.path("/path/to/me/folder", mes[[i]]), sep = ",")
  colnames(me)[1]<-"ASV"
  colnames(me)[2]<-"me_values"
  
  # Order me file by order in tree
  me_reordered <- me[match(tip_labels, me$ASV), ,drop = FALSE]

  # Make a named vector with me
  me_vector <- me_reordered$me_values
  names(me_vector) <- tip_labels

 # Read PC file
trait <- read.csv(file.path("/path/to/PC/folder", traits[[i]]), sep = "\t")

# Order by order in tree
trait_reordered <- trait[match(tip_labels, rownames(trait)), , drop = FALSE]
colnames(trait_reordered)[1]<- "pc"

# Make a named vector
vector <- trait_reordered$pc
names(vector) <- rownames(trait_reordered)

# Perform model analysis (Here exemplified with BM. Change to OU and EB for analysis with these model)
BM.fit <- fit_t_standard(tree, vector, model = "BM", error = me_vector)

# Extract output
LH <- BM.fit$logl
aic <- BM.fit$aic
aicc <- BM.fit$aicc
free_parameters <- BM.fit$nb_param
sig2 <- BM.fit$param[1]
theta <- BM.fit$theta

# Make a tibble with results
trait_results <- tibble(
tree<-tree_filename,
LH = LH,
aic = aic,
aicc = aicc,
free_parameters = free_parameters,
sig2 = sig2,
theta = theta)

# Write a file with results
results_df <- bind_rows(results_df,trait_results)
write.csv(results_df, "name_of_file.csv")
}
