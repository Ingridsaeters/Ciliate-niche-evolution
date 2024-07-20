# ASV phylogeny

## Data

Assemble the accepted backbone trees:

```
cp /cluster/home/ingrmsae/nn8118k/ingrid/ciliate_niche/analyses/1_phylogenies/reference_phylogeny/phylogeny_round2/all.18S28S.constrained.{49,11,79,82,62,46,64,37,75,70,50,65,17,4,18,33,90,21,72,51,48,13}.tree.raxml.bestTree .
```

Extract the fasta file for of the ciliate sequences from Eukbank: 

```
cp /cluster/home/ingrmsae/nn8118k/ingrid/ciliate_niche/data/EukBank/eukbank_ciliate_clean.fasta .
```

These are the statistics for this file:

```
file                         format  type  num_seqs    sum_len  min_len  avg_len  max_len
eukbank_ciliate_clean.fasta  FASTA   DNA     17,705  6,367,340      152    359.6      453
```

Remove sequences below 200bp, as these are likely to be of decreased phylogenetic signal.

```
seqkit seq -m 200 eukbank_ciliate_clean.fasta > eukbank_ciliate200.fasta
```

Statistics after removing sequences below 200bp:

```
file                      format  type  num_seqs    sum_len  min_len  avg_len  max_len
eukbank_ciliate200.fasta  FASTA   DNA     17,687  6,364,238      200    359.8      453
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

Do tree inference for the complete alignment for each of the 22 accepted backbone trees, 10 trees for each backbone (220 trees in total), using the sbatch script trees.sbatch. 

Activate this script with the following command, to make one sbatch job per tree and 10 trees per backbone:

```
for i in 11 13 17 18 21 33 37 46 48 49 4 50 51 62 64 65 70 72 75 79 82 90; do 
    echo $i
    for j in {1..10}; do
        sbatch trees.sbatch ${i} ${j}
        sleep 1
    done
done
```
## Robinson Foulds and clustering
Calculate Robinson Foulds distances for the 62 trees with RAxML-ng. First make one file for all 62 trees. Concatenate by increasing order of number in the filename. 

```
ls -v all.18S28S.*.tree.raxml.bestTree | xargs cat > all.18S28S.bestTree
```

Then calculate Robinson Foulds distances. 

```
raxml-ng --rfdist --tree all.18S28S.bestTree --prefix RF
```

Use these distances for a clustering analysis in R, using the Rscript Clustering.R. 

Decide on a reasonable threshold value to choose which cluster level to select trees from. Choose one arbitrary tree from each level below this cluster. 

## Rooting 
Root the trees you select with the root_at_node.py script. 

## Make 100 bootstrap replicates for each tree

Make 100 bootstraped trees with branch lengths from the alignment using RAxML-ng. First, create 100 bootstrap replicates based on the alignment:

```
raxml-ng --bsmsa --bs-trees 100 --msa all.18S28S.ciliate.final.edited.fasta --model GTR+G
```

This creates 100 bootstrap alignments. Then, create 100 bootstrap trees based on this alignment. Use the script bootstrap.sbatch and activate the script with this command:

```
for i in {1..100}; do echo $i; sbatch bootstrap.sbatch ${i}; sleep 1; done
```

This creates one sbatch job for each bootstrap tree.

Do this for all 9 trees.
