###############################################################################
#                                Rscript ddEXP                                #
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
## List tree files
trees <- list.files("/path/to/tree/folder")

## Read data
data <- read_tsv(data_file.tsv)

## Assign traits for analysis
traits <- c("trait1", "trait2", "trait3", "etc")

# Perform model analysis ----
#____________________________
## Make an empty tibble to store results
results_df<-tibble()

# Loop through trees
for (tree_file in trees) {
  # Read tree
  tree <- read.newick(file.path("/path/to/tree/folder", tree_file))
  # Some trees are not strictly ultrametric, which causes problems. Force the trees to be ultrametric. 
  tree <- force.ultrametric(tree, method = "extend")
  tree_filename <- basename(tree_file)
  tip_labels <- tree$tip.label

  # Order data in the same order as tree
  data_tree <- data[match(tip_labels, rownames(data)), , drop = FALSE]
  data_tree["ASV"] <- tip_labels

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

    # Fit model
    LB.fit <- fit_t_comp(tree, vector, model = "DDexp", error = sem) 
    
    # Extract model parameters
    LH <- LB.fit$logl
    aic <- LB.fit$aic
    aicc <- LB.fit$aicc
    free_parameters <- LB.fit$free_parameters
    sig2 <- LB.fit$sig2
    r <- LB.fit$r
    z0 <- LB.fit$z0
    
    # Create tibble with results
    trait_results <- tibble(
      tree = tree_filename,
      trait = trait,
      LH = LH,
      aic = aic,
      aicc = aicc,
      free_parameters = free_parameters,
      sig2 = sig2,
      r = r,
      z0 = z0
    )
    
    # Make a dataframe with results
    results_df <- bind_rows(results_df, trait_results)
  }
}

# Write results to CSV
write.csv(results_df, "name_of_file.csv", row.names = FALSE)


