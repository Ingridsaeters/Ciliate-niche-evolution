###############################################################################
#                             Rscript Shared ASVs                             #
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
## Load packages
library(ggplot2)
library(dplyr)
library(hrbrthemes)
library(tidyr)

setwd()

data <- read_tsv("datafile.tsv")

# Make a dataframe with values for the barplot
bar_data <- data.frame(
  Category = c("Marine", "Terrestrial", "Freshwater", "Freshwater and Terrestrial", 
               "Freshwater and Marine", "Freshwater, Terrestrial and Marine", "Terrestrial and Marine"),
  Count = c(10810, 2206, 1297, 530, 194, 175, 153)
)

# Reorder Category based on Count
bar_data$Category <- factor(bar_data$Category, levels = bar_data$Category[order(-bar_data$Count)])

# Make a datafram for the dot plot
dot_data <- data.frame(
  Category = c("Marine", "Terrestrial", "Freshwater", 
               "Freshwater and Terrestrial", "Freshwater and Marine", 
               "Freshwater, Terrestrial and Marine", "Terrestrial and Marine"),
  Marine = c(1, 0, 0, 0, 1, 1, 1),
  Freshwater = c(0, 0, 1, 1, 1, 1, 0),
  Terrestrial = c(0, 1, 0, 1, 0, 1, 1)
)

# Apply the same ordering to dot_data
dot_data$Category <- factor(dot_data$Category, levels = levels(bar_data$Category))

# Convert dot_data to long format
library(tidyr)
dot_data_long <- pivot_longer(dot_data, cols = -Category, names_to = "Environment", values_to = "Present")
dot_data_long <- dot_data_long[dot_data_long$Present == 1, ]


# Create the bar plot
bar_plot <- ggplot(bar_data, aes(x = Category, y = Count)) +
  geom_bar(stat = "identity", fill = "#8dd3c7") +
  geom_text(aes(label = Count), vjust = -0.5, size = 5) + 
  theme_minimal() +
  theme(axis.text.x = element_blank(), 
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 20),
        axis.title.y = element_text(size = 20),
        axis.title = element_text(size = 25),
        text = element_text(size = 25),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  labs(x = NULL,
       y = "Intersection size")

# Create the dot plot
dot_plot <- ggplot(dot_data_long, aes(x = Category, y = Environment)) +
  geom_point(color = "black", size = 3) +
  geom_rect(aes(xmin = as.numeric(as.factor(Category))-Inf,
                xmax = as.numeric(as.factor(Category))+Inf,
                ymin = 0.5, ymax = 1.5),
            fill = "#e9e9e9", alpha = 0.1) +
  geom_rect(aes(xmin = as.numeric(as.factor(Category))-Inf,
                xmax = as.numeric(as.factor(Category))+Inf,
                ymin = 1.5, ymax = 2.5),
            fill = "#fbfbfb") +
  geom_rect(aes(xmin = as.numeric(as.factor(Category))-Inf,
                xmax = as.numeric(as.factor(Category))+Inf,
                ymin = 2.5, ymax = Inf),
            fill = "#e9e9e9", alpha = 0.1) +
  geom_point(color = "black", size = 3) +
  # Add segments between relevant points
  geom_segment(data = subset(dot_data_long, Category == "Freshwater and Terrestrial"), 
               aes(x = Category, xend = Category, y = "Freshwater", yend = "Terrestrial"), 
               color = "black", lwd = 1) +
  geom_segment(data = subset(dot_data_long, Category == "Freshwater and Marine"), 
               aes(x = Category, xend = Category, y = "Freshwater", yend = "Marine"), 
               color = "black", lwd = 1) +
  geom_segment(data = subset(dot_data_long, Category == "Freshwater, Terrestrial and Marine"), 
               aes(x = Category, xend = Category, y = "Freshwater", yend = "Marine"), 
               color = "black", lwd = 1) +
  geom_segment(data = subset(dot_data_long, Category == "Freshwater, Terrestrial and Marine"), 
               aes(x = Category, xend = Category, y = "Freshwater", yend = "Terrestrial"), 
               color = "black", lwd = 1) +
  geom_segment(data = subset(dot_data_long, Category == "Freshwater, Terrestrial and Marine"), 
               aes(x = Category, xend = Category, y = "Terrestrial", yend = "Marine"), 
               color = "black", lwd = 1) +
  geom_segment(data = subset(dot_data_long, Category == "Terrestrial and Marine"), 
               aes(x = Category, xend = Category, y = "Terrestrial", yend = "Marine"), 
               color = "black", lwd = 1) +
  theme_minimal() +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank(), 
        axis.text.x = element_blank(), axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 20),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  labs(x = NULL, y = NULL)


# Combine the plots
combined_plot <- bar_plot / dot_plot +
  plot_layout(heights = c(3, 1)) # Adjust the relative heights of the plots




