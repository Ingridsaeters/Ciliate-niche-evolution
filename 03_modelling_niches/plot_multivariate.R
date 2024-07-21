###############################################################################
#                       Rscript Plot multivariate                             #
###############################################################################

#=================#
# Ingrid Sætersdal
# Niche Evolution 
# EDGE group, Natural history museum, University of Oslo
# 17.03.2024
# R v. 4.2.2
# Version 1
#=================#

# Setup ----
#___________
## Load packages
library(tidyverse)
library(ggplot2)
library(dplyr)

## Set working directory
setwd()

# Load data for mantel and lambda for terrestrial and marine ciliates

# Plot Mantel R values ----
#__________________________
# Make soil plot
soil_plot <- mantel_soil %>%
  mutate(class = fct_reorder(group, Mantel_r, .fun='mean' )) %>%
  ggplot(aes(x=reorder(group, -Mantel_r), y=Mantel_r, fill = environment)) +
  ylim(-0.05,0.075)+
  geom_boxplot() +
  scale_fill_manual(values = c("#fdc086", "#7fc97f"))+
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 15, angle = 90),
        axis.text.y = element_text(size = 30),
        text = element_text(size = 15),
        title = element_text(size = 30),
        axis.title.y = element_text(size = 30)) +
  xlab("") +
  ylab("R-value")+
  ggtitle("Terrerstrial")

# Make marine plot
marine_plot <- mantel_marine %>%
  mutate(class = fct_reorder(group, Mantel_r, .fun='mean' )) %>%
  ggplot(aes(x=reorder(group, -Mantel_r), y=Mantel_r)) +
  ylim(0,0.1)+
  geom_boxplot(fill = "#beaed4") +
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 15, angle = 90),
        axis.text.y = element_text(size = 30),
        text = element_text(size = 15),
        title = element_text(size = 30),
        axis.title.y = element_text(size = 30)) +
  xlab("") +
  ylab("R-value")+
  ggtitle("Marine")

# Combine the plots
combined <- soil_plot / marine_plot +
  plot_layout(ncol = 2)
# Make annotations a and b
combined +
  plot_annotation(tag_levels = 'a')


# Plot lambda values  ----
#___________________________________
## Make soil plot
soil_plot <- lambda_soil %>%
  mutate(class = fct_reorder(group, lambda, .fun='mean' )) %>%
  ggplot(aes(x=reorder(group, -lambda), y=lambda, fill = environment)) +
  ylim(0,1)+
  geom_boxplot() +
  scale_fill_manual(values = c("#fdc086", "#7fc97f"))+
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 15, angle = 90),
        axis.text.y = element_text(size = 30),
        text = element_text(size = 15),
        title = element_text(size = 30),
        axis.title.y = element_text(size = 30)) +
  xlab("") +
  ylab("Pagel's λ")+
  ggtitle("Terrestrial")

# Make marine plot
marine_plot <- lambda_marine %>%
  mutate(class = fct_reorder(group, lambda, .fun='mean' )) %>%
  ggplot(aes(x=reorder(group, -lambda), y=lambda)) +
  ylim(0,1)+
  geom_boxplot(fill = "#beaed4") +
  theme_minimal() +
  theme(legend.position="none",
        axis.text.x = element_text(size = 15, angle = 90),
        axis.text.y = element_text(size = 30),
        text = element_text(size = 15),
        title = element_text(size = 30),
        axis.title.y = element_text(size = 30)) +
  xlab("") +
  ylab("Pagel's λ")+
  ggtitle("Marine")

# Combine the plots
combined <- soil_plot / marine_plot +
  plot_layout(ncol = 2)

# Add annotations c and d
combined +
  plot_annotation(tag_levels = list(c("c", "d")))

# Make significance plot ----
#____________________________
## Add a new column 'signal' based on conditions
mantel_soil$P <- ifelse(mantel_soil$pval3 <= 0.01 & mantel_soil$pval3 > 0,
                 "Significant positive phylogenetic signal",
                 ifelse(mantel_soil$pval3 < 0.01 & mantel_soil$pval3 < 0,
                        "Significant negative phylogenetic signal",
                        "No significant phylogenetic signal"))

mantel_marine$P <- ifelse(mantel_marine$pval3 <= 0.01 & mantel_marine$pval3 > 0,
                 "Significant positive phylogenetic signal",
                 ifelse(mantel_marine$pval3 < 0.01 & mantel_marine$pval3 < 0,
                        "Significant negative phylogenetic signal",
                        "No significant phylogenetic signal"))

lambda_soil <- lambda_soil %>%
  mutate(signal = ifelse(P < 0.01, "Significant phylogenetic signal", "No significant phylogenetic signal"))

lambda_marine <- lambda_marine %>%
  mutate(signal = ifelse(P < 0.01, "Significant phylogenetic signal", "No significant phylogenetic signal"))

# Make mantel plot for soil
soil_mantel <-  ggplot(mantel_soil, aes(x = group, y = 1, fill = P)) +
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = P), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
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
  guides(fill = guide_legend(override.aes = list(color = "black")))+
  ggtitle("Terrestrial")

# Make mantel plot for marine
marine_mantel <-  ggplot(mantel_marine, aes(x = group, y = 1, fill = P)) +
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = P), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  scale_fill_manual(values = c("#66c2a5", "#8da0cb", "#fc8d62"),
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
  guides(fill = guide_legend(override.aes = list(color = "black")))+
  ggtitle("Marine")

## Make lambda plot for soil
soil_lambda <-  ggplot(lambda_soil, aes(x = group, y = 1, fill = signal)) +
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = signal), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  scale_fill_manual(values = c("#66c2a5", "#8da0cb", "#fc8d62"),
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
  guides(fill = guide_legend(override.aes = list(color = "black")))+
  ggtitle("Terrestrial")

## Make lambda plot for marine
marine_lambda <-  ggplot(lambda_marine, aes(x = group, y = 1, fill = signal)) +
  geom_blank() +
  ylab("Proportions") +
  geom_bar(aes(fill = signal), stat = "identity", position = "fill") +
  xlab(element_blank()) +
  theme_minimal() +
  scale_fill_manual(values = c("#66c2a5", "#8da0cb", "#fc8d62"),
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
  guides(fill = guide_legend(override.aes = list(color = "black")))+
  ggtitle("Marine")

## Combine the plots 
combined <- soil_mantel / marine_mantel / soil_lambda / marine_lambda +
  plot_layout(ncol = 2)

## Add annotations a-d
combined +
  plot_annotation(tag_levels = 'a')


