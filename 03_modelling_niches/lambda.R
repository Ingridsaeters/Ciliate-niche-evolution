###############################################################################
#                   	    Rscript Pagels lambda 	                      #
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
library(ape)
library(tidyverse)
library(picante)
library(vegan)
library(motmot)
library(phytools)
library(geiger)

## Set working directory
setwd()

# Read trees and data ----
#________________
## List treefiles
trees <- list.files("/path/to/tree/folder")

## Read data
trait_data <- read_tsv("trait_data.tsv")
### Make sure you have one column with values for the trait, and one column with sd (with trait name and suffix _sd), and one column with the number of samples the ASV has been found in (N). 

## Assign traits for analysis
traits<-c("trait1", "trait2", "trait3", "etc")

# Calculate Pagel's lambda and probability that lambda is significantly different from 0 ----
#____________________________________________________________________________________________
## Make an empty tibble to store results
results_df<-tibble()

## Loop through trees and traits to calculate Pagel's lambda for each tree and trait combination
# Loop through each tree
for (tree_file in trees) {
  tree<-read.newick(file.path("/path/to/tree/folder", tree_file))
  tip_labels<-tree$tip.label
  tree_name <- basename(tree_file)

  # Loop through each trait
  for (trait in traits) {
    row_names<-trait_data$ASV
    # Order trait data in the same order as the tree
    trait_data_ordered<-trait_data[match(tip_labels, row_names), , drop = FALSE]
    
    # Calculate standard error of mean for this trait by dividing sd by the square root of number of samples ASV is found in (N)
    sem_name <- paste0("sem_", trait)
    trait_data_ordered[[sem_name]] <- trait_data_ordered[[paste0(trait, "_sd")]] / sqrt(trait_data_ordered$N)
    
    # Set error to 0 for ASVs that appear just once
    trait_data_ordered[[sem_name]] <- ifelse(trait_data_ordered$N == 1, 0, trait_data_ordered[[sem_name]])
    
    # Convert sem to named vector
    sem <- as.vector(trait_data_ordered[[sem_name]])
    names(sem)<-trait_data_ordered$ASV
    
    # Convert trait column to named vector
    trait_column<-trait_data_ordered[[trait]]
    vector <- as.vector(trait_data_ordered[[trait]])
    names(vector)<-trait_data_ordered$ASV

    # Perform test of Pagel's lambda
    test <-fitContinuous(tree, vector, SE = sem, model = "lambda")
    
    # Store results for this trait
    lambda<-test$opt$lambda
    sigsq<-test$opt$sigsq
    logL<-test$opt$lnL
    aic<-test$opt$aic
    
    # Test if lambda is significantly different from 0 by comparing with white noise model
    wn <- fitContinuous(tree, vector, SE = sem, model = "white")
    logL_wn <- wn$opt$lnL

    # Conduct hypothesis test using chi-square
    LR<-2*(test$opt$lnL-logL_wn)
    P<-pchisq(LR,df=1,lower.tail=F)
    
    # Print p-value
    print(paste("P-value:", P))
    
    # Make a tibble with results
    trait_results <- tibble(
    tree = tree_name, 
    trait = trait,
    lambda = lambda,
    sigsq = sigsq,
    logL = logL,
    aic = aic, 
    P = P)

    # Write file with results
    results_df <- bind_rows(results_df,trait_results)
    write.csv(results_df, "marine/geiger_marine_p_values_clades.csv")
  }
}

