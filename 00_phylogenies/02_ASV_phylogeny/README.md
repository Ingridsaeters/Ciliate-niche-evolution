# ASV phylogeny

## Data

Assemble the accepted backbone trees:

```
cp /cluster/home/ingrmsae/nn8118k/ingrid/ciliate_niche/analyses/1_phylogenies/reference_phylogeny/all.18S28S.constrained.{1,2,3,4,5,6,7,8,10,12,14,15,16,17,21,22,27,28,32,33,34,36,37,38,41,42,44,45,47,51,52,53,54,56,57,59,62,63,65,66,67,68,69,70,72,73,74,75,76,77,78,81,83,85,86,87,88,89,92,97,99,100}.tree.raxml.bestTree .
```

Extract the fasta file for of the ciliate sequences from Eukbank: 

```
cp /cluster/home/ingrmsae/nn8118k/ingrid/ciliate_niche/data/EukBank/eukbank_ciliate_clean.fasta .
```

These are the statistics for this file:

```
file                         format  type  num_seqs    sum_len  min_len  avg_len  max_len
eukbank_ciliate_clean.fasta  FASTA   DNA     18,816  6,760,308       32    359.3      453
```

Remove sequences below 200bp, as these are likely to be of decreased phylogenetic signal.

```
seqkit seq -m 200 eukbank_ciliate_clean.fasta > eukbank_ciliate200.fasta
```

Statistics after removing sequences below 200bp:

```
file                      format  type  num_seqs    sum_len  min_len  avg_len  max_len
eukbank_ciliate200.fasta  FASTA   DNA     18,781  6,755,513      200    359.7      453
```

Extract the alignment used to make the constraint trees, in phylip format:

```
cp /cluster/home/ingrmsae/nn8118k/ingrid/ciliate_niche/analyses/1_phylogenies/reference_phylogeny/all.18S28S.replaced.phy .
```

## Alignment

Do an alignment using papara_static_x86_64 (Download: https://cme.h-its.org/exelixis/resource/download/software/papara_nt-2.5-static_x86_64.tar.gz). Papara makes an alignment based on a reference tree (newick format), reference alignment (phylip format) and query sequences (fasta format).    
    
Use whichever of the 100 backbone trees as reference tree. We decided to use tree 70 as it has the highest log likelihood and is the tree we used as input for the statistical analyses in iqtree.

Use the sbatch script papara.sbatch for the alignment. 

## Formatting

Format headers so that the alignment will be accepted by raxml-ng:

```
cat papara_alignment.default | sed -e '1d' -e 's/^/>/g' -e 's/[[:blank:]]\+/\n/g' > all.18S28S.ciliate.fasta
cat all.18S28S.ciliate.fasta | sed 's/;/_/g' > all.18S28S.ciliate.final.fasta
```

## Tree inference

Do tree inference for the complete alignment for each of the 62 accepted backbone trees, using the sbatch script trees.sbatch. 

Activate this script with the following command, to make one sbatch job per tree:

```
for i in 1 2 3 4 5 6 7 8 10 12 14 15 16 17 21 22 27 28 32 33 34 36 37 38 41 42 44 45 47 51 52 53 54 56 57 59 62 63 65 66 67 68 69 70 72 73 74 75 76 77 78 81 83 85 86 87 88 89 92 97 99 100; do echo $i; sbatch trees.sbatch ${i}; sleep 1; done
```
