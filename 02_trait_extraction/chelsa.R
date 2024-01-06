###############################################################################
#                     Rscript CHELSA Niche Evolution                          #
###############################################################################


### Download the bio1, bio10, bio12, bio15, bio16 and bio19 CHELSA data in tif format https://chelsa-climate.org/downloads/
### path: Downloads/climatologies/1981-2010/bio


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
coords_df<-data.frame(rbind(coords))
## Make a file with coordinate values
points<-cbind(coords_df$longitude, coords_df$latitude)

# Prepare a dataframe to enter extracted values ----
#___________________________________________________
chelsa<-as.data.frame(metadata_geo[1], row.names = NULL)

# Extract annual average temperature data ----
#_____________________________________________
## Rasterize the tif file
bio1_r<- raster('tif_files/CHELSA_bio1_1981-2010_V.2.1.tif')
## Extract values
chelsa$temperature<-raster::extract(bio1_r, points)
## Raster values must be multiplied by the scale value (0,1) and offset value must be added (-273,15)
chelsa$temperature<- chelsa[,2]*0.1
chelsa$temperature<- chelsa[,2]-273.15

# Extract annual mean percipitation data (precipitation seasonality) ----
#________________________________________________________________________
## Rasterize the tif file
bio15_r<- raster('tif_files/CHELSA_bio15_1981-2010_V.2.1.tif')
## Extract values
chelsa$precipitation_seasonality<-raster::extract(bio15_r, points)
## Raster values must be multiplied by the scale value (0,1) 
chelsa$precipitation_seasonality<- chelsa[,3]*0.1

# Extract annual percipitation amount ----
#_________________________________________
## Rasterize the tif file
bio12_r<- raster('tif_files/CHELSA_bio12_1981-2010_V.2.1.tif')
## Extract values
chelsa$precipitation_accumulated<-raster::extract(bio12_r, points)
## Raster values must be multiplied by the scale value (0,1) 
chelsa$precipitation_accumulated<- chelsa[,4]*0.1

# Extract mean monthly precipitation amount for wettest quarter ----
#___________________________________________________________________
## Rasterize the tif file
bio16_r<- raster('tif_files/CHELSA_bio16_1981-2010_V.2.1.tif')
## Extract values
chelsa$precipitation_mean_monthly_wettest<-raster::extract(bio16_r, points)
## Raster values must be multiplied by the scale value (0,1) 
chelsa$precipitation_mean_monthly_wettest<- chelsa[,5]*0.1

# Extract mean monthly precipitation amount for coldest quarter ----
#___________________________________________________________________
## Rasterize the tif file
bio19_r<- raster('tif_files/CHELSA_bio19_1981-2010_V.2.1.tif')
## Extract values
chelsa$precipitation_mean_monthly_coldest<-raster::extract(bio19_r, points)
## Raster values must be multiplied by the scale value (0,1) 
chelsa$precipitation_mean_monthly_coldest<- chelsa[,6]*0.1

# Extract mean daily mean temperature for warmest quarter ----
#_____________________________________________________________
## Rasterize the tif file
bio10_r<- raster('tif_files/CHELSA_bio10_1981-2010_V.2.1.tif')
## Extract values
chelsa$temperature_mean_warmest_quarter<-raster::extract(bio10_r, points)
## Raster values must be multiplied by the scale value (0,1) and offset value must be added (-273.15)
chelsa$temperature_mean_warmest_quarter<- chelsa[,7]*0.1
chelsa$temperature_mean_warmest_quarter<- chelsa[,7]-273.15

# Write file ----
#________________
write_tsv(chelsa, "chelsa.tsv")
