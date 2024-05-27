# Statistical analyses
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
- Early Burst: This model assumes an initial rapid evolution of the trait value, followed by a reduction of diversification rates.
- Late burst: This model assumes rapid evolution after relative stasis/low diversification rates. 

### Mode of evolution 
Test the standard models of evolution (Brownian motion, Ornstein Uhlenbeck, Early burst and Late Burst) for each combination of trait and tree, to see which model fits the data best. Use the R scripts model_comparison_BM_OU_EB.R and model_comparison_PC_BM_OU_EB.R to test Brownian Motion, Ornstein Uhlenbeck and Early Burst. Use the R scripts model_comparison_ddexp.R and model_comparison_PC_ddexp.R to test for a Late Burst. ddEXP is an exponential diversity dependant model where evolutionary rates either increase or decrease exponentially with accumulation of species diversity in the clade. Exponential increase can be characterized as "Late Burst", and exponential decrease as "Early Burst". Use the script plot_best_model.R to make a visualization with best model. 

## Rate of evolution 
### Relative evolutionary rates
Normalize the trait values to make evolutionary rates comparable across different niche trait variables, by setting the mean to zero and standard deviation to one for all traits. Then estimate the rate parameter, sigma squared, with the script rates.R. Visualize the results with the script plot_rates.R. 

### Absolute rates
To compare rates in ciliates with estimated rates in plants and animals, repeat the analyses in rates.R with non-normalized trait values. Take the square root of estimated rates to get the rate per million years. 

### Rates within clades
Examine evolutionary rates within clades using evorates.R. 

## Age of trees
Extract the age of the phylogenetic trees using the R script age_trees.R. 

