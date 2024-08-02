#!/bin/bash

#SBATCH --account=nn8118k
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1GB
#SBATCH --mail-user mahwash.jamy@slu.se
#SBATCH --mail-type=FAIL

## Load module
module load R/4.2.2-foss-2022b

## Run r script
log=$1
tree=$2
data=$3
outfile=$4
plot=$5
rds=$6

echo $tree
echo $data

Rscript evorates.r $log $tree $data $outfile $plot $rds

