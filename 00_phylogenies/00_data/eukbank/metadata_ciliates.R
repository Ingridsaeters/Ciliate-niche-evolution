#########################################################################
#                     Rscript Metadata Ciliates                         #
#########################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution
# EDGE group, Natural history museum, University of Oslo
# 27.10.2024
# Version 1
# R v. 4.4.0
#=================#

# Setup ----
#___________

## Load packages
library(tidyverse)

## Set working directory
setwd("")

# Metadata for ciliates ----
#___________________________

# Read the full metadata file 
metadata <- read_tsv("eukbank_18SV4_asv.subset.metadata")

# Read the file with ciliates and format the file
ciliates <- read_tsv("sample_amplicon", col_names = FALSE)
colnames(ciliates)[1]<-"ASV"
colnames(ciliates)[2]<-"sample"
ciliates <- ciliates[-3]

# Create a metadata file for ciliates
metadata_ciliates <- merge(metadata, ciliates, by.x = "sample", by.y = "sample")

# Add taxon information to the ASV name, so it is in the same format as in the fasta file
sub <- read.csv("substitute.list", header = FALSE, sep = "")
colnames(sub)[1]<-"ASV"
metadata_ciliates <- merge(metadata_ciliates, sub, by.x = "ASV", by.y = "ASV" )
metadata_ciliates<-metadata_ciliates[-1]
colnames(metadata_ciliates)[13]<- "ASV"
metadata_ciliates <- metadata_ciliates %>%
  relocate(ASV)

# Format ASV name in the same style as in the trees
metadata_ciliates$ASV <- gsub("=", "_", metadata_ciliates$ASV)

# Remove ASVs without coordinate information
metadata_ciliates <- metadata_ciliates %>% drop_na(latitude)
metadata_ciliates <- metadata_ciliates %>% drop_na(longitude)

# Check how many ASVs we have
n_ASVs <- as.data.frame(unique(metadata_ciliates$ASV)) #We have 17698 ASVs
colnames(n_ASVs)[1]<-"ASV"

# Write the list of ASVs
write_tsv(n_ASVs, "eukbank_all_17698.list.tsv")

# Write the metadata file
write_tsv(metadata_ciliates, "metadata_ciliates.tsv", col_names = TRUE)
