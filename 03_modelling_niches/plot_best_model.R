###############################################################################
#                       Rscript Best Model Niche Evolution                    #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 26.05.2024
# Version 1
#=================#

# Setup
## Load packages
library(data.table)
library(dplyr)
library(readxl)
library(ggplot2)
library(stringr)
library(tidyverse)

## Set working directory
setwd()


# Load data ----
#_______________
### Make sure data is a dataframe with the four first columns named
### "LB", "BM", "OU" and "EB" with corresponding values. The remaining columns 
### should be "tree", "r" (from the ddexp analysis), "trait" and "group"

# Get the best model and significance ----
#_________________________________________
### If the r-value is negative and LB has the lowest value, we want to assign it 
### to EB instead. Results are significant if the difference between the two 
### lowest scores is above two points, and insiginificant if it is below two points. 

## Make a function to get the best model and significance
get_min_column <- function(row, r_value) {
  min_val <- min(row) # finds the column with lowest value
  min_col <- names(row)[which(row == min_val)] # finds the name of the column with lowest value
  
  # Find the second lowest value
  row_without_min <- row[row != min_val]
  second_min_val <- min(row_without_min)
  
  # Check if the difference between the lowest and second lowest is greater than 2
  significance <- ifelse(second_min_val - min_val > 2, "Significant", "Not significant")
  
  # Check if "r" is negative and "LB" has the lowest value. If this is true, assign best_model to EB instead
  if (r_value < 0 && "LB" %in% min_col) {
    return(c("EB", significance))
  }
  # Get the best model and significance
  return(c(min_col, significance))
}

## Create an empty data frame to store the results. Original data is "df". 
results <- data.frame(best_model = character(nrow(df)),
                      significance = character(nrow(df)))

## Loop through each row of df and find best model and significance
for (i in 1:nrow(df)) {
  # Get the row to compare
  row_to_compare <- df[i, 1:4] # compare the columns "LB", "BM", "OU" and "EB"
  # Get the corresponding value in the "r" column
  r_column_value <- df$r[i]
  # Call get_min_column for the current row and r_column_value
  result <- get_min_column(row_to_compare, r_column_value)
  # Assign the result to the corresponding row in the results data frame
  results[i, ] <- result
}

## Add the results to the original data frame, df
df$best_model <- results$best_model
df$significance <- results$significance

## Group by 'clade' and then count the number of occurrences of each 'best_model'
count_per_clade <- df %>%
  group_by(group, best_model) %>%
  summarise(count = n()) %>%
  ungroup()

## Count only unique 'best_model' per 'clade'
unique_count_per_clade <- df %>%
  distinct(group, best_model) %>%
  group_by(group) %>%
  summarise(count = n()) %>%
  ungroup()

# Make plot for traits ----
#__________________________
## Define a function to get labels in the plot to be on multiple lines
wrap_labels <- function(labels, multi_line = TRUE) {
  if (multi_line) {
    str_wrap(labels, width = 10)  
  } else {
    labels
  }
}

## Make a plot for soil traits
soil_traits <- ggplot(df_soil, aes(x = group, y = 1, fill = best_model)) + # Plot best model for each group
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = best_model), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  facet_wrap(~trait, labeller = as_labeller(wrap_labels)) + # Order by trait. Have the labels on multiple lines
  scale_fill_manual(values = c("#fdc086", "#ffff99", "#beaed4", "#7fc97f", "gray")) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15), # Have the x-axis labels at 90 degree angle
    strip.text.x = element_text(size = 20), 
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks on y-axis
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1 on y-axis
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black"))) # Make a black outline around the legend box

## Make a plot for marine traits
marine_traits <- ggplot(df_marine, aes(x = group, y = 1, fill = best_model)) + # Plot best model for each group
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = best_model), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  facet_wrap(~trait, labeller = as_labeller(wrap_labels)) + # Order by trait. Have the labels on multiple lines
  scale_fill_manual(values = c("#fdc086", "#ffff99", "#beaed4", "#7fc97f", "gray")) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15), # Have the x-axis labels at 90 degree angle
    strip.text.x = element_text(size = 20),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks on y-axis
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1 on y-axis
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black"))) # Make a black outline around legend box

## Combine the plots 
combined_traits <- soil_traits / marine_traits +
  plot_layout(ncol = 2)

## Add annotations with a and b
combined_traits +
  plot_annotation(tag_levels = 'a')

# Make plot for clades ----
#__________________________
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

## Make soil plot
soil_plot <- ggplot(df_soil, aes(x = trait, y = 1, fill = best_model)) + # Plot best model for each trait
  geom_blank() +
  ylab("Proportions")+
  geom_bar(aes(fill = best_model), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  facet_wrap(~group) + # Order by group
  scale_fill_manual(values = c("#ffff99", "#fdc086", "#beaed4", "#7fc97f")) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15), # Have the x-axis labels at 90 degree angle
    strip.text.x = element_text(size = 20),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks on y-axis
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1 on y-axis
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black"))) # Make a black outline around legend box

## Make marine plot
marine_plot <- ggplot(marine, aes(x = trait, y = 1, fill = best_model)) + # Plot best model for each trait
  geom_blank() +
  geom_bar(aes(fill = best_model), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  ylab("Proportions")+
  theme_minimal() +
  facet_wrap(~group) + # Order by group
  scale_fill_manual(values = c("#ffff99", "#fdc086", "#beaed4", "#7fc97f")) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15), # Have the x-axis labels at 90 degree angle
    strip.text.x = element_text(size = 20),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 15)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks on y-axis
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1 on y-axis
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black"))) # Make a black outline around legend box

## Combine the plots
combined_plots <- soil_plot / marine_plot +
  plot_layout(ncol = 1)

## Add annotations with a and b
combined_plots +
  plot_annotation(tag_levels = 'a')

# Plot the significance ----
#___________________________
## Make soil plot
soil_significance <- ggplot(df_soil, aes(x = trait, y = 1, fill = significance)) + # Plot significance for each trait
  geom_blank() +
  geom_bar(aes(fill = significance), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  ylab("Proportions")+
  theme_minimal() +
  facet_wrap(~group) + # Order by group
  scale_fill_manual(values = c("#8da0cb", "#66c2a5")) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15), # Have the x-axis labels at 90 degree angle
    strip.text.x = element_text(size = 15),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 10)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks on y-axis
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1 on y-axis
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black"))) # Make a black outline around legend box

## Make marine plot
marine_significance <- ggplot(marine, aes(x = trait, y = 1, fill = significance)) +
  geom_blank() +
  geom_bar(aes(fill = significance), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  ylab("Proportions")+
  theme_minimal() +
  facet_wrap(~group) +
  scale_fill_manual(values = c("#8da0cb", "#66c2a5")) +
  theme(
    axis.title.y = element_text(),
    axis.text.y = element_text(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray", linetype = "solid"),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 15),
    strip.text.x = element_text(size = 15),
    legend.title = element_blank(),
    legend.key.size = unit(2, "lines"),  # Increase size of legend box
    legend.text = element_text(size = 15),
    text = element_text(size = 10)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 1/5),  # Define breaks
    labels = seq(0, 1, by = 1/5)   # Define labels as 0 and 1
  ) +
  guides(fill = guide_legend(override.aes = list(color = "black")))

## Combine the plots
combined_significance <- soil_significance / marine_significance +
  plot_layout(ncol = 1)

## Add annotation level
combined_significance +
  plot_annotation(tag_levels = 'a') +
  plot_layout(guides = "collect") 
