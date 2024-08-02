#!/bin/bash

#SBATCH -A naiss2024-5-252
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1-10:00:00 
#SBATCH --mail-user mahwash.jamy@slu.se
#SBATCH --mail-type=FAIL
#SBATCH -J dbm

#Command
tree=$1
data=$2
out=$3

echo $tree
echo $data

julia dbm.jl $tree $data $out

