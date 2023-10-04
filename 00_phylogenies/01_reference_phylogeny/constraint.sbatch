#!/bin/bash

#SBATCH --account=nn8118k
#SBATCH --time=12:0:0
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=600MB

#Settings
module load Miniconda3/22.11.1-1
conda activate raxml-ng

raxml-ng --search1 --msa all.18S28S.replaced.fasta --model GTR+G --tree-constraint Ciliate_constraint.txt.tre --prefix  all.18S28S.constrained."$1".tree --threads 8 --seed $RANDOM
