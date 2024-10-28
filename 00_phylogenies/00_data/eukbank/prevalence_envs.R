################################################################################
#               Ciliate ASVs prevalence in different environments              #
################################################################################

# In this Rscript, we calculate how prevalent ciliate ASVs are in the following environmnets:
## marine pelagic 
## marine benthic
## freshwater 
## soil 
## inland saline/hypersaline
## animal-associated

# This information will be used to plot a stacked barplot around the ciliate ASV phylogeny.

## set working directory
setwd("Ciliate-niche-evolution/00_phylogenies/00_data/eukbank/")

## Load packages
library("dplyr")
library("tidyr")
library("stringr")


## 1. Add read counts (nreads) information to ciliate metadata file.
### read metadata file
metadata <- read.csv("metadata_ciliates_env.csv", header = TRUE, sep = ",")

### read counts file
counts <- read.csv("ciliate_asvs_V4_counts.tsv", header = TRUE, sep = "\t")

### join the two dataframes
meta_counts <- counts %>% inner_join(metadata, by=c("amplicon","sample"))


## 2. Get total number of ciliate reads per sample.
meta_counts <- meta_counts %>%
  group_by(sample) %>%
  mutate(total_nreads = sum(nreads))


## 3. Get relative abundance (among ciliates) per sample.
meta_counts <- meta_counts %>%
  mutate(rel_ab = nreads / total_nreads)


## 4. For each ASV, get average relative abundance per environment
df <- meta_counts %>%
  group_by(ASV, env) %>%
  summarize(avg_rel_ab = mean(rel_ab)) %>%
  pivot_wider(names_from = env, values_from = avg_rel_ab)

### replace NAs with 0
df <- df %>% replace(is.na(.), 0)


## 5. Calculate sum of relative abundances
df <- df %>%
  mutate(sum_average = rowSums(across(where(is.numeric))))


## 6. Calculate prevalence in each habitat
df <- df %>%
  mutate(av_ratio_marine_pelagic = (`Marine pelagic` / sum_average)*100) 

df <- df %>%
  mutate(av_ratio_marine_benthic = (`Marine benthic` / sum_average)*100) 

df <- df %>%
  mutate(av_ratio_soil = (Soil / sum_average)*100) 

df <- df %>%
  mutate(av_ratio_freshwater = (Freshwater / sum_average)*100) 

df <- df %>%
  mutate(av_ratio_animal = (`Animal-associated` / sum_average)*100)  

df <- df %>%
  mutate(av_ratio_saline_hypersaline = (`Inland saline-hypersaline` / sum_average)*100)


## 7. Add taxonomy
### Create new column called Group which uses the string after the last underscore in each ASV name
df$Group <- sub(".*_", "", df$ASV)

### Replace empty cells with NA
df[df==""] <- NA

### We follow Rajter et al 2021 and assign several groups to other groups
df$Group[df$Group == 'Cariacotrichea'] <- 'Armophorea'
df$Group[df$Group == 'Licnophora'] <- 'Spirotrichea'
df$Group[df$Group == 'Mesodiniidae'] <- 'Litostomatea'
df$Group[df$Group == 'Microthoracida'] <- 'Nassophorea'
df$Group[df$Group == 'Nassulida'] <- 'Nassophorea'
df$Group[df$Group == 'Odontostomatea'] <- 'Armophorea'
df$Group[df$Group == 'Paraspathidium'] <- 'Prostomatea'


## 8. Add total number of samples for each ASV
df$Num_Samples <- as.numeric(sub(".*_samples_(\\d+)_size_.*", "\\1", df$ASV))


## 9. Write metadata file with quantitative prevalence in envs
## Write metadata file for ciliates (quantitative)
df <- df %>% select(1, 9:16)

write.table(df, file = "ciliate_env_prevalence.tsv", quote = FALSE, sep = "\t", row.names = FALSE)


## 10. Generate metadata file with qualitative metadata on habitat
df_qual <- df 
df_qual[, 2:7] <- lapply(df_qual[, 2:7], function(x) ifelse(x > 0, "present", "absent"))

colnames(df_qual)

colnames(df_qual)=c("ASV","marine_pelagic","marine_benthic","soil","freshwater","animal-associated","saline-hypersaline", "Group", "Num_Samples")

write.table(df_qual, file = "ciliate_env_presence.tsv", quote = FALSE, sep = "\t", row.names = FALSE)


## 11. Get list of soil and marine-pelagic ciliates
## ASVs are assumed to be belong to a habitat if 75% of the signal comes from that habitat

marine <- df %>%
  filter(av_ratio_marine_pelagic >= 75) %>%
  select(1)

write.table(marine, file = "marine_pelagic_ASVs.list", quote = FALSE, sep = "\t", row.names = FALSE)


soil <- df %>%
  filter(av_ratio_soil >= 75) %>%
  select(1)

write.table(soil, file = "soil_ASVs.list", quote = FALSE, sep = "\t", row.names = FALSE)


## 12. Create an UpSet plot to visualise how many ASVs are shared between environments

upset_data <- df_qual

# Convert presence/absence into binary format (1 = present, 0 = absent)
upset_data$marine_pelagic <- ifelse(upset_data$marine_pelagic == "present", 1, 0)
upset_data$marine_benthic <- ifelse(upset_data$marine_benthic == "present", 1, 0)
upset_data$soil <- ifelse(upset_data$soil == "present", 1, 0)
upset_data$freshwater <- ifelse(upset_data$freshwater == "present", 1, 0)
upset_data$`animal-associated` <- ifelse(upset_data$`animal-associated` == "present", 1, 0)
upset_data$`saline-hypersaline` <- ifelse(upset_data$`saline-hypersaline` == "present", 1, 0)

# Select only the binary habitat columns for the UpSet plot
upset_data <- upset_data[, c("marine_pelagic", "marine_benthic", "soil", "freshwater", "animal-associated", "saline-hypersaline")]

colnames(upset_data)=c("marine_pelagic","marine_benthic","soil","freshwater","animal_associated","saline_hypersaline")

## convert to dataframe as using a tibble gives an error
upset_data <- as.data.frame(upset_data)

# Generate the UpSet plot
upset(upset_data, 
      sets = c("marine_pelagic", "marine_benthic", "soil", "freshwater", "animal_associated", "saline_hypersaline"),
      nsets = 6,
      order.by = "freq", # Orders intersections by frequency
      empty.intersections = "on") # Show all combinations, even those with zero counts

