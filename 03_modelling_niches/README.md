# Modelling niche evolution
## Subtrees for clades
Prune the trees to make subtrees for clades

```
for file in soil_all*; do python ../extract_clade.py "$file" Phyllopharyngea ../soil_clades/Phyllopharyngea."$file"; done;
for file in soil_all*; do python ../extract_clade.py "$file" Colpodea ../soil_clades/Colpodea."$file"; done;
for file in soil_all*; do python ../extract_clade.py "$file" Litostomatea ../soil_clades/Litostomatea."$file"; done;
for file in soil_all*; do python ../extract_clade.py "$file" Oligohymenophorea ../soil_clades/Oligohymenophorea."$file"; done;
for file in soil_all*; do python ../extract_clade.py "$file" Spirotrichea ../soil_clades/Spirotrichea."$file"; done;
```

For some variables (nitrogen, ph, carbon and soil temperature) there isnt any trait information. Make pruned trees to run analyses for these variables. 

We have trait information for 4041 marine pelagic ASVs. Prune the trees to cover these ASVs. 


## Phylogenetic signal
Phylogenetic signal is the tendency of closely related species to have more similar traits than expected by chance. Test this using Pagels lambda and mantel test. 
### Pagels lambda
Pagel's lambda is a model-based test that measures correlations relative to correlations expected under Brownian evolution. A lambda of 0 indicates no phylogenetic signal and a lambda of 1 indicates that the distributions of trait values across the phylogeny is exactly as expected under Brownian Motion, i.e. that the correlation structure among trait values is proportional to the amount of common ancestry for a pair of species. 

Run the script lambda.R to calculate Pagels lambda and the probability that lambda is significantly different from 0. For the multivariate niche, run the script lambda_PC.R. To make a plot with the resulting values run the script plot_lambda.R. 

### Mantel test
The mantel test is a model-free test that examines the correlation between two distance matrices. Apply it to examine the correlation between distance in the phylogenetic trees and distance in trait values, by running the scripts mantel.R and mantel_PC.R. To make a plot with resulting values, run the script plot_mantel.R.

## Mode of niche evolution
### Standard models of evolution: 
- Brownian motion: This is a "random walk" model, because the trait value changes randomly, in both direction and distance, over any time interval.
- Ornstein Uhlenbeck: This model assues that a character is evolving towards an optimal value. The character evolves stochastically according to a drift parameter, and is pulled towards the optimum by the rate of adaption, alpha. Since alpha determines how strongly the character is pulled towards the optimum value, it is often called the "rubber band" parameter.
- Early Burst: This model assumes an initial rapid evolution of the trait value, followed by a reduction of evolutionary rates.
- Late burst: This model assumes rapid evolution after relative stasis/low evolutionary rates. 

### Mode of evolution 
Test the standard models of evolution (Brownian motion, Ornstein Uhlenbeck, Early burst and Late Burst) for each combination of trait and tree, to see which model fits the data best. Use the R scripts model_comparison_BM_OU_EB.R and model_comparison_PC_BM_OU_EB.R to test Brownian Motion, Ornstein Uhlenbeck and Early Burst. Use the R scripts model_comparison_ddexp.R and model_comparison_PC_ddexp.R to test for a Late Burst. ddEXP is an exponential diversity dependant model where evolutionary rates either increase or decrease exponentially with accumulation of species diversity in the clade. Exponential increase can be characterized as "Late Burst", and exponential decrease as "Early Burst". Use the script plot_best_model.R to make a visualization with best model. 

## Rate of evolution 
### Relative evolutionary rates
Normalize the trait values to make evolutionary rates comparable across different niche trait variables, by setting the mean to zero and standard deviation to one for all traits. Then estimate the rate parameter, sigma squared, with the script rates.R. Visualize the results with the script plot_rates.R. 

### Absolute rates
To compare rates in ciliates with estimated rates in plants and animals, repeat the analyses in rates.R with non-normalized trait values. Take the square root of estimated rates to get the rate per million years. 

### Rates within clades
Examine evolutionary rates within clades using evorates.R. 

### Examine the effect of terrestrial sampling bias on inferences of rates - Prune away ASVs randomly
Measure evolutionary rates for subsets of the terrestrial phylogeny to see if the same general patterns are detected. First, shuffle the list of terrestrial ASVs so that they are in random order: 

```
shuf terrestrial_tip_labels.tsv > terrestrial_tip_labels_shuffled.tsv
```

Then make new lists were you have removed percentages. We removed 10, 20, 30, 50 and 70% of ASVs: 

```
sed '1,306d' terrestrial_tip_labels_shuffled.tsv > terrestrial_tip_labels_shuffled_10_percent.tsv
```

Prune the trees to create trees with subset of 10, 20, 30, 50 and 70% less ASVs: 

```
for file in all.*.tree.treepl.mahendrarajah.dated_primary_secondary.soil.bestTree; do python prune.py "$file" terrestrial_tip_labels_shuffled_70_percent.tsv 70_percent/70_percent."$file"; done;
```

Then repeat analysis of evolutionary rates with these trees, and examine the difference. 

### Examine the effect of terrestrial sampling bias on inferences of rates - Prune away ASVs based on area

First define a bounding box for Europe, and exclude points in this bounding box. Then filter the metadata file to keep only samples not found in Europe. 

```
## Filter out points in Europe
# Define a bounding box for Europe (longitude: -10 to 60, latitude: 35 to 70)
coords_soil_df <- coords_soil_df %>%
  filter(!(x >= -10 & x <= 60 & y >= 35 & y <= 70))

## Filter metadata_soil to keep only rows where "sample" matches "id" in coords_soil_df
metadata_soil_filtered <- metadata_soil %>%
  semi_join(coords_soil_df, by = c("sample" = "id"))

write_tsv(metadata_soil_filtered, "soil/metadata_soil_without_europe.tsv")
```

Do the same for North America, central+south America and Southeast Asia. 

Bounding box for North America: longitude: -170 to -30, latitude: 15 to 80   
Bounding box for Southeast Asia: longitude: 90 to 155, latitude: -10 to 45
Bounding box for Central and South America: longitude: -120 to -34, latitude: -56 to 33

The full terrestrial phylogeny has 3064 ASVs. When you remove samples from Europe you have 1833 ASVs (Complete number of ASVs from Europe = 1886, which means there are 1231 unique ASVs and 1886-1231 = 655 overlapping ASVs). When you remove samples from North America you have 2936 ASVs (Complete number of ASVs from North America = 529, which means there are 128 unique ASVs and 529-128=401 overlapping ASVs). When you remove samples from Southeast Asia you have 2838 ASVs (Complete number of ASVs from southeast Asia is 603, which means there are 226 unique ASVs and 603-226=377 overlapping ASVs). When you remove samples from Central and South America you have 2338 ASVs (Complete number of ASVs from central+south america is 1106, which means there are 726 unique ASVs and 1106-726=380 overlapping ASVs).    

The number of terrestrial samples is 977. When you remove samples from Europe, you have 555 samples (=422 european samples). When you remove samples from North America you have 959 samples (=18 North American samples). When you remove samples from central+south america you have 684 samples (=293 central+south american samples). When you remove from southeast asia you have 733 (=244 southeast asian samples). 

Then calculate new trait values based on this metadata, prune trees to only keep ASVs in this new list and repeat analyses of evolutionary rates. 

## Age of trees
Extract the age of the phylogenetic trees using the R script age_trees.R. 

