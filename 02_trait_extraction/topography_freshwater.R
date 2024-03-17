###############################################################################
#                          Rscript Topography-Freshwater                      #
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
library(raster)
library(dplyr)
library(ncdf4)
library(elevatr)

## set working directory
setwd("C:/Users/path/to/directory")

# Prepare metadata ----
#______________________
## Read metadata 
metadata <- read.csv('asv_long_metadata_freshwater_reduced', sep="\t", header=FALSE)                     

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
  dplyr::select(sample, abundance, latitude, longitude, depth, altitude) %>% 
  group_by(sample, latitude, longitude, depth, altitude) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata$sample)
### We have 351 distinct samples


## Make a data frame with sample names and coordinates
coords <- metadata_geo %>%
  dplyr::select(c(1:3))
coords_df<-data.frame(rbind(coords))
## Make a file with coordinate values
points<-cbind(coords_df$longitude, coords_df$latitude)
points_df<-coords_df %>%
  dplyr::select(latitude, longitude)
points_df<-points_df %>%
  relocate("longitude")
colnames(points_df)[1]<-"x"
colnames(points_df)[2]<-"y"

# Extract elevation ----
#_______________________
## Choose projection
ll_proj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

## Extract point elevation
elevation<- elevatr::get_elev_point(locations = points_df, prj=ll_proj, src = "aws")
elevation$sample<-coords$sample

## Change column order 
elevation<-elevation %>%
  relocate(sample, .after = 1)

# Write file ----
#________________
write_tsv(elevation, file="elevation_freshwater.tsv")

