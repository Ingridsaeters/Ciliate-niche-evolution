###############################################################################
#                            Rscript Age trees                                #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 26.05.2023
# Version 1
#=================#

# Setup ----
#___________
## Load packages
library(dispRity)
library(phytools)
library(stringr)

## Set working directory
setwd()

# List tree names ----
#_____________________
trees <- list.files("path/to/tree/folder")

# Extract age of trees ----
#__________________________
## Make an empty tibble to store results
results <- tibble()

## Loop through trees and extract ages
for (tree_file in trees) {
  tree_path <- file.path("path/to/tree/folder", tree_file)
  tree <- read.tree(tree_path)
  tree_name <- basename(tree_file)
  
  ages <- tree.age(tree)
  age_root <- max(ages$ages)

  # Make a dataframe with results
  df <- tibble(
    tree = tree_name, 
    age = age_root
  )
  # Write results to a file
  results <- bind_rows(results, df)
  write.csv(results, "name_of_file.csv")
  
}
