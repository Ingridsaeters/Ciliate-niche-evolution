#!/bin/bash

# Script run on Uppmax. 

#SBATCH -A naiss2024-5-252
#SBATCH -M rackham
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 4-00:00:00
#SBATCH --mail-user mahwash.jamy@slu.se
#SBATCH --mail-type=FAIL
#SBATCH -J raxml-ng

# modules
module load bioinfo-tools

/home/mahja/bin/raxml-ng --search1 --msa all.18S28S.ciliate.final.fasta --model GTR+G --tree-constraint all.18S28S.constrained.$1.tree.raxml.bestTree --prefix  all.18S28S."$1"."$2".tree --threads auto{8} --seed $RANDOM


