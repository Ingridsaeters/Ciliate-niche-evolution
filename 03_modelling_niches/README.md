# Mode of evolution

## Standard models of evolution: 
- Brownian motion: This is a "random walk" model, because the trait value changes randomly, in both direction and distance, over any time interval.
- Ornstein Uhlenbeck: This model assues that a character is evolving towards an optimal value. The character evolves stochastically according to a drift parameter, and is pulled towards the optimum by the rate of adaption, alpha. Since alpha determines how strongly the character is pulled towards the optimum value, it is often called the "rubber band" parameter.
- Early Burst: This model assumes an initial rapid evolution of the trait value, followed by a reduction of diversification rates.

## Mode of evolution for full tree
Test the standard models of evolution (Brownian motion, Ornstein Uhlenbeck and Early burst) for each combination of trait and tree, to see which model fits the data best. Use the R script Rpanda.R.

## Mode of evolution for clades

Prune the trees, so that you get subtrees for each clade. Use the python script prune.py. Test the standard models of evolution against the tree for each clade, but use a cutoff of 50 ASVs (don't run the analyses on trees with less than 50 tips). For soil, this includes all clades except Plagiopylea and Karyorelictea.  
