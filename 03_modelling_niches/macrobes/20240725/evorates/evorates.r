#!/usr/bin/env Rscript

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

## Scan arguments
args = commandArgs(trailingOnly=TRUE)

## Specify paths
.libPaths("/cluster/projects/nn8118k/mahwash/bin/R")

## Load packages
library(evorates)
library(tidyverse)
library(phytools)
library(magrittr)

log <- file(args[1])
sink(log, append=TRUE)
sink(log, append=TRUE, type="message")



# Read tree and data ----
#________________________
## Tree
tree<-read.tree(args[2])
tip_labels<-tree$tip.label

## Data
### Data needs to be in format with ASVs as rows and traits as columns. 
### Remove rows with NA
data<-read_tsv(args[3]) 
rownames_data<-trimws(data$Species)

## Order data by order in tree
data_ordered<-data[match(tip_labels, data$Species), , drop = FALSE]

## Make a named vector with temperature values
temp_vector<-data_ordered$Bio1.mean
names(temp_vector) <- tip_labels


# Make a vector with se values ----
#__________________________________
data_ordered["sem"]<-data_ordered$Bio1.sd/sqrt(data_ordered$n)
data_ordered$sem<-ifelse(data_ordered$n ==1, 0, data_ordered$sem)
temp_se_vector<-data_ordered$sem
names(temp_se_vector) <- tip_labels


# Fit evolving rates model ----
#______________________________
temp_fit <- fit.evorates(tree, 
                         temp_vector, 
                         trait.se = temp_se_vector,
                         out.file = args[4],
                         cores = 4,
                         iter = 6000)

## Check if chains have mixed properly
check.mix(temp_fit, printlen = 6)

## Check whether chains adequatly sampled the posterior distribution
check.ess(temp_fit, printlen = 6)

## Calculate Savey-Dickey ratio (ratio of posterior to prior density). 
## The lower ratio, the more evidence for rate heterogeniety. 
get.sd(temp_fit) 

## Combine chains
combine.chains(temp_fit)

## Plot temperature evolution
pdf(args[5])
plot(temp_fit, style = "phylogram", remove.trend = TRUE)
dev.off()

## Get background rate parameters
get.bg.rate(temp_fit, type = "mean", remove.trend = "TRUE")

## Save as RDS file
saveRDS(temp_fit, args[6])
