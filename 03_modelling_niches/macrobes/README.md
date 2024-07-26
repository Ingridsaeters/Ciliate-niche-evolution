# Running EvoRates and DBM on macrobes

Here I am running preliminary analyses using both the (DBM)[https://github.com/ignacioq/Tapestree.jl] and (EvoRates)[https://doi.org/10.1093/sysbio/syac068] models. 

The aim of these preliminary tests are:  
1. To compare DBM and EvoRates. Do they produce similar results?  
2. To estimate the rates of temp (and precipitation) niche evolution. 
	- Do DBM and EvoRates produce similar results?  
	- What rates od we get for plants and animals?  
	- Are they similar to published rates?  
3. Figure out how to visualize results.  
4. Figure out how computationally feasible it is to run these complex models on our large phylogenies.    
   

For these tests, I am using the phylogenies and data downloaded from [Liu et al. 2020](https://doi.org/10.1038/s41559-020-1158-x). In total, this corresponds to 17 animal phylogenies and 17 plant phylogenies (two plant phylogenies, p13 and p15 were excluded as they contained nodes that were younger than their descendants, causing problems in analyses). These phylogenies have been scaled to be in the units of 10 Myr to improve estimation (following [Revell et al. 2018](https://doi.org/10.1111/2041-210X.12977)).  



## References
Diffused Brownian Motion (DBM). https://github.com/ignacioq/Tapestree.jl. Not yet publicly avaialble.

Martin, B. S., Bradburd, G. S., Harmon, L. J., & Weber, M. G. (2023). Modeling the evolution of rates of continuous trait evolution. Systematic Biology, 72(3), 590-605. Available at: https://github.com/bstaggmartin/evorates

Liu, H., Ye, Q., & Wiens, J. J. (2020). Climatic-niche evolution follows similar rules in plants and animals. Nature Ecology & Evolution, 4(5), 753-763. https://doi.org/10.1038/s41559-020-1158-x

Revell, L. J., González‐Valenzuela, L. E., Alfonso, A., Castellanos‐García, L. A., Guarnizo, C. E., & Crawford, A. J. (2018). Comparing evolutionary rates between trees, clades and traits. Methods in Ecology and Evolution, 9(4), 994-1005. https://doi.org/10.1111/2041-210X.12977


