###############################################################################
#                         Rscript Subset metadata                             #
###############################################################################


#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 27.10.2024
# R v. 4.4.2
# Version 1
#=================#


# Setup ----
#___________
## Set working directory
setwd("")

# Prepare metadata ----
#______________________
## Read in metadata file
metadata <- read.csv("metadata_ciliates_env.csv", sep = ",") 

# Soil ----
#__________
## Read the list of soil ASVs
soil_list <- read_tsv("soil_ASVs.list")

metadata_soil <- merge(metadata, soil_list, by.x = "ASV", by.y = "ASV")

## Filter away ASVs that don't have the env "Soil"
metadata_soil_filtered <- metadata_soil[grep("Soil", metadata_soil$env), ]

## Write the file
write_tsv(metadata_soil_filtered, "../data/metadata_soil_filtered.tsv")

# Marine pelagic ----
#____________________
## Read the list of marine pelagiv ASVs
marine_list <- read_tsv("marine_pelagic_ASVs.list")

metadata_marine <- merge(metadata, marine_list, by.x = "ASV", by.y = "ASV")

## Filter away ASVs that don't have the env "Marine_pelagic"
metadata_marine_filtered <- metadata_marine[grep("Marine pelagic", metadata_marine$env), ]

## Write the file
write_tsv(metadata_marine_filtered, "../data/metadata_marine_pelagic_filtered.tsv")
