###############################################################################
#                   	       Rscript Plot Mantel 	                            #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 17.03.2024
# Version 1
#=================#

# Setup ----
#___________
## Load libraries
library(data.table)
library(dplyr)
library(ggplot2)
library(stringr)
library(tidyverse)

## Set working directory
setwd()

# Read data ----
#_______________
### Make sure to have the following columns: Mantel_r, group (clades), pval3 (two-tailed probability, null hypothesis: R=0), trait

# Add a new column 'signal' based on conditions
data$signal <- ifelse(data$pval3 <= 0.01 & data$pval3 > 0,
                    "Significant positive phylogenetic signal",
                    ifelse(data$pval3 < 0.01 & data$pval3 < 0,
                           "Significant negative phylogenetic signal",
                           "No significant phylogenetic signal"))

# Plot values for clades ----
#____________________________
## Make soil plot
soil_values_clades <- df_soil %>%
  mutate(class = fct_reorder(group, Mantel_r, .fun='mean' )) %>% # Calculate mean mantel R per group
  ggplot(aes(x=reorder(group, -Mantel_r), y = Mantel_r)) + # Plot mean Mantel R per group in decresing order
  ylim(-0.15,0.3)+
  geom_boxplot(fill = "#d04848") +
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 20),
        axis.title.y = element_text(size = 30)) +
  xlab("") +
  ylab("R-value")


## Make marine plot
marine_values_clades <- df_marine %>%
  mutate(class = fct_reorder(group, Mantel_r, .fun='mean' )) %>% # Calculate mean mantel R per group
  ggplot(aes(x= reorder(group, -Mantel_r), y=Mantel_r) + # Plot mean mantel R per group in decreasing order
  ylim(-0.15,0.4)+
  geom_boxplot(fill = "#0571b1") +
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 20),
        axis.title.y = element_text(size = 30)) +
  xlab("") +
  ylab("R-value")

## Combine the plots
combined_clades <- soil_values_clades / marine_values_clades +
  plot_layout(ncol = 1)

## Add annotations a and b
combined_clades +
  plot_annotation(tag_levels = 'a')


# Plot values for traits ----
#____________________________
## Colors for soil
trait_colors_soil <- c("#d04848", "#fb9a99", "#fb9a99", "#d04848", "#d04848",
                  "#d04848", "#d04848", "#d04848", "#d04848", "#d04848",
                  "#d04848", "#d04848", "#d04848") 

## Make soil plot
soil_values_traits <- df_soil %>%
  mutate(class = fct_reorder(trait, Mantel_r, .fun='mean' )) %>% # Calculate mean mantel R per trait
  ggplot(aes(x=reorder(trait, -Mantel_r), y = Mantel_r)) + # Plot mean mantel R per trait in decresing order
  ylim(-0.15,0.25)+
  geom_boxplot(aes(fill = trait), color = "black") +  
  scale_fill_manual(values = trait_colors_soil) +  
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 15, angle = 90, vjust = 0.5, hjust = 1),
        axis.title.y = element_text(size = 30)) +
  xlab("") +
  ylab("R-value")

## Colors for marine
trait_colors_marine <- c("#0571b1", "#0571b1", "#0571b1","#0571b1", "#0571b1", "#a6cee3",
                  "#0571b1", "#0571b1", "#0571b1", "#0571b1", "#0571b1", "#0571b1",
                  "#0571b1", "#0571b1", "#0571b1", "#0571b1")

## Make marine plot
marine_values_traits <- df_marine %>%
  mutate(class = fct_reorder(trait, Mantel_r, .fun='mean' )) %>% # Calculate mean mantel R per trait
  ggplot(aes(x=reorder(trait, -Mantel_r), y = Mantel_r)) + # Plot mean mantel R per trait in decresing order
  ylim(-0.15,0.4)+
  geom_boxplot(aes(fill = trait), color = "black") +  
  scale_fill_manual(values = trait_colors_marine) +  
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 15, angle = 90, vjust = 0.5, hjust = 1),
        axis.title.y = element_text(size = 30))+
  xlab("") +
  ylab("R-value")


## Combine plots
combined_traits <- plot_grid(soil_values_traits, marine_values_traits, ncol = 1)

## Add annotations
combined_traits +
  plot_annotation(tag_levels = 'a')


# Make significance plot for traits ----
#_______________________________________
## Make a function to have labels on multiple lines
wrap_labels <- function(labels, multi_line = TRUE) {
  if (multi_line) {
    str_wrap(labels, width = 10)  
  } else {
    labels
  }
}

## Make soil plot
soil_traits <- ggplot(df_soil, aes(x = group, y = 1, fill = signal)) + # Plot signal per group
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = signal), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  facet_wrap(~trait, labeller = as_labeller(wrap_labels)) +  # Group by trait, have labels on multiple lines
  scale_fill_manual(values = c("#8da0cb", "#66c2a5", "#fc8d62"),
                    labels = function(x) str_wrap(x, width = 15)) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15),
    strip.text.x = element_text(size = 20),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black")))

## Make marine plot
marine_traits <- ggplot(df_marine, aes(x = group, y = 1, fill = signal)) + # Plot signal per group
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = signal), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  facet_wrap(~trait, labeller = as_labeller(wrap_labels)) +  # Group by trait, have labels on multiple lines
  scale_fill_manual(values = c("#8da0cb", "#66c2a5", "#fc8d62"),
                    labels = function(x) str_wrap(x, width = 15)) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15),
    strip.text.x = element_text(size = 20),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black")))

## Combine the plots
combined_traits <- soil_traits / marine_traits +
  plot_layout(ncol = 2)

## Add annotations a and b
combined_traits +
  plot_annotation(tag_levels = 'a') +
  plot_layout(guides = "collect")

# Make significance plots for clades ----
#________________________________________
## Add ASV number to clade
df_marine$group <- str_replace(df_marine$group, "\\bColpodea\\b", "Colpodea (N = 67)")
df_marine$group <- str_replace(df_marine$group, "\\bLitostomatea\\b", "Litostomatea (N = 218)")
df_marine$group <- str_replace(df_marine$group, "\\bOligohymenophorea\\b", "Oligohymenophorea (N = 1317)")
df_marine$group <- str_replace(df_marine$group, "\\bPhyllopharyngea\\b", "Phyllopharyngea (N = 1156)")
df_marine$group <- str_replace(df_marine$group, "\\bSpirotrichea\\b", "Spirotrichea (N = 2561)")
df_marine$group <- str_replace(df_marine$group, "\\bProstomatea\\b", "Prostomatea (N = 219)")

df_soil$group <- str_replace(df_soil$group, "\\bColpodea\\b", "Colpodea (N = 1180)")
df_soil$group <- str_replace(df_soil$group, "\\bLitostomatea\\b", "Litostomatea (N = 551)")
df_soil$group <- str_replace(df_soil$group, "\\bNassophorea\\b", "Nassophorea (N = 69)")
df_soil$group <- str_replace(df_soil$group, "\\bOligohymenophorea\\b", "Oligohymenophorea (N = 507)")
df_soil$group <- str_replace(df_soil$group, "\\bPhyllopharyngea\\b", "Phyllopharyngea (N = 141)")
df_soil$group <- str_replace(df_soil$group, "\\bSpirotrichea\\b", "Spirotrichea (N = 492)")

## Make plot for soil
soil_plot <- ggplot(df_soil, aes(x = trait, y = 1, fill = signal)) + # Plot signal per trait
  geom_blank() +
  ylab("Proportions")+
  geom_bar(aes(fill = signal), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  facet_wrap(~group) +  # Group by clade
  scale_fill_manual(values = c("#8da0cb", "#66c2a5", "#fc8d62"),
                    labels = function(x) str_wrap(x, width = 15)) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15),
    strip.text.x = element_text(size = 20),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black")))

## Make marine plot
marine_plot <- ggplot(df_marine, aes(x = trait, y = 1, fill = signal)) + # Plot signal per trait
  geom_blank() +
  geom_bar(aes(fill = signal), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  ylab("Proportions")+
  theme_minimal() +
  facet_wrap(~group) +  # Group by clade
  scale_fill_manual(values = c("#8da0cb", "#66c2a5", "#fc8d62"),
                    labels = function(x) str_wrap(x, width = 15)) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15),
    strip.text.x = element_text(size = 20),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black")))

## Combine the plots
combined_plots <- soil_plot / marine_plot +
  plot_layout(ncol = 1)

## Add annotations a and b
combined_plots +
  plot_annotation(tag_levels = 'a')



