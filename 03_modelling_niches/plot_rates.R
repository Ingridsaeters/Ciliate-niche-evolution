###############################################################################
#                                Rscript Plot rates                           #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 22.02.2024
# Version 1
#=================#

# Setup ----
#___________
## Load libraries
library(scales)
library(ggplot2)
library(tidyverse)
library(ggforce)
library(grid)
library(patchwork)

## Set working directory
setwd()

# Load data ----
#_______________

data <- read.csv("datafile.csv")

### Data should be modified to include the columns "trait", "mean_sig2", "sd", "median", "min", "max"

##  Combine the datasets
combined_data <- rbind(transform(df_soil, dataset = "Soil"),
                       transform(df_marine, dataset = "Marine"))

## Make sure numeric columns are in numeric format
combined_data[2:6] <- lapply(combined_data[2:6], as.numeric)

# Make a plot with values ----
#_____________________________
combined_plot <- ggplot(combined_data) +
  geom_bar(aes(x = reorder(trait, -sig2), y = sig2, fill = dataset),
             stat = "identity", position = position_dodge()) +
    geom_pointrange(aes(x = trait, y = sig2, ymin = sig2 - sd, ymax = sig2 + sd, color = dataset), size = 0.5) +
    scale_fill_manual(values = c("#0571b1", "#d04848")) +
    scale_color_manual(values = c("#a6cee3", "#fb9a99")) +
    theme_minimal() +
    ylim(0, 0.12) +
    theme(axis.text = element_text(size = 10),
          axis.title = element_text(size = 20),
          axis.title.x = element_blank(),
          axis.text.x = element_text(size = 15, angle = 90, hjust = 1, vjust = 0.5),
          axis.text.y = element_text(size = 15),
          text = element_text(size = 15),
          legend.position = "none",
          panel.grid.minor.y = element_blank()) +
    ylab(label = expression(sigma^2))

# Make a plot where POC and Chlorophyll-A are removed, since they are a lot higher than remainig traits, to get a better visualization
combined_data_pruned <- combined_data[!grepl("POC", combined_data$trait),]
combined_data_pruned <- combined_data_pruned[!grepl("Chlorophyll-A", combined_data_pruned$trait),]

combined_plot_pruned <- ggplot(combined_data_pruned) +
  geom_bar(aes(x = reorder(trait, -sig2), y = sig2, fill = dataset),
           stat = "identity", position = position_dodge()) +
  geom_pointrange(aes(x = trait, y = sig2, ymin = sig2 - sd, ymax = sig2 + sd, color = dataset), size = 0.5) +
  scale_fill_manual(values = c("#0571b1", "#d04848")) +
  scale_color_manual(values = c("#a6cee3", "#fb9a99")) +
  theme_minimal() +
  ylim(0, 0.02) +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 20),
        axis.title.x = element_blank(),
        axis.text.x = element_text(size = 15, angle = 90, hjust = 1, vjust = 0.5),
        axis.text.y = element_text(size = 15),
        text = element_text(size = 15),
        legend.position = "none",
        panel.grid.minor.y = element_blank()) +
  ylab(label = expression(sigma^2))

# Combine the two plots
combined <- combined_plot / combined_plot_pruned +
  plot_layout(ncol = 2)

# Add annotations a and b
combined +
  plot_annotation(tag_levels = 'a')
