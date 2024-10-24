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
setwd("~/Documents/OneDrive/Postdoc/Projects/Ciliate-niche-evolution/00_phylogenies/00_data/eukbank/")

## Load packages
library("dplyr")
library("tidyr")


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
taxo <- read.csv("asvs_group.tsv", header = TRUE, sep = "\t")

df <- df %>% inner_join(taxo, by="ASV")


## 8. Write metadata file with quantitative prevalence in envs
## Write metadata file for ciliates (quantitative)
df <- df %>% select(1, 9:15)

write.table(df, file = "ciliate_env_prevalence.tsv", quote = FALSE, sep = "\t", row.names = FALSE)


## 9. Generate metadata file with qualitative metadata on habitat
df_qual <- df %>%
  mutate(across(where(is.numeric), ~ ifelse(. == 0, "absent", "present")))

colnames(df_qual)

colnames(df_qual)=c("ASV","marine_pelagic","marine_benthic","soil","freshwater","animal-associated","saline-hypersaline", "Group")

write.table(df_qual, file = "ciliate_env_presence.tsv", quote = FALSE, sep = "\t", row.names = FALSE)


## 9. Get list of soil and marine-pelagic ciliates
## ASVs are assumed to be belong to a habitat if 75% of the signal comes from that habitat

marine <- df %>%
  filter(av_ratio_marine_pelagic >= 75) %>%
  select(1)

write.table(marine, file = "marine_pelagic_ASVs.list", quote = FALSE, sep = "\t", row.names = FALSE)


soil <- df %>%
  filter(av_ratio_soil >= 75) %>%
  select(1)

write.table(soil, file = "soil_ASVs.list", quote = FALSE, sep = "\t", row.names = FALSE)
