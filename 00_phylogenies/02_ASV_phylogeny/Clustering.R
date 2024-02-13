###############################################################################
#                     Rscript Clustering Niche Evolution                      #
###############################################################################

# Setup ----
#___________
## Load packages
library(dplyr)
library(tidyr)
library(fastcluster)

## Set working directory
setwd("/Users/path/to/directory")

# Read in distance file ----
#___________________________
## Read file
rf_distances <- read.csv("RF.raxml.rfDistances", sep="\t", header = FALSE)

## Subset columns
rf_distances_subset <- subset(rf_distances, select = c(V1, V2, V3)) 

# Make distance matrix ----
#__________________________
## Turn the distance file into a data frame
rf_df <- data.frame(rf_distances_subset)

## Convert dataframe into wide format
rf_wide <- pivot_wider(rf_df, names_from = "V1", values_from = "V3")
rf_wide <- rf_wide[, -1]  

### Using this as input for clustering analysis does not include the last tree (61)
### as the clustering extracts values based on column names. 
### Therefore we need to add a column 61 to the dataframe. 

## Add column 61
rf_wide['61']<- NA

## Add row to make the matrix square (62x62)
rf_wide<-rbind(NA, rf_wide)

## Make row names 0 to 61 so that they match corresponding column names
rownames<-c(0:61)
rownames(rf_wide)<-rownames

# Cluster ----
#_____________
## Preform clustering
hc<-hclust(as.dist(rf_wide))

## Plot the cluster dendrogram with cutoff line at 14800 differences
plot(hc)
abline(h=14800, col="blue")

### Select one arbitrary tree from each cluster beneath the cutoff line
