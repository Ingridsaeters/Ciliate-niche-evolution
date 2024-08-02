# DBM analyses started on 25-07-2024

## Settings

Settings were as follows:

Number of iterations used as burn-in : 3,000,000
Number of iterations post burn-in: 10,000,000
Recording frequency: 10,000
δt (time discretized): 1e-3


## Results

NONE of the analyses reached convergence. `Gamma` in particular never converged. 

### mxthf
In the next set of analyses, I plan to set the parameter `mxthf` to 0.05. `mxthf` can be a number from (0,1). It means the maximum edge length when cutting the tree as a proportion of tree height.
So 0.05 will only allow branches less than treeheight x 0.05.

This allows the mixing to be better, and a better exploration of parameter space. 
 
This should take care of some of the really long branches in most phylogenies, which might have been causing problems. 

### Run longer
Perhaps increasing the number of iterations will help. Several phylogenies that could be run longer are:

```
a01 (Try unscaled tree also)
a07 (Try unscaled tree also)
a13 (Try unscaled tree also)
p05
p07 (Try unscaled tree also)
p09
p14
p18 (Try unscaled tree also)
```

### Too few taxa
Several trees also have very few taxa which might not provide enough information for parameters to converge. 

These include:

```
a05
a06
a08
a09
a10.unscaled
a11
a12
a14
a16
a17
p01.unscaled
p02.unscaled
p03
p04.unscaled
p06.unscaled
p08
p11
p16
p17
p19
```

### Scaling issues

I scaled all trees to be in 10s of millions of years. However, for very recent clades, it might be better to not scale the tree. 

These trees include the following (note that they also potentially suffer from having too few taxa).

```
a15
p10
p12.unscaled
```
 
### Input file issues

I later discovered that several datasets had used different taxa names in the tree file and in the data file. So these files should not be considered for the time being. These include:

```
p01
p02
p04
p06
p14
p16
p19
```




