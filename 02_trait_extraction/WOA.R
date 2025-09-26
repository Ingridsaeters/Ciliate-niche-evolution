###############################################################################
#                            Rscript World Ocean Atlas                        #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 22.02.2024
# R v. 4.2.2
# Version 1
#=================#

### Download WOA data from: https://www.ncei.noaa.gov/access/world-ocean-atlas-2018/
### Repeat analysis for marine surface only

# Setup ----
#___________
## Load packages
library(tidyverse)
library(readr)
library(raster)

## Set working directory
setwd("/Users/path/to/directory")

# Prepare metadata ----
#______________________
# Read metadata file
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
n_distinct(metadata$sample)### We have 5493 distinct samples

## Make a file with coordinate values
points<-cbind(metadata_geo$longitude, metadata_geo$latitude)

# Make a data frame with subset of values ----
#_____________________________________________
## Create data frame with samples, coordinates and depth values
metadata_subset <- metadata_geo %>%
  dplyr::select(c(1:4))
metadata_subset<-data.frame(rbind(metadata_subset))

# Round depth values so that they match the values from WOA ----
#_______________________________________________________________
## Convert depth variables to numeric 
depth_n <- as.numeric(metadata_subset$depth)
## Round values
depth <-ifelse(depth_n<100, round(depth_n/5)*5, depth_n)### For depth <100 round by 5
depth <-ifelse(depth >100 & depth <500, round(depth/25)*25, depth) ### For depth 100-500 round by 25
depth <- ifelse(depth >500, round(depth/50)*50, depth)### For depth >500 round by 50
## Add rounded depth value to metadata_subset
metadata_subset["rounded_depth"] <- depth

# Extract nitrate values from World Ocean Atlas ----
#___________________________________________________
## Make a brick
nitrate_brick <- brick("woa18_all_n00_01.nc")

## Extract nitrate values for our points
nitrate <- raster::extract(nitrate_brick, points)
nitrate<-data.frame(nitrate)
nitrate<-cbind(metadata_subset[1], nitrate)

## Add columns with depth and rounded depth for each sample
nitrate["depth"] <- metadata_subset$depth
nitrate["rounded_depth"] <- metadata_subset$rounded_depth

## Reorder columns
nitrate<-nitrate %>% relocate(depth, .after=1)
nitrate<-nitrate %>% relocate(rounded_depth, .after=2)

## Remove the X from column names
for ( col in 1:ncol(nitrate)){
  colnames(nitrate)[col] <-  sub("X", "", colnames(nitrate)[col])
}

## Check dimensions
dim(nitrate)

## Remove rows that contain NA for all columns (selecting columns 4-105 as these are the ones we have values from)
nitrate_clean <- subset(nitrate, rowSums(is.na(nitrate)) != ncol(nitrate[4:105]))

## Extract nitrate for specific depth
nitrate_clean$nitrate <- apply(nitrate_clean, 1, function(x) { x[names(x)==x[names(x)=="rounded_depth"]]})
nitrate_clean <-nitrate_clean %>% relocate(nitrate, .after = 1)

# Extract silicate values from World Ocean Atlas ----
#____________________________________________________
## Make a brick
silicate_brick <- brick("woa18_all_i00_01.nc")

## Extract values for our points
silicate <- raster::extract(silicate_brick, points)
silicate<-data.frame(silicate)
silicate<-cbind(metadata_subset[1], silicate)

## Add columns with depth and rounded depth for each sample
silicate["depth"] <- metadata_subset$depth
silicate["rounded_depth"] <- metadata_subset$rounded_depth

## Reorder columns
silicate<-silicate %>% relocate(depth, .after=1)
silicate<-silicate %>% relocate(rounded_depth, .after=2)

## Remove the X from column names
for ( col in 1:ncol(silicate)){
  colnames(silicate)[col] <-  sub("X", "", colnames(silicate)[col])
}

## Remove rows that contain NA for all columns (selecting columns 4-105 as these are the ones we have values from)
silicate_clean <- subset(silicate, rowSums(is.na(silicate)) != ncol(silicate[4:105]))

## Extract silicate for specific depth
silicate_clean$silicate <- apply(silicate_clean, 1, function(x) { x[names(x)==x[names(x)=="rounded_depth"]]})
silicate_clean <-silicate_clean %>% relocate(silicate, .after = 1)

# Extract dissolved oxygen values from World Ocean Atlas ----
#____________________________________________________________
## Make a brick
DO_brick <- brick("woa18_all_o00_01.nc")

## Extract values for our points
DO <- raster::extract(DO_brick, points)
DO<-data.frame(DO)
DO<-cbind(metadata_subset[1], DO)

## Add columns with depth and rounded depth for each sample
DO["depth"] <- metadata_subset$depth
DO["rounded_depth"] <- metadata_subset$rounded_depth

## Reorder columns
DO<-DO %>% relocate(depth, .after=1)
DO<-DO %>% relocate(rounded_depth, .after=2)

## Remove the X from column names
for ( col in 1:ncol(DO)){
  colnames(DO)[col] <-  sub("X", "", colnames(DO)[col])
}

## Remove rows that contain NA for all columns (selecting columns 4-105 as these are the ones we have values from)
DO_clean <- subset(DO, rowSums(is.na(DO)) != ncol(DO[4:105]))

## Extract DO for specific depth
DO_clean$DO <- apply(DO_clean, 1, function(x) { x[names(x)==x[names(x)=="rounded_depth"]]})
DO_clean <-DO_clean %>% relocate(DO, .after = 1)

# Extract percent oxygen saturation values from World Ocean Atlas ----
#_____________________________________________________________________
## Make a brick
POS_brick <- brick("woa18_all_O_00_01.nc")

## Extract values for our points
POS <- raster::extract(POS_brick, points)
POS<-data.frame(POS)
POS<-cbind(metadata_subset[1], POS)

## Add columns with depth and rounded depth for each sample
POS["depth"] <- metadata_subset$depth
POS["rounded_depth"] <- metadata_subset$rounded_depth

## Reorder columns
POS<-POS %>% relocate(depth, .after=1)
POS<-POS %>% relocate(rounded_depth, .after=2)

## Remove the X from column names
for ( col in 1:ncol(POS)){
  colnames(POS)[col] <-  sub("X", "", colnames(POS)[col])
}

## Remove rows that contain NA for all columns (selecting columns 4-105 as these are the ones we have values from)
POS_clean <- subset(POS, rowSums(is.na(POS)) != ncol(POS[4:105]))

## Extract POS for specific depth
POS_clean$POS <- apply(POS_clean, 1, function(x) { x[names(x)==x[names(x)=="rounded_depth"]]})
POS_clean <-POS_clean %>% relocate(POS, .after = 1)

# Extract apparent oxygen utilization values from World Ocean Atlas ----
#_______________________________________________________________________
## Make a brick
AOU_brick <- brick("woa18_all_A00_01.nc")

## Extract values for our points
AOU <- raster::extract(AOU_brick, points)
AOU<-data.frame(AOU)
AOU<-cbind(metadata_subset[1], AOU)

## Add columns with depth and rounded depth for each sample
AOU["depth"] <- metadata_subset$depth
AOU["rounded_depth"] <- metadata_subset$rounded_depth

## Reorder columns
AOU<-AOU %>% relocate(depth, .after=1)
AOU<-AOU %>% relocate(rounded_depth, .after=2)

## Remove the X from column names
for ( col in 1:ncol(AOU)){
  colnames(AOU)[col] <-  sub("X", "", colnames(AOU)[col])
}

## Remove rows that contain NA for all columns (selecting columns 4-105 as these are the ones we have values from)
AOU_clean <- subset(AOU, rowSums(is.na(AOU)) != ncol(AOU[4:105]))

## Extract AOU for specific depth
AOU_clean$AOU <- apply(AOU_clean, 1, function(x) { x[names(x)==x[names(x)=="rounded_depth"]]})
AOU_clean <-AOU_clean %>% relocate(AOU, .after = 1)

# Extract phosphate values from World Ocean Atlas ----
#_____________________________________________________
## Make a brick
phosphate_brick <- brick("woa18_all_p00_01.nc")

## Extract values for our points
phosphate <- raster::extract(phosphate_brick, points)
phosphate<-data.frame(phosphate)
phosphate<-cbind(metadata_subset[1], phosphate)

## Add columns with depth and rounded depth for each sample
phosphate["depth"] <- metadata_subset$depth
phosphate["rounded_depth"] <- metadata_subset$rounded_depth

## Reorder columns
phosphate<-phosphate %>% relocate(depth, .after=1)
phosphate<-phosphate %>% relocate(rounded_depth, .after=2)

## Remove the X from column names
for ( col in 1:ncol(phosphate)){
  colnames(phosphate)[col] <-  sub("X", "", colnames(phosphate)[col])
}

## Remove rows that contain NA for all columns (selecting columns 4-105 as these are the ones we have values from)
phosphate_clean <- subset(phosphate, rowSums(is.na(phosphate)) != ncol(phosphate[4:105]))

## Extract phosphate for specific depth
phosphate_clean$phosphate <- apply(phosphate_clean, 1, function(x) { x[names(x)==x[names(x)=="rounded_depth"]]})
phosphate_clean <-phosphate_clean %>% relocate(phosphate, .after = 1)

# Extract temperature values from World Ocean Atlas ----
#_______________________________________________________
## Make a brick
temperature_brick <- brick("woa18_decav_t00_01.nc")

## Extract values for our points
temperature <- raster::extract(temperature_brick, points)
temperature<-data.frame(temperature)
temperature<-cbind(metadata_subset[1], temperature)

## Add columns with depth and rounded depth for each sample
temperature["depth"] <- metadata_subset$depth
temperature["rounded_depth"] <- metadata_subset$rounded_depth

## Reorder columns
temperature<-temperature %>% relocate(depth, .after=1)
temperature<-temperature %>% relocate(rounded_depth, .after=2)

## Remove the X from column names
for ( col in 1:ncol(temperature)){
  colnames(temperature)[col] <-  sub("X", "", colnames(temperature)[col])
}

## Remove rows that contain NA for all columns (selecting columns 4-105 as these are the ones we have values from)
temperature_clean <- subset(temperature, rowSums(is.na(temperature)) != ncol(temperature[4:105]))

## Extract temperature for specific depth
temperature_clean$temperature <- apply(temperature_clean, 1, function(x) { x[names(x)==x[names(x)=="rounded_depth"]]})
temperature_clean <-temperature_clean %>% relocate(temperature, .after = 1)

# Make a table with all values ----
#______________________________________
WOA<-cbind(nitrate_clean[1], nitrate_clean[2], AOU_clean[2], DO_clean[2], phosphate_clean[2], POS_clean[2], silicate_clean[2], temperature_clean[2])

## Currently the dataframe contains variables in list format, turn it into values
columns_to_process<-c("nitrate", "AOU", "DO", "phosphate", "POS", "silicate", "temperature")
## Function to process each column
process_column <- function(df, col_name) {
  df[[col_name]] <- lapply(df[[col_name]], function(x) if (length(x) > 0) x else NA)
  df <- unnest(df, cols = col_name)
  df
}
# Apply the operation to each column using lapply and assign back to WOA
WOA_processed <- WOA
for (col in columns_to_process) {
  WOA_processed <- process_column(WOA_processed, col)
}

## Remove NAs and NULL values
WOA_clean<- WOA_processed[- grep("NA", WOA_processed$nitrate),]
WOA_clean<- WOA_clean[- grep("NULL", WOA_clean$nitrate),]

## Convert the 'Values' column to character so that we can write it out as tsv file
WOA_clean[columns_to_process] <- lapply(WOA_clean[columns_to_process], function(x) sapply(x, function(y) paste(y, collapse = ",")))

# Write the file ----
#____________________
write_tsv(WOA_clean, "WOA.tsv")


