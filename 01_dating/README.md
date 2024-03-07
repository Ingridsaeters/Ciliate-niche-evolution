# Dating

## Extract subtrees

Extract trees of only the clades you have fossils from with the extract_clade.py script, to make it easier to select taxa for node calibrations. 

```
for file in all.*.tree.raxml.rooted.bestTree; do python extract_clade.py "$file" Colpodea Colpodea."$file"; done;
for file in all.*.tree.raxml.rooted.bestTree; do python extract_clade.py "$file" Oligohymenophorea Oligohymenophorea."$file"; done;
for file in all.*.tree.raxml.rooted.bestTree; do python extract_clade.py "$file" Dinoflagellata Dinoflagellata."$file"; done;
for file in all.*.tree.raxml.rooted.bestTree; do python extract_clade.py "$file" Armophorea Armophorea."$file"; done;
for file in all.*.tree.raxml.rooted.bestTree; do python extract_clade.py "$file" Litostomatea Litostomatea."$file"; done;
```

## Select taxa for calibration

For each taxon you have dating information for, select taxa so that your calibration will be for the node that separates the fossil taxon from its closest sister taxa. 

## Date the trees with TreePL

The = sign in the tree causes a problem for treePL, since the config file uses = signs for assigning calibration nodes. Change the = sign to _ in the tree, and for the calibration taxa given in the calibration file.

```
cat all.15.tree.raxml.rooted.bestTree | sed -E 's/=/_/g' > all.15.tree.raxml.rooted.formatted.bestTree
```

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
```

Prune the trees, to create a tree with only soil ciliate ASVs. 
```
python prune.py 99.dated.mahendrarajah_root.nwk soil.formatted.list 99.dated.mahendrarajah_root_soil.nwk
```
Do the same proceedure for marine and freshwater ASVs.

