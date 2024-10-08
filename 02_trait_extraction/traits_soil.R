###############################################################################
#                               Rscript Traits-Soil                           #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 22.02.2024
# R v. 4.2.2
# Version 1
#=================#

# Setup ----
#___________
library(dplyr)
library(plyr)
library(tidyverse)


## set working directory
setwd("C:/Users/path/to/directory")

# Prepare metadata ----
#______________________
## Read metadata
metadata <- read.csv('asv_long_metadata_soil_reduced', sep="\t", header=FALSE)


# Create a dataframe to add values 
traits_soil<- metadata %>%
           dplyr::select(sample, ASV)


# Add traits from Chelsa ----
#____________________________
chelsa<-read_tsv("chelsa/chelsa.tsv")
traits_soil<-merge(traits_soil, chelsa[c("sample", "temperature", "precipitation_seasonality", "precipitation_accumulated", "precipitation_mean_monthly_wettest", "precipitation_mean_monthly_coldest", "temperature_mean_warmest_quarter")], by = "sample")

# Add traits from SoilGrids ----
#_______________________________
carbon<-read_tsv("soilgrids/mean_carbon.tsv")
nitrogen<-read_tsv("soilgrids/mean_nitrogen.tsv")
ph<-read_tsv("soilgrids/mean_ph.tsv")

colnames(carbon)[1]<-"sample"
colnames(nitrogen)[1]<-"sample"
colnames(ph)[1]<-"sample"

traits_soil<-merge(traits_soil, carbon[, c("sample", "socmean")], by="sample")
traits_soil<-merge(traits_soil, nitrogen[, c("sample", "nitrogenmean")], by="sample")
traits_soil<-merge(traits_soil, ph[, c("sample", "phh2omean")], by="sample")

# Add traits from SoilTemp ----
#______________________________
soiltemp<-read_tsv("soiltemp/soiltemp.tsv")
colnames(soiltemp)[2]<-"soil_temperature"

traits_soil<-merge(traits_soil, soiltemp[, c("sample", "soil_temperature")], by="sample")

# Add topography traits ----
#___________________________
topography<-read_tsv("topography/topography_soil.tsv")
topography<- topography %>%
  dplyr::select(sample, elevation, TPI, slope)

traits_soil<-merge(traits_soil, topography[, c("sample", "elevation", "TPI", "slope")], by="sample")


# Group by ASVs and calculate mean values ----
#________________________________________
traits <- traits_soil %>%
  group_by(ASV) %>%
  summarise_at(vars(-group_cols()), mean, na.rm = TRUE)

## Remove the sample column
traits <- traits[-2]

# Group by ASV and calculate SD values ----
#__________________________________________
## Calculate the number of each ASV
asv_counts <- traits_soil %>%
  count(ASV, name = "ASV_count")

## Calculate standard deviation for each trait 
sd_soil <- traits_soil %>%
  group_by(ASV) %>%
  summarise_at(vars(-group_cols()), sd, na.rm = TRUE) %>%
  left_join(asv_counts, by = "ASV") %>%
  mutate(ASV_group_count = ASV_count) %>%
  select(-ASV_count)

## Add suffix _sd to trait columns
names(sd_soil)[3:15] <- paste0(names(sd_soil[,3:15]), "_sd")

## Remove the sample column
sd_soil<-sd_soil[-2]

## Rename ASV_count column to N
colnames(sd_soil)[15]<-"N"

# Merge the traits table with sd table ----
#__________________________________________
traits_sd<-merge(traits, sd_soil, by.x = "ASV", by.y = "ASV")


# Add taxon ----
#______________________________
## Load file with ASV and taxon
group<-read.csv("eukbank_ciliate_soil_ASV.list", header=FALSE, sep = "\t")
colnames(group)[1]<-"ASV"
colnames(group)[3]<-"taxon"

## Add taxon information to traits file
traits_sd<-merge(traits_sd, group, by.x = "ASV", by.y = "ASV")

## Replace ASV column with one that matches the ASV information on our trees
traits_sd <- traits_sd[-1]
colnames(traits_sd)[28]<-"ASV"
traits_sd<-traits_sd %>%
  relocate(ASV, 1) %>%
  relocate(taxon, .after=1)

# Rename taxa ----
#_________________
## Check which unique taxa we have 
unique<-as.data.frame(unique(traits_soil$taxon))

## Rename taxa from undergroup to main group
traits_sd$taxon[traits_sd$taxon=="Microthoracida"]<-"Nassophorea"
traits_sd$taxon[traits_sd$taxon=="Nassulida"]<-"Nassophorea"
traits_sd$taxon[traits_sd$taxon=="Phacodinium"]<-"SAL"

## Replace NaNs with blank
traits_sd$socmean[is.nan(traits_sd$socmean)]<-""
traits_sd$nitrogenmean[is.nan(traits_sd$nitrogenmean)]<-""
traits_sd$phh2omean[is.nan(traits_sd$phh2omean)]<-""
traits_sd$soil_temperature[is.nan(traits_sd$soil_temperature)]<-""
traits_sd$socmean[is.na(traits_sd$socmean)]<-""
traits_sd$nitrogenmean[is.na(traits_sd$nitrogenmean)]<-""
traits_sd$phh2omean[is.na(traits_sd$phh2omean)]<-""
traits_sd$soil_temperature[is.na(traits_sd$soil_temperature)]<-""

# Write file ----
#________________
write_tsv(traits_soil, "traits_soil.tsv")

### Run a phylogenetic PCA analysis with the R script pPCA with the extracted values 
### Then return to this script to add PC1 values to the table

# Add PC1 values to the table ----
#_________________________________

## Load the traits file
traits_soil<-read_tsv("traits_soil.tsv")


## Load the PCA scores 
pca_scores_soil<-read_tsv("pca_scores_soil.tsv")
traits_soil<-merge(traits_sd, pca_scores_soil, by.x ="ASV", by.y = "ASV")
traits_soil<-traits_soil[-31]

# Write file ----
#________________
write_tsv(traits_soil, "traits_soil_PC1.tsv")
