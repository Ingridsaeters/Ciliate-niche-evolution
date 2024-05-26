###############################################################################
#                         Rscript Model comparison PC                         #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution
# EDGE group, Natural history museum, University of Oslo
# 17.03.2024
# Version 1
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
## Read trees
trees <- list.files("/path/to/treefile_folder")

## Read files with PC scores
traits <- list.files("/path/to/PCfiles_folder")

# Read files with measurement errors (Proceedure from Drury et al. 2018 to calculate measurement errors for PC scores)
sems <- list.files("/path/to/me_files")

# Perform model test ----
#________________________
## Make an empty tibble to store results
results_df<-tibble()

# Perform model test by using the first tree file in the tree folder, the first PC file in the PC folder and first me file in me folder. Then the second and so on
for (i in seq_along(trees)) {
  tree_path <- file.path(tree_directory, trees[[i]])
  tree <- read.tree(tree_path)
  tree_filename<- basename(trees[[i]])
  tip_labels<- tree$tip.label
  
  # Read me file
  sem <- read.csv(file.path("/path/to/me_files", sems[[i]]), sep = ",")
  colnames(sem)[1]<-"ASV"
  colnames(sem)[2]<-"pc_values"
  
  # Order me file by order in tree
  sem_reordered <- sem[match(tip_labels, sem$ASV), ,drop = FALSE]

  # Make a named vector with sem
  sem_vector <- sem_reordered$pc_values
 names(sem_vector) <- tip_labels

 # Read PC file
trait <- read.csv(file.path("/path/to/PCfiles_folder", traits[[i]]), sep = "\t")

# Order by order in tree
trait_reordered <- trait[match(tip_labels, rownames(trait)), , drop = FALSE]
colnames(trait_reordered)[1]<- "pc"

# Make a named vector
vector <- trait_reordered$pc
names(vector) <- rownames(trait_reordered)

# Perform model analysis (Here exemplified with BM. Change to OU and EB if you wish to use these model)
BM.fit <- fit_t_standard(tree, vector, model = "BM", error = sem_vector)
                              
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

