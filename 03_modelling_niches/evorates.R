###############################################################################
#                             Rscript Evorates                                #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 22.02.2024
# Version 1
#=================#

# Setup ----
#___________

## Load packages
library(devtools)
library(evorates)
library(tidyverse)
library(phytools)
library(magrittr)
library(plyr)
library(dplyr)
library(sf)

## Set working directory
setwd()


# Read tree ----
#_______________
tree<-read.tree("treefile")
tip_labels<-tree$tip.label

# Read data ----
#_______________
# Data needs to be in format with ASVs as rows and traits as columns. 
# Remove rows with NA
data<-read_tsv("datafile.tsv") 

## Order data by order in tree
data_ordered<-data[match(tip_labels, data$ASV), , drop = FALSE]

# Make a named vector with temperature values
temp_vector<-data_ordered$temperature
names(temp_vector) <- tip_labels

# Fit evolving rates model ----
#______________________________
temp_fit <- fit.evorates(tree, temp_vector, trait.se = NULL, out.file = "name_of_output", cores = number_of_cores, iter = 10000)

# Check if chains have mixed properly
check.mix(temp_fit, printlen = 6)
check.ess(temp_fit, printlen = 6)
get.sd(temp_fit) 

# Remove trend
remove.trend(temp_fit)

# Combine chains
combine.chains(temp_fit)

# Save as RDS file
saveRDS(temp_fit, "name_of_file")

# Plot temperature for tree
plot(temp_fit, style = "phylogram", remove.trend = TRUE)

