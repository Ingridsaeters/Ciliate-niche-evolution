# DBM analyses started on 30-07-2024

## Settings

Settings were as follows:

Number of iterations used as burn-in : 5,000,000
Number of iterations post burn-in: 15,000,000
Recording frequency: 15,000
δt (time discretized): 1e-3
mxthf: 0.05

## Submitting analyses
To start with, just running analyses on a subset of phylogenies until I figure out the optimum settings. 

```
for i in *scaled.10.tre; do file=$(echo $i | cut -f1 -d '.'); sbatch dbm.sbatch $i "$file".dbm.txt "$file".scaled.10.dbm.out; sleep 1; done
``` 


## Post processing
for i in *dbm.out.txt; do tree=$(echo $i | cut -f1 -d '.'); scale=$(echo $i | cut -f2 -d '.'); julia post_dbm.jl $i "$tree"."$scale".reconstructed.temp.pdf "$tree"."$scale".reconstructed.rates.pdf "$tree"."$scale".temp.time.pdf "$tree"."$scale".rates.time.pdf; done 


