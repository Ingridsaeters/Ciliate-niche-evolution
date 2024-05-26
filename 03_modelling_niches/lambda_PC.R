###############################################################################
#                           Rscript Pagels lambda PC                          #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution
# EDGE group, Natural history museum, University of Oslo
# 26.05.2024
# Version 1
#=================#

library(caper)
library(tidyverse)
library(geiger)
library(phytools)
library(ape)

## Set working directory
setwd()

# Read trees and data ----
#________________
## Assign trees
trees <- list.files("/path/to/treefiles")

## Read data
### PC scores
PCfiles<-list.files("/path/to/PC_files")

### Measurement error files (Proceedure from Drury et al. 2018 to calculate measurement errors for PC scores)
mefiles<-list.files("/path/to/me_files")

# Calculate Pagel's lambda and probability that lambda is significantly different from 0 ----
#____________________________________________________________________________________________
## Make an empty tibble to store results
results_df<-tibble()

## Calculate lambda by using the first tree file in the tree folder, the first PC file in the PC folder and first me file in me folder. Then the second and so on
for(i in seq_along(trees))  {
  # Read tree
  tree_path<-file.path("/Users/ingri/OneDrive/Dokumenter/ciliate_niche/analyses/Analyses/dating/marine_pruned", trees[[i]])
  tree<-read.newick(tree_path)
  tree_name<-basename(trees[[i]])
  tip_labels<-tree$tip.label
  
  # Read data 
    data_path<-file.path("/Users/ingri/OneDrive/Dokumenter/ciliate_niche/analyses/Analyses/modelling/pPCA/pc5_scores_marine", PCfiles[[i]])
    PC <-read.csv(data_path, sep = "\t")
  
    # Read me file
    me_path<-file.path("/Users/ingri/OneDrive/Dokumenter/ciliate_niche/analyses/Analyses/modelling/pPCA/me_marine", mefiles[[i]])
    me<-read.csv(me_path, sep=",")
    rownames(me)<-me$ASV
    me_reordered<-me[match(rownames(PC1), rownames(me)), , drop=FALSE]
    me_reordered<-me_reordered[-1]
    me_reordered<-me_reordered[-1]
    
    # Calculate Pagel's lambda
    test<-fitContinuous(tree, PC, SE = me_reordered, model = "lambda")
    
    # Create an empty list to store results for this trait
    lambda<-test$opt$lambda
    sigsq<-test$opt$sigsq
    logL<-test$opt$lnL
    aic<-test$opt$aic
    
    # Test if lambda is significantly different from 0 by comparing with white noise model
    wn <- fitContinuous(tree, PC1, SE = me_reordered, model = "white")
    logL_wn <- wn$opt$lnL

    # conduct hypothesis test using chi-square
    LR<-2*(test$opt$lnL-logL_wn)
    
    P<-pchisq(LR,df=1,lower.tail=F)
    
    # Print p-value
    print(paste("P-value:", P))
    
    # Store results in a tibble
    trait_results <- tibble(
      tree = tree_name, 
      lambda = lambda,
      sigsq = sigsq,
      logL = logL,
      aic = aic, 
      P = P)
    
    # Write a file with the results
    results_df <- bind_rows(results_df,trait_results)
    write.csv(results_df, "name_of_result_file.csv")
  }

