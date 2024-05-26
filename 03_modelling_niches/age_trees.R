###############################################################################
#                            Rscript Age trees                                #
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
library(dispRity)
library(phytools)
library(stringr)

setwd()

# List tree names 
trees <- list.files("path/to/tree_folder")

# Make an empty tibble to store results
results <- tibble()

# Extract ages
for (tree_file in trees) {
  tree_path <- file.path("path/to/tree_folder", tree_file)
  tree <- read.tree(tree_path)
  tree_name <- basename(tree_file)
  
  ages <- tree.age(tree)
  age_root <- max(ages$ages)
  
  df <- tibble(
    tree = tree_name, 
    age = age_root
  )
  # Write results to a file
  results <- bind_rows(results, df)
  write.csv(results, "name_of_file.csv")
  
}
