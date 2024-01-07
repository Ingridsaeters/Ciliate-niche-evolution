###############################################################################
#                     Rscript Topography-Soil Niche Evolution                 #
###############################################################################

# Setup ----
#___________
## Load packages
library(tidyverse)
library(readr)
library(raster)
library(dplyr)
library(ncdf4)
library(elevatr)

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
  dplyr::select(sample, abundance, latitude, longitude) %>% 
  group_by(sample, latitude, longitude) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata$sample)### We have 977 distinct samples

## Make a data frame with sample names and coordinates
coords <- metadata_geo %>%
  dplyr::select(c(1:3))
coords_df<-data.frame(coords)
rownames(coords_df) <- coords_df[,1]
coords_df<-coords_df %>%
  dplyr::select(c(2:3))
coords_df<-coords_df[,c(2,1)]
colnames(coords_df)[1] <- "x"
colnames(coords_df)[2]<- "y"

## Make a file with coordinate values
points<-cbind(coords$longitude, coords$latitude)

# Extract elevation, TPI and slope ----
#______________________________________
# Choose projection
ll_proj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# Extract point elevation
topography<-elevatr::get_elev_point(locations = coords_df, prj=ll_proj, src = "aws")
topography$sample<-coords$sample

# Extract TPI values
## Create raster layer
elevation_r<- elevatr::get_elev_raster(locations = coords_df, prj=ll_proj, src = "aws", z=7) 
### Z=resolution, range=1:14. Choose a resolution of 7 as this equals 30arc seconds and 1km resolution, 
### and is the same resolution as the chelsa data we have downloaded

## Extract TPI
TPI<- terrain(elevation_r, opt = "TPI")
topography$TPI<-extract(TPI, points)

# Extract slope
slope<-terrain(elevation_r, opt = "slope", unit="degrees", neighbours = 8)
topography$slope<-extract(slope, points)

## Change column order and rename column header
topography<-topography %>%
  relocate(sample, .after = 1)

# Write file ----
#________________
write_tsv(topography, file="topography_soil.tsv")

