###############################################################################
#                     Rscript Traits-Marine Niche Evolution                   #
###############################################################################

# Setup ----
#___________
library(dplyr)
library(plyr)

## set working directory
setwd("C:/Users/path/to/directory")

# Prepare metadata ----
#______________________
## Read metadata
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


# Create a dataframe to add values ----
#______________________________________
traits_marine<- metadata %>%
  dplyr::select(sample, ASV)


# Add traits from WOA ----
#_________________________
WOA<-read_tsv("WOA/WOA.tsv")
traits_marine<-merge(traits_marine, WOA[c("sample", "nitrate", "AOU", "DO", "phosphate", "POS", "silicate", "temperature")], by="sample")

# Add traits from GMED ----
#__________________________
GMED<-read_tsv("GMED/GMED.tsv")
traits_marine<-merge(traits_marine, GMED[, c("sample", "chla_mean", "par", "pic", "poc", "primprod", "tsm", "ph")], by="sample")

# Group by ASVs and calculate mean values ----
#________________________________________
traits_marine <- traits_marine %>%
  group_by(ASV) %>%
  summarise_at(vars(-group_cols()), mean, na.rm = TRUE)

## Remove the sample column
traits_marine <- traits_marine[-2]

# Add taxon ----
#______________________________
## Load file with ASV and taxon
group<-read_tsv("eukbank_ciliate_marine_ASV.list", col_names = FALSE)
colnames(group)[1]<-"ASV"
colnames(group)[3]<-"taxon"

## Add to traits file
traits_marine<-merge(traits_marine, group, by.x = "ASV", by.y = "ASV")

## Replace ASV column with one that matches the ASV information on our trees
traits_marine <- traits_marine[-1]
colnames(traits_marine)[15]<-"ASV"
traits_marine<-traits_marine %>%
  relocate(ASV, 1) %>%
  relocate(taxon, .after=1)

# Rename taxa ----
#_________________
## Check which unique taxa we have 
unique<-as.data.frame(unique(traits_marine$taxon))

## Rename taxa from undergroup to main group
traits_marine$taxon[traits_marine$taxon=="Discotrichidae"]<-"CONthreeP"
traits_marine$taxon[traits_marine$taxon=="Protocruzia"]<-"Intramacronucleata"
traits_marine$taxon[traits_marine$taxon=="Cyclotrichium"]<-"CONthreeP"
traits_marine$taxon[traits_marine$taxon=="Pseudotrachelocerca"]<-"CONthreeP"
traits_marine$taxon[traits_marine$taxon=="Licnophora"]<-"Spirotrichea"
traits_marine$taxon[traits_marine$taxon=="Paraspathidium"]<-"Prostomatea"
traits_marine$taxon[traits_marine$taxon=="Nassulida"]<-"Nassophorea"
traits_marine$taxon[traits_marine$taxon=="Kiitrichidae"]<-"Spirotrichea"
traits_marine$taxon[traits_marine$taxon=="Mesodiniidae"]<-"Litostomatea"
traits_marine$taxon[traits_marine$taxon=="Microthoracida"]<-"Nassophorea"

# Write file ----
#________________
write_tsv(traits_marine, "traits_marine.tsv")

# OPTIONAL - Make a file that is ordered by ASV to see if identical ASVs are found in different samples ----
#________________________________________________________________________________________________
traits_marine_ordered<-traits_marine[order(traits_marine$ASV),]
