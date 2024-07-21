###############################################################################
#                              Rscript rates                                  #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution
# EDGE group, Natural history museum, University of Oslo
# 17.03.2024
# R v. 4.2.2
# Version 1
#=================#

# Setup ----
#___________

## Load packages
library(phytools)
library(RPANDA)
library(tidyverse)

## Set working directory
setwd()

# Read trees and data ----
#________________
## List tree files
trees <- list.files("/path/to/tree/folder")

## Read data
trait_data <- read_tsv("trait_data.tsv") # Normalized for comparisons among traits and non-normalized for calculations of rates per millions of years

## Assign traits for analysis
traits<-c("trait1", "trait2", "trait3", "etc")

# Perform rate analysis ----
#____________________________
## Make an empty tibble to store results
results_df<-tibble()

# Loop through trees
for (tree_file in trees) {
tree_path <- file.path("/path/to/tree/folder", tree_file)
tree <- read.tree(tree_path)
tree_filename<- basename(tree_file)
tip_labels<- tree$tip.label

# Change order of data so it is in the same order as the tree
data_tree <- data[match(tip_labels, rownames(data)), , drop = FALSE]
data_tree["ASV"]<-tip_labels

  # Loop through traits
  for (trait in traits) {

    # Calculate standard error of mean for the trait by dividing the sd by the square root of number of samples the ASV is found in (N)
    sem_name <- paste0("sem_", trait)
    data_tree[[sem_name]] <- data_tree[[paste0(trait, "_sd")]] / sqrt(data_tree$N)

    # Set error to NA for ASVs that appear just once
    data_tree[[sem_name]] <- ifelse(data_tree$N == 1, NA, data_tree[[sem_name]])

    # Make a named vector with sem
    sem <- setNames(data_tree[[sem_name]], data_tree$ASV)

    # Make a named vector with trait data
    vector<-data_tree[[trait]]
    names(vector)<- data_tree$ASV
    
    # Calculate rates under BM
    BM.fit <- fit_t_standard(tree, vector, model = "BM", error = sem) 
    
    LH <- BM.fit$logl
    aic <- BM.fit$aic
    aicc <- BM.fit$aicc
    free_parameters <- BM.fit$nb_param
    sig2 <- BM.fit$param[1]
    alpha <- BM.fit$param[2]
    theta <- BM.fit$theta

    # Make a tibble with results
    trait_results <- tibble(
      tree<-tree_filename, 
      trait<-trait,
      LH = LH, 
      aic = aic, 
      aicc = aicc, 
      free_parameters = free_parameters, 
      sig2 = sig2,
      alpha = alpha, 
      theta = theta)

    # Write file with results
    results_df <- bind_rows(results_df,trait_results)
    write.csv(results_df, "name_of_file.csv")
  }
  
}

