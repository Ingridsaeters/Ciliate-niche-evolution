#!/bin/bash

#SBATCH --account=nn8118k
#SBATCH --time=24:0:0
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4GB

# raxml-ng --bsmsa --bs-trees 100 --msa all.18S28S.ciliate.final.edited.fasta --model GTR+G

raxml-ng --evaluate --msa all.18S28S.ciliate.final.edited.fasta.raxml.bootstrapMSA.$1.phy --model GTR+G --tree 99.tree/all.99.tree.raxml.rooted.bestTree --prefix EVAL99_$1
