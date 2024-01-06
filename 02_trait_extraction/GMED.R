###############################################################################
#           Rscript Global Marine Environment Dataset Niche Evolution         #
###############################################################################

### Download GMED data from: https://gmed.auckland.ac.nz/download.html 

# Setup ----
#___________
## Load packages
library(tidyverse)
library(raster)
library(dplyr)
library(ncdf4)

## set working directory
setwd("C:/Users/path/to/directory")

# Prepare metadata ----
#______________________
## Read in metadata file
metadata <- read.csv('asv_long_metadata_marine_reduced', sep="\t", header=FALSE)                     
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
  dplyr::select(sample, abundance, latitude, longitude, depth) %>% 
  group_by(sample, latitude, longitude, depth) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata$sample) ### We have 5493 distinct samples

## Make a file with coordinate values
points<-cbind(metadata_geo$longitude, metadata_geo$latitude)

# Prepare a dataframe to enter extracted values ----
#___________________________________________________
GMED<-as.data.frame(metadata_geo[1])

# Extract PAR values from GMED ----
#_________________________________
## Rasterize the asc file
r_par<-raster("GMED/par/bo_par_mean.asc")
plot(r_par)
## Extract values
GMED$par<-raster::extract(r_par, points) 

# Extract mean Chlorophyll-A values from GMED ----
#_________________________________________________
## Rasterize the asc file
r_chla<-raster("GMED/chla_mean/bo_chla_mean.asc")
plot(r_chla)
## Extract values 
GMED$Chla_mean<-raster::extract(r_chla, points)

# Extract pH values from GMED ----
#_________________________________
## Rasterize the asc file
r_ph<-raster("GMED/ph/bo_ph.asc")
plot(r_ph)
## Extract values 
GMED$ph<-raster::extract(r_ph, points)

# Extract PIC values from GMED ----
#__________________________________
## Rasterize the asc file
r_pic<-raster("GMED/PIC/gc_pic_mean.asc")
plot(r_pic)
## Extract values 
GMED$pic<-raster::extract(r_pic, points)

# Extract POC values from GMED ----
#__________________________________
## Rasterize the asc file
r_poc<-raster("GMED/POC/gc_poc_mean.asc")
plot(r_poc)
## Extract values 
GMED$poc<-raster::extract(r_poc, points)

# Extract primary production values from GMED ----
#_________________________________________________
## Rasterize the asc file
r_primprod<-raster("GMED/primprod_chla/aq_primprod.asc")
plot(r_primprod)
## Extract values 
GMED$primprod<-raster::extract(r_primprod, points)

# Extract Total Suspended Matter values from GMED ----
#_____________________________________________________
## Rasterize the asc file
r_tsm<-raster("GMED/Total_Suspended_Matter/gc_tsm_mean.asc")
plot(r_tsm)
## Extract values 
GMED$tsm<-raster::extract(r_tsm, points)

# Write the file ----
#____________________
write_tsv(GMED, "GMED.tsv")
