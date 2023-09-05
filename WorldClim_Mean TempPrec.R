# Setup
## Load packages
library(tidyverse)
library(sf)
library(rnaturalearth) 
library(rnaturalearthdata)
library(raster)
library(ncdf4)
library(tibble)

## Set working directory
setwd("C:/Users/ingri/OneDrive/Dokumenter/Master/Masteroppgave/Investigating_how_niches_evolve_in_microbial_eukaryotes/WorldClim")

# Read in metadata file
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

## Retain only the columns we need for now (ASV, sample, biome, latitude, longitude, collection date)  
metadata <- metadata %>% 
  dplyr::select(ASV, sample, abundance, biome, latitude, longitude, collection_date) 

## Get data for unique samples
metadata_geo <- metadata %>% 
  dplyr::select(sample, abundance, latitude, longitude, collection_date) %>% 
  group_by(sample, latitude, longitude, collection_date) %>% 
  summarise(sum_abundance = sum(abundance))

## Number of samples
n_distinct(metadata$sample)
### We have 977 distinct samples

# Extract climate data for our coordinates

## Download WorldClim Mean Temperature data at a resolution of 30 seconds (tavg 30s) from here https://www.worldclim.org/data/worldclim21.html 

## Make a matrix or data frame with sample names as the row names, column 1 as longitude, and column 2 as latitude. 
columns <- metadata_geo %>%
  dplyr::select(c(1:3))
df<-data.frame(rbind(columns))
rownames(df) <- df[,1]
samples<-df %>%
  dplyr::select(c(2:3))
samples<-samples[,c(2,1)]

## Import WorldClim Mean Temp data for each month (temp1=Jan etc)
temp1 <- raster("wc2.1_30s_tavg_01.tif")
temp2 <- raster("wc2.1_30s_tavg_02.tif")
temp3 <- raster("wc2.1_30s_tavg_03.tif")
temp4 <- raster("wc2.1_30s_tavg_04.tif")
temp5 <- raster("wc2.1_30s_tavg_05.tif")
temp6 <- raster("wc2.1_30s_tavg_06.tif")
temp7 <- raster("wc2.1_30s_tavg_07.tif")
temp8 <- raster("wc2.1_30s_tavg_08.tif")
temp9 <- raster("wc2.1_30s_tavg_09.tif")
temp10 <- raster("wc2.1_30s_tavg_10.tif")
temp11 <- raster("wc2.1_30s_tavg_11.tif")
temp12 <- raster("wc2.1_30s_tavg_12.tif")

## Extract WorldClim Mean Temp data for our dataset. Make a column with data for each month. 
temp.data <- samples 
temp.data$Jan <- extract(temp1, samples)
temp.data$Feb <- extract(temp2, samples)
temp.data$Mar <- extract(temp3, samples)
temp.data$Apr <- extract(temp4, samples)
temp.data$May <- extract(temp5, samples)
temp.data$Jun <- extract(temp6, samples)
temp.data$Jul <- extract(temp7, samples)
temp.data$Aug <- extract(temp8, samples)
temp.data$Sep <- extract(temp9, samples)
temp.data$Oct <- extract(temp10, samples)
temp.data$Nov <- extract(temp11, samples)
temp.data$Dec <- extract(temp12, samples)


## Convert row names to first column so that sample names are included in extracted tsv file
temp.data <- tibble::rownames_to_column(temp.data, "sample")

## Write out tsv file with temperature data
write_tsv(temp.data, file="temperature.tsv")

## Download precipitation data at a resolution of 30 seconds (prec 30s) from WorldClim (https://www.worldclim.org/data/worldclim21.html)

## Import WorldClim precipitation data for each month (prec1=january etc)
prec1 <- raster("wc2.1_30s_prec_01.tif")
prec2<-raster("wc2.1_30s_prec_02.tif")
prec3<-raster("wc2.1_30s_prec_03.tif")
prec4<-raster("wc2.1_30s_prec_04.tif")
prec5<-raster("wc2.1_30s_prec_05.tif")
prec6<-raster("wc2.1_30s_prec_06.tif")
prec7<-raster("wc2.1_30s_prec_07.tif")
prec8<-raster("wc2.1_30s_prec_08.tif")
prec9<-raster("wc2.1_30s_prec_09.tif")
prec10<-raster("wc2.1_30s_prec_10.tif")
prec11<-raster("wc2.1_30s_prec_11.tif")
prec12<-raster("wc2.1_30s_prec_12.tif")

## Extract WorldClim percipitation data for our dataset. Make a column with data for each month. 
prec.data<-samples
prec.data$Jan<-extract(prec1, samples)
prec.data$Feb<-extract(prec2, samples)
prec.data$Mar<-extract(prec3, samples)
prec.data$Apr<-extract(prec4, samples)
prec.data$May<-extract(prec5, samples)
prec.data$Jun<-extract(prec6, samples)
prec.data$Jul<-extract(prec7, samples)
prec.data$Aug<-extract(prec8, samples)
prec.data$Sep<-extract(prec9, samples)
prec.data$Oct<-extract(prec10, samples)
prec.data$Nov<-extract(prec11, samples)
prec.data$Dec<-extract(prec12, samples)

## Convert row names to first column so that sample names are included in extracted tsv file
prec.data <- tibble::rownames_to_column(prec.data, "sample")

## Write out tsv file with percipitation data
write_tsv(prec.data, file="precipitation.tsv")

# Get temperature and precipitation based on collection date

## Merge the dataframes temp.data and metadata_geo
full.table.temp<-merge(temp.data, metadata_geo, by="sample")

## Change value of collection date to number of month collected
full.table.temp$collection_date <- format(as.Date(full.table.temp$collection_date, format="%Y-%m-%d"),"%m")

## Change number of month to the name of month that is used for the temperature value
full.table.temp$collection_date[full.table.temp$collection_date == "01"] <- "Jan"
full.table.temp$collection_date[full.table.temp$collection_date == "02"] <- "Feb"
full.table.temp$collection_date[full.table.temp$collection_date == "03"] <- "Mar"
full.table.temp$collection_date[full.table.temp$collection_date == "04"] <- "Apr"
full.table.temp$collection_date[full.table.temp$collection_date == "05"] <- "May"
full.table.temp$collection_date[full.table.temp$collection_date == "06"] <- "Jun"
full.table.temp$collection_date[full.table.temp$collection_date == "07"] <- "Jul"
full.table.temp$collection_date[full.table.temp$collection_date == "08"] <- "Aug"
full.table.temp$collection_date[full.table.temp$collection_date == "09"] <- "Sep"
full.table.temp$collection_date[full.table.temp$collection_date == "10"] <- "Oct"
full.table.temp$collection_date[full.table.temp$collection_date == "11"] <- "Nov"
full.table.temp$collection_date[full.table.temp$collection_date == "12"] <- "Dec"


## Extract temperature for the month of sampling and add this in a new column
temp_by_date<-full.table.temp %>% pivot_longer(cols = Jan:Dec) %>% group_by(sample) %>% filter(name == collection_date) %>% mutate(nm1 = c('temperature')) %>% ungroup %>%  dplyr::select(sample, value, nm1) %>% pivot_wider(names_from = nm1, values_from = value) %>% left_join(full.table.temp, .)

## Make a new file with sample name, mean temperature in month of collection and collection month 
temp<-temp_by_date %>% 
  dplyr::select(sample, temperature, collection_date)

## Write out tsv file with sample, temperature and collection date
write_tsv(temp, file="temperature.tsv")

## Make a new metadata table with the temperature information we are after
asv.date<-merge(metadata, temp, by="sample")

## Remomve NA's
asv.date.reduced<-asv.date[Reduce(`&`, lapply(asv.date, function(x) !(is.na(x)|x==""))),]

## Merge the data frames prec.data and metadata.geo
full.table.prec<-merge(prec.data, metadata_geo, by="sample")

## Change value of collection date to number of month collected
full.table.prec$collection_date <- format(as.Date(full.table.prec$collection_date, format="%Y-%m-%d"),"%m")

## Change number of month to the name of month that is used for the precipitation value
full.table.prec$collection_date[full.table.prec$collection_date == "01"] <- "Jan"
full.table.prec$collection_date[full.table.prec$collection_date == "02"] <- "Feb"
full.table.prec$collection_date[full.table.prec$collection_date == "03"] <- "Mar"
full.table.prec$collection_date[full.table.prec$collection_date == "04"] <- "Apr"
full.table.prec$collection_date[full.table.prec$collection_date == "05"] <- "May"
full.table.prec$collection_date[full.table.prec$collection_date == "06"] <- "Jun"
full.table.prec$collection_date[full.table.prec$collection_date == "07"] <- "Jul"
full.table.prec$collection_date[full.table.prec$collection_date == "08"] <- "Aug"
full.table.prec$collection_date[full.table.prec$collection_date == "09"] <- "Sep"
full.table.prec$collection_date[full.table.prec$collection_date == "10"] <- "Oct"
full.table.prec$collection_date[full.table.prec$collection_date == "11"] <- "Nov"
full.table.prec$collection_date[full.table.prec$collection_date == "12"] <- "Dec"

## Extract precipitation for the month of sampling and add this in a new column
prec_by_date<-full.table.prec %>% pivot_longer(cols = Jan:Dec) %>% group_by(sample) %>% filter(name == collection_date) %>% mutate(nm1 = c('precipitation')) %>% ungroup %>%  dplyr::select(sample, value, nm1) %>% pivot_wider(names_from = nm1, values_from = value) %>% left_join(full.table.prec, .)

## Make a new file with sample name, mean precipitation in month of collection and collection month 
prec<-prec_by_date %>% 
  dplyr::select(sample, precipitation, collection_date)

## Write out tsv file with sample, temperature and collection date
write_tsv(prec, file="prec.tsv")

## Make a new metadata file with temperature and precipitation by month
asv.meta<-merge(asv.date, prec, by="sample")

## Remove unecessary columns
asv.meta<-asv.meta[,c(-7,-9)]

# For each ASV, get mean temp, number of samples, and biome (optional)
## Mean temperature
asv_clim <- asv.meta %>%
  dplyr::select(ASV, temperature, precipitation) %>%
  drop_na(temperature) %>%
  drop_na(precipitation) %>%
  group_by(ASV) %>%
  summarise(mean_temp=mean(temperature), 
            mean_prec=mean(precipitation))

## Number of samples
asv_samples <- asv.meta %>%
  dplyr::select(ASV, sample) %>%
  count(ASV)

### Let's get range of presence data (out of 977 samples)
min(asv_samples$n)  ## 1
max(asv_samples$n)  ## 698
mean(asv_samples$n) ## 14.2
median(asv_samples$n) ## 4

# Put it all together
## Read in taxonomy file
taxo <- read.csv('eukbank_asv_size_taxonomy.tsv', sep="\t", header=TRUE)

## Combine! :D
asv_meta <- merge(taxo, asv_samples, by="ASV", all.x = TRUE)

asv_meta <- merge(asv_meta, asv_clim, by="ASV", all.x = TRUE) %>%
  dplyr::select(Tip, Abundance, Taxonomy, n, mean_temp, mean_prec)

## Remove NA's
asv_meta[is.na(asv_meta)] <- ""

## Write table
write.table(asv_meta, "asv_meta.ingrid.tsv", quote = FALSE, sep = "\t", row.names = FALSE)
