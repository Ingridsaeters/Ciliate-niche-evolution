#!/bin/bash

#SBATCH --account=nn8118k
#SBATCH --time=3-0:0:0
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6G

#Settings
module load MAFFT/7.490-GCC-11.2.0-with-extensions

mafft-linsi --thread 20 --reorder --adjustdirection all.18S.unaligned_auto.man_trimmed.fasta > all.18S.aligned.fasta
