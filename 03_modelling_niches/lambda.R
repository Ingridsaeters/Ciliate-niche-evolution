###############################################################################
#                   Rscript Blombergs K and Pagels lambda                     #
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
library(ape)
library(tidyverse)
library(picante)
library(vegan)
library(motmot)


# Read trees ----
#________________

trees<-list("/path/to/treefile1", 
	   "/path/to/treefile2",
	  "etc"
	 )
# Read data ----
#_______________
trait_data_file <- "data.tsv"
trait_data <- read_tsv(trait_data_file)

# Loop over traits
results <- list()
for (trait in c("trait1", "trait2", "etc")) {
  # Loop over trees
  for (tree_file in trees) {
    # Read tree
    tree <- read.tree(tree_file)
    
    # Extract tree name from file path
    tree_name <- basename(tree_file)
    
    # Read trait data
    trait_column <- trait_data[[trait]]
    df <- data.frame(ASV = trait_data$ASV, trait = trait_column)
    
    tip_labels <- tree$tip.label
    
    # Create dataframe with rownames
    rownames_df <- trimws(df$ASV)
    
    # Turn data into matrix, ordered by tip labels in the tree
    df_ordered <- df[match(tip_labels, rownames_df), , drop = FALSE]
    df_ordered <- as.matrix(df_ordered[, -1])
    rownames(df_ordered) <- tip_labels
    
    # Calculate Pagels lambda
    lambda.ml <- transformPhylo.ML(phy = tree, y = df_ordered, model = "lambda")
    
    # Store results
    result_name <- paste(tree_name, trait, sep = "_")
    lambda_values <- ifelse(length(lambda.ml$lambda) > 1, paste(lambda.ml$lambda, collapse = ","), lambda.ml$Lambda)
    
    results[[result_name]] <- list(Pagels_Lambda = lambda_values)  
  }
}

# Combine results into a data frame
results_df <- do.call(rbind.data.frame, results)

# Write results to a CSV file
write.csv(results_df, "results.csv", row.names = TRUE)
