###########################################################################
#               Rscript Remove ASVs in multiple envoronments              #
###########################################################################

## Set working directory
setwd("~/Documents/ciliate_niche/trait_extraction")

# Soil ----
#__________
## Read metadata file
metadata <- read.csv("~/Documents/ciliate_niche/trait_extraction/raw_data/metadata_soil_reduced", sep="\t", header=FALSE)                     

## Rename columns
metadata <- metadata %>% 
  rename("ASV" = "V1",
         "sample" = "V2",
         "abundance" = "V3",
         "latitude" = "V4",
         "longitude" = "V5",
         "depth" = "V6",
         "altitude" = "V7",
         "collection_date" = "V8",
         "biome" = "V9",
         "feature" = "V10",
         "material" = "V11",
         "raw_env" = "V12",
         "temperature" = "V13",
         "salinity" = "V14")

# Read the list of ASVs found in multiple environments
overlapping_ASVs <- read.csv("~/Documents/ciliate_niche/trait_extraction/overlapping_all.list", sep = "\t", header = FALSE)

# Create new column for only the amplicon
overlapping_ASVs[c('Amplicon', 'ASV')] <- str_split_fixed(overlapping_ASVs$V1, '_', 2)
metadata[c("Amplicon", "rest")] <- str_split_fixed(metadata$ASV, ';', 2)

# Remove the Amplicons found in multiple environments from the metadata
metadata_trimmed <- metadata[!(metadata$Amplicon %in% overlapping_ASVs$Amplicon),]

# Remove the new columns we made
metadata_trimmed <- metadata_trimmed[1:14]

# Write the file
write_tsv(metadata_trimmed, "metadata_soil.tsv")

# Marine ----
#____________
## Read metadata file
metadata <- read.csv("~/Documents/ciliate_niche/trait_extraction/raw_data/metadata_marine_reduced", sep="\t", header=FALSE)                     

## Rename columns
metadata <- metadata %>% 
  rename("ASV" = "V1",
         "sample" = "V2",
         "abundance" = "V3",
         "latitude" = "V4",
         "longitude" = "V5",
         "depth" = "V6",
         "altitude" = "V7",
         "collection_date" = "V8",
         "biome" = "V9",
         "feature" = "V10",
         "material" = "V11",
         "raw_env" = "V12",
         "temperature" = "V13",
         "salinity" = "V14")

# Read the list of ASVs found in multiple environments
overlapping_ASVs <- read.csv("~/Documents/ciliate_niche/trait_extraction/raw_data/overlapping_all.list", sep = "\t", header = FALSE)

# Create new column for only the amplicon
overlapping_ASVs[c('Amplicon', 'ASV')] <- str_split_fixed(overlapping_ASVs$V1, '_', 2)
metadata[c("Amplicon", "rest")] <- str_split_fixed(metadata$ASV, ';', 2)

# Remove the Amplicons found in multiple environments from the metadata
metadata_trimmed <- metadata[!(metadata$Amplicon %in% overlapping_ASVs$Amplicon),]

# Remove the new columns we made
metadata_trimmed <- metadata_trimmed[1:14]

# Write the file
write_tsv(metadata_trimmed, "metadata_marine.tsv")

# Freshwater ----
#________________
## Read metadata file
metadata <- read.csv("~/Documents/ciliate_niche/trait_extraction/raw_data/metadata_freshwater_reduced", sep="\t", header=FALSE)                     

## Rename columns
metadata <- metadata %>% 
  rename("ASV" = "V1",
         "sample" = "V2",
         "abundance" = "V3",
         "latitude" = "V4",
         "longitude" = "V5",
         "depth" = "V6",
         "altitude" = "V7",
         "collection_date" = "V8",
         "biome" = "V9",
         "feature" = "V10",
         "material" = "V11",
         "raw_env" = "V12",
         "temperature" = "V13",
         "salinity" = "V14")

# Read the list of ASVs found in multiple environments
overlapping_ASVs <- read.csv("~/Documents/ciliate_niche/trait_extraction/raw_data/overlapping_all.list", sep = "\t", header = FALSE)

# Create new column for only the amplicon
overlapping_ASVs[c('Amplicon', 'ASV')] <- str_split_fixed(overlapping_ASVs$V1, '_', 2)
metadata[c("Amplicon", "rest")] <- str_split_fixed(metadata$ASV, ';', 2)

# Remove the Amplicons found in multiple environments from the metadata
metadata_trimmed <- metadata[!(metadata$Amplicon %in% overlapping_ASVs$Amplicon),]

# Remove the new columns we made
metadata_trimmed <- metadata_trimmed[1:14]

# Write the file
write_tsv(metadata_trimmed, "metadata_freshwater.tsv")

