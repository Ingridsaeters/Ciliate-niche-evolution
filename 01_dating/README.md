# Dating

## Prune away outgroup and format trees
For dating analyses, we opted to prune away the outgroups (in an effort to reduce excessive rate heterogeneity that may be introduced by groups like Apicomplexa and Dinoflagellata), leaving behind only the ciliates. 

First create some subfolders to work in.

```
for i in 11 13 17 18 21 33 37 46 48 49 4 50 51 62 64 65 70 72 75 79 82 90; do 
    mkdir tree_"$i"
done
```

Now we prune away the outgroup.
```
for i in ../00_phylogenies/02_ASV_phylogeny/trees/*.rooted; do 
    tree=$(basename $i | cut -f3 -d '.')
    file=$(basename $i)
    python extract_clade.py $i Ciliophora tree_"$tree"/"$file" 
done
```

Finally, the `=` sign in the tree causes a problem for treePL, since the config file uses `=` signs for assigning calibration nodes. Change the `=` sign to `_` in the trees.

```
for i in tree*/*rooted; do 
    cat $i | sed -E 's/=/_/g' > Tree
    mv Tree $i
done
```

## Extract subtrees to help identify taxa for node calibrations

Extract trees of only the clades we have fossils from with the `extract_clade.py` script, to make it easier to select taxa for node calibrations. We just need to do this for one tree (any tree) per backbone as taxa for definiing mrca for node calibrations are only selected from reference taxa, and not ASVs (as we are less confident of the taxonomic ID of ASVs). 

```
for file in tree*/all.*.10.tree.raxml.bestTree.rooted; do base=$(basename $file); python extract_clade.py "$file" Colpodea Colpodea."$base"; done
for file in tree*/all.*.10.tree.raxml.bestTree.rooted; do base=$(basename $file); python extract_clade.py "$file" Oligohymenophorea Oligohymenophorea."$file"; done
for file in tree*/all.*.10.tree.raxml.bestTree.rooted; do base=$(basename $file); python extract_clade.py "$file" Spirotrichea Spirotrichea."$file"; done;
for file in tree*/all.*.10.tree.raxml.bestTree.rooted; do base=$(basename $file); python extract_clade.py "$file" Armophorea Armophorea."$file"; done;
for file in tree*/all.*.10.tree.raxml.bestTree.rooted; do base=$(basename $file); python extract_clade.py "$file" Litostomatea Litostomatea."$file"; done;
```

## Select taxa for calibration

We use two dating strategies:

1. Eight primary calibrations, and two secondary calibrations (on the root, and age of Intramacronucleata) from Strassert et al 2021.  
2. Eight primary calibrations, four calibrations based on obligate animal associations (Armophorea and Litostomatea), and two secondary calibrations (on the root, and age of Intramacronucleata) from Strassert et al 2021.  

Fossil calibrations are described in `Fossil_calibrations.pdf`.

The taxa for defining each fossil node are largely the same between different backbone trees, but there are some occasional differences. We created a `config_skeleton` file for each folder. 

Once taxa for defining each node have been selected, we can delete the clade trees to keep the folders clean. 

```
rm tree_*/Litostomatea*
rm tree_*/Armophorea*
rm tree_*/Colpodea*
rm tree_*/Oligohymenophorea*
rm tree_*/Spirotrichea*
```
 
## Scale trees

During preliminary analyses, we found that treePL replaces branch lengths that are too small with a standard value. This is undesirable as it would likely affect downstream results. Therefore, we followed the suggestion of Maurin 2020, and scaled the trees by a factor of 1000, which made the `tiny branch length` message go away. 

```
for i in tree_*/*rooted; do echo $i; Rscript scaleTrees.R $i "$i".scaled; done
```

We remove the unscaled trees to clean folders.

```
rm tree_*/*rooted
```
  
## Prime
This step will try to find the best optimisation parameters for the treePL run.

```
for i in tree_*/*.rooted.scaled; do 
    folder=$(dirname $i) 
    tree=$(basename $i) 
    echo $tree 
    config=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.prime/') 
    out=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.prime.out/') 
    sbatch treepl_prime.sh $folder $tree $config $out
    sleep 1 
done
```

## Cross validation (CV)
This step will try to find the best rate smoothing value.

```
for i in tree_*/*.rooted.scaled; do 
    folder=$(dirname $i) 
    tree=$(basename $i) 
    echo $tree 
    config=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.cv/') 
    prime=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.prime.out/') 
    out=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.cv.out/') 
    sbatch treepl_cv.sh $folder $tree $config $prime $out 
    sleep 1 
done
```

## Date phylogenies
We now date the phylogenies using the best optimisation parameters from the prime step, and the best smoothing value from the the CV step. 

```
for i in tree_*/*.rooted.scaled; do
    folder=$(dirname $i)
    tree=$(basename $i)
    echo $tree
    config=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.date/')
    prime=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.prime.out/')
    cv=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.cv.out/')
    out=$(basename $i | sed -E 's/(.*)raxml.bestTree.rooted.scaled/\1treepl.dated.tre/')
    sbatch treepl_date.sh $folder $tree $config $prime $cv $out
    sleep 1
done 
```
 

For each taxon you have dating information for, select taxa so that your calibration will be for the node that separates the fossil taxon from its closest sister taxa. 


Follow this manual for treePL: https://doi.org/10.48550/arXiv.2008.07054.

Run the configuration file in treePL in three different steps:
1. Priming - This step will try to find the best optimisation parameters for your run. Run treePL with the configuration file, but comment out [Best optimization parameters], [Cross validation analyses] and [Best smoothing value]. Give it three hours.
2. Cross Validation (CV) analysis - This step will try to find the best smoothing parameter that affects the penalty of rate variation across the tree. Run this analysis with random subsample and replicate cross-validation (RSRCV). This will randomly sample, with replacement, multiple terminal nodes, recalculate rates and dates with these nodes removed, and calculate the averaged error over the sampled nodes. Add the best optimisation parameters from step 1. For [Cross validation analyses] use the same settings as in the manual, except the cvstart parameter (we set it to 1, while in the manual it is 100000). Unless you are expecting rates consistent with a strict clock model, you may not need a high cvstart value. Run treePL with the configuration file again, but this time comment out [Priming command] and [Best smoothing value]. Give it 24 hours. The smoothing value will be the lowest chisq value you get as output. 
3. Date the tree - This step uses the best optimisation parameters and the best smoothing value to date the tree. Add the smoothing value you got in step 2. Comment out [Priming command] and [Cross validation analyses] and run it in treePL again. Give it 24 hours.

To comment out several lines at once in vim: 
1. Go to the first line and press shift+v and mark all the lines you want to comment out
2. Press :s/^/# / and hit enter
3. To remove the yellow search line that comes up, press :nohl and hit enter

## Extract soil, marine and frehwater trees

Make a list of all the soil ciliate ASVs in the tree. First, make a pattern file from the eukbank file. 

```
grep ">" eukbank_ciliate_soil.fasta | tr ";" "_" | tr -d ">" > eukbank_ciliate_soil.list
```

Format the pattern file, since "=" has been changed to _ in the trees. 

```
sed -E 's/(.*)_size=(.*)_tax=(.*)/\1/g' eukbank_ciliate_soil.list > eukbank_ciliate_soil.reduced.list
```

Extract ASV soil ciliate fasta sequences from the final alignment. 

```
seqkit grep -r -f eukbank_ciliate_soil.reduced.list all.18S28S.ciliate.final.fasta > all.18S28S.ciliate.soil.final.fasta
```

Make a pattern file of these sequences to prune the trees. 
```
grep ">" all.18S28S.ciliate.soil.final.fasta > soil.list
cat soil.list | tr -d ">" > soil.formatted.list
cat soil.formatted.list | sed -E 's/(.*)_samples=(.*)_size=(.*)_tax=(.*)/\1_samples_\2_size_\3_tax_\4/g' > soil.formatted.reduced.list
```

Repeat for marine and freshwater. There are 5964 marine, 2440 soil and 2106 freshwater ASVs. 

## Find the ASVs present in multiple habitats

```
grep -Ff soil.formatted.reduced.list marine.formatted.reduced.list > overlapping_soil_marine
grep -Ff soil.formatted.reduced.list freshwater.formatted.reduced.list > overlapping_soil_freshwater
grep -Ff freshwater.formatted.reduced.list marine.formatted.reduced.list > overlapping_freshwater_marine
cat overlapping_soil_marine overlapping_soil_freshwater overlapping_freshwater_marine > overlapping_all.list
```

There are 869 ASVs that are present in multiple habitats. Remove these from the files: 

```
grep -vf overlapping_all.list soil.formatted.reduced.list > soil_ASVs_removed.list
grep -vf overlapping_all.list freshwater.formatted.reduced.list > freshwater_ASVs_removed.list
grep -vf overlapping_all.list marine.formatted.reduced.list > marine_ASVs_removed.list
```

After removing the ASVs there are 5789 marine, 1746 soil, and 1237 freshwater ASVs. 

Prune the trees: 
```
for i in *.tree.treepl.dated.tre; do python ../prune.py $i ../../soil_ASVs_removed.list ../soil_dated_trees/soil_"$i"; done
for i in *.tree.treepl.dated.tre; do python ../prune.py $i ../../marine_ASVs_removed.list ../marine_dated_trees/marine_"$i"; done
for i in *.tree.treepl.dated.tre; do python ../prune.py $i ../../freshwater_ASVs_removed.list ../freshwater_dated_trees/freshwater_"$i"; done
```
Do the same proceedure for marine and freshwater ASVs.

## Prune away backbone taxa for complete trees

First make a fasta file with all marine, soil and freshwater sequences

```
cat eukbank_ciliate_marine.fasta eukbank_ciliate_soil.fasta eukbank_ciliate_freshwater.fasta > eukbank.fasta
```

Then follow the steps from above

```
grep ">" eukbank.fasta | tr ";" "_" | tr -d ">" > eukbank_ciliate.list
sed -E 's/(.*)_size=(.*)_tax=(.*)/\1/g' eukbank_ciliate.list > eukbank_ciliate.reduced.list
seqkit grep -r -f eukbank_ciliate.reduced.list all.18S28S.ciliate.final.fasta > all.eukbank.ciliate.final.fasta
grep ">" all.eukbank.ciliate.final.fasta > eukbank.list
cat eukbank.list | tr -d ">" > eukbank.formatted.list
cat eukbank.formatted.list | sed -E 's/(.*)_samples=(.*)_size=(.*)_tax=(.*)/\1_samples_\2_size_\3_tax_\4/g' > eukbank.formatted.reduced.list
```

Prune away the backbone taxa

```
for i in *.tree.treepl.dated.tre; do python ../prune.py $i ../../eukbank.formatted.reduced.list ../eukbank_dated_trees/eukbank_"$i"; done
```







