###############################################################################
#                               Rscript SoilGrids                             #
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
library(tidyverse)
library(readr)
library(raster)
library(soilDB)
library(aqp)

## Set working directory
setwd("C:/Users/path/to/directory")

# Prepare metadata ----
#______________________
## Read metadata file
metadata <- read.csv('asv_long_metadata_soil_reduced', sep="\t", header=FALSE)                     

## Rename columns
metadata <- metadata %>% 
  rename("sample" = "V1",
         "ASV" = "V2",
         "abundance" = "V3",
         "latitude" = "V4",
         "longitude" = "V5",
         "depth" = "V6",
         "altitude" = "V7",
         "biome" = "V8",
         "material" = "V9",
         "collection_date" = "V10")

## Get data for unique samples
metadata_geo <- metadata %>% 
  dplyr::select(sample, abundance, latitude, longitude, collection_date) %>% 
  group_by(sample, latitude, longitude, collection_date) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata$sample)### We have 977 distinct samples

## Make a data frame with sample id, latitude and longitude
coords <- metadata_geo %>%
  dplyr::select(c(1:3))
coords_df<-data.frame(rbind(coords), stringsAsFactors = FALSE)
colnames(coords_df)[1] <- "id"
colnames(coords_df)[2] <- "lat"
colnames(coords_df)[3] <- "lon"

# Extract pH ----
#________________
if(requireNamespace("curl") &
   curl::has_internet()) {
  
  soilgrid_ph <- fetchSoilGrids(coords_df, 
                                    loc.names = c("id", "lat", "lon"), 
                                    depth_intervals = "0-5",
                                    variables = "phh2o")

}

ph <- as.data.frame(soilgrid_ph, row.names = NULL)
mean_ph <- pH %>%
  dplyr::select(c(1, 6))

# Extract nitrogen ----
#______________________
if(requireNamespace("curl") &
   curl::has_internet()) {
  
  soilgrid_nitrogen <- fetchSoilGrids(coords_df, 
                                loc.names = c("id", "lat", "lon"), 
                                depth_intervals = "0-5",
                                variables = "nitrogen")
  
}

nitrogen <- as.data.frame(soilgrid_nitrogen, row.names = NULL)
mean_nitrogen <- nitrogen %>%
  dplyr::select(c(1, 6))

# Extract Carbon ----
#____________________
if(requireNamespace("curl") &
   curl::has_internet()) {
  
  soilgrid_carbon <- fetchSoilGrids(coords_df, 
                                      loc.names = c("id", "lat", "lon"), 
                                      depth_intervals = "0-5",
                                      variables = "soc")
  
}

carbon <- as.data.frame(soilgrid_carbon, row.names = NULL)
mean_carbon <- carbon %>%
  dplyr::select(c(1, 6))

# Combine the files ----
#_______________________

soilgrids<-cbind(metadata_geo$sample, )

