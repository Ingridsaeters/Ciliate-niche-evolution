#!/bin/bash

#SBATCH --account=nn8118k
#SBATCH --time=4-00:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=600MB


raxml-ng --bootstrap --msa all.18S28S.replaced.fasta --model GTR+G --tree-constraint Ciliate_constraint.txt.tre --prefix all.18S28S.constrained.bs."$1" --seed $RANDOM --threads 8 --bs-trees 10
