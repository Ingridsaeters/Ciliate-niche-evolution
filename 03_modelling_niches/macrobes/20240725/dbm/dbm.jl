#=
Inference for dbm

Ignacio Quintero Mächler

t(-_-t)

04 04 2024
=#

using Tapestree
using DelimitedFiles

# load tree
tre = read_newick(ARGS[1])

# load data
tx  = readdlm(ARGS[2], '\t')
xav = Dict{String, Float64}(tx[i,1] => tx[i,3] for i in 1:size(tx,1))

# load standard deviations
xst = Dict{String, Float64}(tx[i,1] => tx[i,4] for i in 1:size(tx,1)) 

# out file
out_file = ARGS[3]

# run mcmc
### r stores the root state of the trait, the root rate, the trend (α) and the rate variation (γ).
### tv stores the reconstructed history of the tree at each iteration that is printed
### tre, xav, and xs are the tree, data, and standard deviations respectively. xs has to be specified since it is not the default option.
### Inverse gamma prior on rate variation through time
### nburn = Number of generations to burn in
### niter = Number of iterations after burn in
### nthin = frequency of sampling
### nflush = frequency of writing to file (more important)
### ofile = outfile
### δt = discretize time (shouldn't be too large or you will get weird results). 1e-3 works fine usually.
### prints = update to screen after every few seconds. If running on cluster for several hours, set prints to every hour (3600) so that you dont get a huge file generated

### 
r, tv = insane_dbm(tre, xav,
          xs     = xst,
          γ_prior= (0.05, 0.05),
          nburn  = 3_000_000,
          niter  = 7_000_000,
          nthin  = 7_000,
          nflush = 7_000,
          ofile  = out_file,
          δt     = 1e-3,
          prints = 3600)


