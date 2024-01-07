# Modelling niches

## Choice of model for trait evolution

Test the standard models of evolution (Brownian motion, Ornstein Uhlenbeck and Early burst) for each combination of trait and tree, to see which model fits the data best. Use the R script Rpanda.R. 

Models of evolution: 
- Brownian motion: This is a "random walk" model, because the trait value changes randomly, in both direction and distance, over any time interval.
- Ornstein Uhlenbeck: This model assues that a character is evolving towards an optimal value. The character evolves stochastically according to a drift parameter, and is pulled towards the optimum by the rate of adaption, alpha. Since alpha determines how strongly the character is pulled towards the optimum value, it is often called the "rubber band" parameter.
- Early Burst: This model assumes an initial rapid evolution of the trait value, followed by a reduction of diversification rates.
