###############################################################################
#                       Rscript RPANDA Niche Evolution                        #
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


# Define a function to fit models and extract statistics
fit_and_extract <- function(tree_file, trait, sem) {
  tree <- read.newick(tree_file)
  BM.fit <- fit_t_standard(tree, trait, model = "BM", error = sem) 
  OU.fit <- fit_t_standard(tree, trait, model = "OU", error = sem) 
  EB.fit <- fit_t_standard(tree, trait, model = "EB", error = sem) 
  
  BM <- c(BM.fit$logl, BM.fit$aic, BM.fit$theta)
  OU <- c(OU.fit$logl, OU.fit$aic, OU.fit$theta)
  EB <- c(EB.fit$logl, EB.fit$aic, EB.fit$theta)
  
  return(data.frame(BM = BM, OU = OU, EB = EB))
}



# Define paths to tree files
tree_files <- list(
  "/path/to/treefile", 
  "/path/to/treefile", 
  "etc"
)

# Prepare the data ----
#______________________
## Load the traits dataset
data <- read_tsv("data.tsv")

# Prepare data for multiple traits
traits <- c("trait1", "trait2", "trait3", "osv")

results <- list()  # Create an empty list to store results

# Loop through each trait
for (trait in traits) {
  
# Calculate standard error for this trait
  sem_name <- paste0("sem_", trait)
  data[[sem_name]] <- data[[paste0(trait, "_sd")]] / sqrt(data$N)
  
  # Set error to NA for ASVs that appear just once
  data[[sem_name]] <- ifelse(data$N == 1, NA, data[[sem_name]])
  
  # Give the values corresponding ASV names
  sem <- setNames(data[[sem_name]], data$ASV)
  trait_data <- setNames(data[[trait]], data$ASV)
  
  # Create an empty list to store results for this trait
  trait_results <- list()
  
  # Loop through tree files
  for (tree_file in tree_files) {
    # Fit models and extract statistics for this trait and tree
    stats <- fit_and_extract(tree_file, trait_data, sem)
    
    # Write tree name
    tree_filename <- basename(tree_file)
    
   # Set rownames to "logl", "AIC", and "theta"
    rownames(stats) <- c("logl", "AIC", "theta")

    # Store statistics in the results list for this trait
    trait_results[[tree_filename]] <- stats
  }
  
  # Store the results for this trait in the main results list
  results[[trait]] <- trait_results
}

# Combine results for all traits into a single data frame
combined_results <- lapply(results, function(trait_results) {
  do.call(rbind, trait_results)
})

# Write combined results to separate files for each trait
for (i in seq_along(traits)) {
  
# Convert rownames to a column
  combined_results_converted <- cbind(rowname = rownames(combined_results[[i]]), combined_results[[i]])
 
# Write to TSV file
  write_tsv(combined_results_converted, paste0(traits[i], "_.tsv"))
}
