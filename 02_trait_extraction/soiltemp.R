###############################################################################
#                       Rscript SoilTemp Niche Evolution                      #
###############################################################################

### Download the bio1 SoilTemp data in tif format https://zenodo.org/records/7134169

# Setup ----
#___________
## Load packages
library(tidyverse)
library(readr)
library(raster)
library(dplyr)
library(ncdf4)

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
  dplyr::select(sample, abundance, latitude, longitude) %>% 
  group_by(sample, latitude, longitude) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata$sample)
### We have 977 distinct samples

## Make a data frame with sample names and coordinates
coords <- metadata_geo %>%
  dplyr::select(c(1:3))
coords_df<-data.frame(rbind(coords))
## Make a file with coordinate values
points<-cbind(coords_df$longitude, coords_df$latitude)

# Extract annual average soil temperature data ----
#__________________________________________________
## Rasterize the tif file
soiltemp_r<- raster('SBIO1_0_5cm_Annual_Mean_Temperature.tif')
## Make a dataframe with sample and temperature data 
soiltemp<-as.data.frame(coords_df$sample)
colnames(soiltemp)[1]<- "sample"
soiltemp$temperature<-extract(soiltemp_r, points)

# Write out the tsv file
write_tsv(soiltemp, file="soiltemp.tsv")
