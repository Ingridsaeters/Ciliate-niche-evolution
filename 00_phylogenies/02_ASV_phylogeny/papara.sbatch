#!/bin/bash

#SBATCH --account=nn8118k
#SBATCH --job-name=papara
#SBATCH --time=2-0:0:0
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=6G

papara_static_x86_64 -t all.18S28S.constrained.70.tree.raxml.bestTree -s all.18S28S.replaced.phy -q eukbank_ciliate200.fasta -r

