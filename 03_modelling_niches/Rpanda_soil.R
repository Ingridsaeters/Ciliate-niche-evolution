###############################################################################
#                       Rscript RPANDA Niche Evolution                        #
###############################################################################

# Setup ----
#___________
## Load packages
library(devtools)
install_github("hmorlon/PANDA", dependencies = TRUE)
library(RPANDA)
library(phytools)
library(tidyverse)
library(readr)

## set working directory
setwd("C:/Users/path/to/directory")

# Prepare the data ----
#______________________
## Load the traits dataset
data <- read_tsv("name_of_traits_file.tsv")

## The tree
tree <- read.newick("name_of_tree_file.nwk")


## Construct a named vector of the trait you want to model (exemplified here by temperature)
temp <- data$temperature
names(temp) <- data$ASV

## Align dataset and tree
temp = temp[tree$tip.label] 

### since the vector is named, the data will be reordered by the name

# Standard models of trait evolution----
#_______________________________________
BM.fit <- fit_t_standard(tree, temp, model="BM", error=NULL)
OU.fit <- fit_t_standard(tree, temp, model="OU", error=NULL)
EB.fit <- fit_t_standard(tree, temp, model="EB", error=NULL)

print(BM.fit)
print(OU.fit)
print(EB.fit)

