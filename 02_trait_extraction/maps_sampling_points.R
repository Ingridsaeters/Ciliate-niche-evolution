###############################################################################
#                 Rscript Sampling Points Maps Niche Evolution                #
###############################################################################

# Setup ----
#___________
## Load packages
library(tidyverse)
library(ggplot2)
theme_set(theme_bw()) ### Dark on light theme 
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

## Set working directory
setwd("C:/Users/path/to/directory")

# Load metadata for soil samples ----
#____________________________________
## Read metadata file
metadata_soil <- read.csv('soil/asv_long_metadata_soil_reduced', sep="\t", header=FALSE)                     

## Rename columns
metadata_soil <- metadata_soil %>% 
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
metadata_soil_geo <- metadata_soil %>% 
  dplyr::select(sample, abundance, latitude, longitude) %>% 
  group_by(sample, latitude, longitude) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata_soil$sample)### We have 977 distinct samples

## Make a data frame with sample id, latitude and longitude
coords_soil <- metadata_soil_geo %>%
  dplyr::select(c(1:3))
coords_soil_df<-data.frame(rbind(coords_soil), stringsAsFactors = FALSE)
colnames(coords_soil_df)[1] <- "id"
colnames(coords_soil_df)[2] <- "y"
colnames(coords_soil_df)[3] <- "x"

# Load metadata for marine samples ----
#_____________________________________
## Read metadata file
metadata_marine <- read.csv('marine/asv_long_metadata_marine_reduced', sep="\t", header=FALSE)                     

## Rename columns
metadata_marine <- metadata_marine %>% 
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
metadata_marine_geo <- metadata_marine %>% 
  dplyr::select(sample, abundance, latitude, longitude, depth) %>% 
  group_by(sample, latitude, longitude, depth) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata_marine$sample)### We have 5493 distinct samples

## Make a data frame with sample id, latitude and longitude
coords_marine <- metadata_marine_geo %>%
  dplyr::select(c(1:3))
coords_marine_df<-data.frame(rbind(coords_marine), stringsAsFactors = FALSE)
colnames(coords_marine_df)[1] <- "id"
colnames(coords_marine_df)[2] <- "y"
colnames(coords_marine_df)[3] <- "x"

# Load metadata for freshwater samples ----
#__________________________________________
## Read in metadata file
metadata_freshwater <- read.csv('freshwater/asv_long_metadata_freshwater_reduced', sep="\t", header=FALSE)                     

## Rename columns
metadata_freshwater <- metadata_freshwater %>% 
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
metadata_freshwater_geo <- metadata_freshwater %>% 
  dplyr::select(sample, abundance, latitude, longitude, depth, altitude) %>% 
  group_by(sample, latitude, longitude, depth, altitude) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata_freshwater$sample)### We have 351 distinct samples

## Make a data frame with sample id, latitude and longitude
coords_freshwater <- metadata_freshwater_geo %>%
  dplyr::select(c(1:3))
coords_freshwater_df<-data.frame(rbind(coords_freshwater), stringsAsFactors = FALSE)
colnames(coords_freshwater_df)[2] <- "id"
colnames(coords_freshwater_df)[3] <- "y"
colnames(coords_freshwater_df)[4] <- "x"


# Create world map ----
#______________________
## Get the world map country border points
world_map <- map_data("world")

## Creat a base plot with gpplot2
p <- ggplot() + coord_fixed() +
  xlab("") + ylab("")

## Add map to base plot
base_world_messy <- p + geom_polygon(data=world_map, aes(x=long, y=lat, group=group), 
                                     colour="light green", fill="light green")
base_world_messy

## Strip the map down so it looks super clean (and beautiful!)
cleanup <- 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill = 'white', colour = 'white'), 
        panel.border = element_blank(),
        axis.line = element_line(colour = "white"), legend.position="none",
        axis.ticks=element_blank(), axis.text.x=element_blank(),
        axis.text.y=element_blank())

base_world <- base_world_messy + cleanup
base_world

# Plot the points for soil samples on the map ----
#_________________________________________________
map_data_soil <- 
  base_world +
  ggtitle("Soil samples") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme(plot.title = element_text(size=22))+
  geom_point(data=coords_soil_df, 
             aes(x=x, y=y), colour="Deep Pink", 
             fill="Pink",pch=21, size=2, alpha=I(0.7))
map_data_soil

# Plot the points for marine samples on the map ----
#_________________________________________________
map_data_marine <- 
  base_world +
  ggtitle("Marine samples") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme(plot.title = element_text(size=22))+
  geom_point(data=coords_marine_df, 
             aes(x=x, y=y), colour="Deep Pink", 
             fill="Pink",pch=21, size=2, alpha=I(0.7))
map_data_marine

# Plot the points for freshwater samples on the map ----
#_________________________________________________
map_data_freshwater <- 
  base_world +
  ggtitle("Freshwater samples") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme(plot.title = element_text(size=22))+
  geom_point(data=coords_freshwater_df, 
             aes(x=x, y=y), colour="Deep Pink", 
             fill="Pink",pch=21, size=2, alpha=I(0.7))
map_data_freshwater

