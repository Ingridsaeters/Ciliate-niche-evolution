###############################################################################
#                             Rscript Evorates                                #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 26.05.2024
# Version 1
# R v. 4.2.2
#=================#

# Setup ----
#___________

## Load packages
library(evorates)
library(tidyverse)
library(phytools)
library(magrittr)

## Set working directory
setwd()

# Read tree and data ----
#________________________
## Tree
tree<-read.tree("treefile")
tip_labels<-tree$tip.label

## Data
data<-read_tsv("datafile.tsv") 
### Data needs to be in format with ASVs as rows and traits as columns. 
### Remove rows with NA

## Order data by order in tree
data_ordered<-data[match(tip_labels, data$ASV), , drop = FALSE]

## Make a named vector with temperature values
temp_vector<-data_ordered$temperature
names(temp_vector) <- tip_labels

# Fit evolving rates model ----
#______________________________
temp_fit <- fit.evorates(tree, temp_vector, trait.se = NULL, out.file = "name_of_output", cores = number_of_cores, iter = 10000)

## Check if chains have mixed properly
check.mix(temp_fit, printlen = 6)

## Check whether chains adequatly sampled the posterior distribution
check.ess(temp_fit, printlen = 6)

## Calculate Savey-Dickey ratio (ratio of posterior to prior density). The lower ratio, the more evidence for rate heterogeniety. 
get.sd(temp_fit) 

## Combine chains
combine.chains(temp_fit)

## Plot temperature evolution
plot(temp_fit, style = "phylogram", remove.trend = TRUE)

## Save as RDS file
saveRDS(temp_fit, "name_of_file")
