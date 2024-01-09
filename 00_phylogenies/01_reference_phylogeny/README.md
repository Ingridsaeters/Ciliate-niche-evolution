# Reference phylogeny

## Alignment

Run MAFFT-L-ins-i on the 18S and 28S sequences. The advantage of L-ins-i is that it can align a set of sequences containing sequences flanking around one alignable domain. Since L-ins-i is very computationally intensive, we ran the jobs with the sbatch scripts 18S.mafft_linsi.sbatch and 28S.mafft_linsi.sbatch, with 20 threads. 

Preliminary analyses showed that some of the 18S sequences are very long, spanning the 18S gene, and so the alignment for the 18S sequences was taking a very long time. Therefore we did the following steps for the 18S sequences:

1. Align with mafft-auto

```
mafft --thread 4 --adjustdirection --reorder --auto 18S.cluster100.fasta > all.18S.aligned_auto.fasta
```

2. Manually trim the ends in AliView

Before trimming the ends the alignment was 16757bp long. After removing bp before and after the 18S gene, the alignment was 6620bp long.

 ```
file                                    format  type  num_seqs     sum_len  min_len  avg_len  max_len
all.18S.aligned_auto.man_trimmed.fasta  FASTA   DNA      2,671  17,682,020    6,620    6,620    6,620
```

3. Remove gaps (i.e. unalign the sequences)

```
seqkit seq -g all.18S.aligned_auto.man_trimmed.fasta > all.18S.unaligned_auto.man_trimmed.fasta
```

4. Align with mafft-linsi 


Statistics after alignment:

```
file                   format  type  num_seqs     sum_len  min_len  avg_len  max_len
all.18S.aligned.fasta  FASTA   DNA      2,671  17,105,084    6,404    6,404    6,404
all.28S.aligned.fasta  FASTA   DNA      1,181  10,238,089    8,669    8,669    8,669
```

## Trimming

Download trimal version 1.2 from http://trimal.cgenomics.org/downloads.

Run Trimal with different tresholds (99.5%, 99%, 98% and 97%) to see the differences. To be concervative we chose a trimming treshold of 99.5%.

```
trimal -in all.28S.aligned.fasta -out all.28S.aligned.trimal99.5.fasta -gt 0.005
trimal -in all.18S.aligned.fasta -out all.18S.aligned.trimal99.5.fasta -gt 0.005
```

Statistics:

```
file                              format  type  num_seqs    sum_len  min_len  avg_len  max_len
all.18S.aligned.trimal99.5.fasta  FASTA   DNA      2,671  5,526,299    2,069    2,069    2,069
all.28S.aligned.trimal99.5.fasta  FASTA   DNA      1,181  4,623,615    3,915    3,915    3,915
```

## Format sequences to remove the text that trimal adds

```
cat all.28S.aligned.trimal99.5.fasta | sed 's/ 3915 bp//' | tr '.' '-' > all.28S.aligned.trimal99.5.formatted.fasta
cat all.18S.aligned.trimal99.5.fasta | sed 's/ 2069 bp//' | tr '.' '-' > all.18S.aligned.trimal99.5.formatted.fasta
```

## Concatenate sequences

Concatenate sequences with the concat.pl script:

```
perl ./concat.pl all.18S.aligned.trimal99.5.formatted.fasta all.28S.aligned.trimal99.5.formatted.fasta > all.18S28S.fasta
```

To run the script, make a conda environment and install the following program:

```
conda install -c "bioconda/label/cf201901" snippy
```

After concatenating the number of sequences was 2789, while the number of sequences in the 18S file was 2671, so something had gone wrong. 118 sequeces must be different. To find the sequences with different headers, the following commands were run:

```
diff <(cat all.18S.aligned.trimal99.5.formatted.fasta | grep ">" | sort)  <(cat all.28S.aligned.trimal99.5.formatted.fasta | grep ">" | sort) | grep "^>" | awk -F\> '{print $3}' > difference.list
wc -l differece.list
```

This gave an output of 118 sequences with different heaeders. We found that these 118 sequences were removed from the 18S file during the clustering step. Therefore we decided to remove them from the 28S file before concatenating. They were removed with the filter_fasta_by_list_of_headers.py python script (biopython was installed with pip install):

```
./filter_fasta_by_list_of_headers.py all.28S.aligned.trimal99.5.formatted.fasta difference.list > 28S.filtered.fasta
```

Then concatenation was repeated:

```
perl ./concat.pl all.18S.aligned.trimal99.5.formatted.fasta 28S.filtered.fasta > all.18S28S.fasta
```

Statistics for concatenated file: 

```
file              format  type  num_seqs     sum_len  min_len  avg_len  max_len
all.18S28S.fasta  FASTA   DNA      2,671  15,983,264    5,984    5,984    5,984
```

## Reannotate

We are following the reference tree for ciliates from Rajter & Dunthorn, 2021. We therefore made the following changes to annotation: 
- Plagiopylea should be a main group (not an undergroup of Prostomatea). 
- Discotrichidae should not be grouped as Nassophorea – This is incertae sedis within CONthreeP.
- Cyclotrichium and Pseudotrachelocerca should not be grouped as Prostomatean - These are incertae sedis within CONthreeP.

Numbers of changed sequences:
- Plagiopylea: 28
- Discotrichidae: 57
- Cyclotrichium: 3
- Pseudotrachelocerca: 1

Also, looking through preliminary trees indicated that this sequence hould be renamed:
 - c-7036_conseq_Otu0060_466_freshwater_permafrost_Eukaryota_TSAR_Alveolata_Ciliophora_Prostomatea_2_Prostomatea_2_X_Placidae_Placus_Genus

Checking it on BLAST gave a percentage identity of 92,99% for the 18S sequence, and 89,2% for the 28S sequence. This indicates that it has been wrongly annotated to Prostomatea, since it appears in a different part of the tree, and has such low percentage identity. We renamed it to this:
- c-7036_conseq_Otu0060_466_freshwater_permafrost_Eukaryota_TSAR_Alveolata_Ciliophora

Headers were changed with the replace_fasta_header.pl script. To run this script you need a tsv file with one column for old headers and one column for new headers. We made a tsv file with two header columns: 

```
grep ">" all.18S28S.fasta > all.18S28S.headers.fasta
cat all.18S28S.headers.fasta | sed -E 's/(.*)/\1\t\1/' > all.18S28S.headers.tsv
```

To change the headers in the second column in the tsv file, the following commands were run:

```
awk -F'\t' -v OFS='\t' 'NR>=2{sub(/_Nassophorea_Nassophorea_X_Discotrichidae_NASSO_1_NASSO_1/, "Discotrichidae_", $2)} 1' all.18S28S.headers.tsv > all.18S28S.headers.tsv1
awk -F'\t' -v OFS='\t' 'NR>=2{sub(/prostomateans.*CyPs-clade.*Cyclotrichiidae/, "Cyclotrichiidae", $2)} 1' all.18S28S.headers.tsv1 > all.18S28S.headers.tsv2
awk -F'\t' -v OFS='\t' 'NR>=2{sub(/prostomateans.*CyPs-clade.*g_Pseudotrachelocerca/, "Pseudotrachelocerca", $2)} 1' all.18S28S.headers.tsv2 > all.18S28S.headers.tsv3
awk -F'\t' -v OFS='\t' 'NR>=2{sub(/prostomateans.*Plagiopylea/, "Plagiopylea", $2)} 1' all.18S28S.headers.tsv3 > all.18S28S.headers.tsv4
awk -F'\t' -v OFS='\t' 'NR>=2{sub(/c-7036_conseq_Otu0060_466_freshwater_permafrost_Eukaryota_TSAR_Alveolata_Ciliophora_Prostomatea_2_Prostomatea_2_X_Placidae_Placus_Genus/, "c-7036_conseq_Otu0060_466_freshwater_permafrost_Eukaryota_TSAR_Alveolata_Ciliophora", $2)} 1' all.18S28S.headers.tsv4 > all.18S28S.headers.tsv5
```

-F'\t' says that it should use tab as the field delimiter on input. -v OFS='\t' says that it should use tab as the field delimiter on output. NR>=2 {sub(/Discotrichidae_NASSO_1_NASSO_1_/, "Discotrichidae_", $2)} says that it should remove /Discotrichidae_NASSO_1_NASSO_1_ from field 2 only for lines after the first line, and replace it with Discotrichidae_. 1 is awk's shorthand for print-the-line.

To check that the correct number of headers had been changed, the following command was run between each step to count the differences between the header files:

```
diff <(cat all.18S28S.headers.tsv3 | grep ">" | sort)  <(cat all.18S28S.headers.tsv4 | grep ">" | sort) | grep "^>" | awk -F\> '{print $3}' | wc -l
```

The > character was removed from the tsv file, and the replace_fasta_header.pl script was run. 

We also noted the following:
1. Odontostomatida - In the EukRibo dataset, the group is in SAL (no further group specified). But in Adl et al, we see that Odontostomatida are placed within Armophorea. In our phylogenies, the group falls within Litostomatea.
2. Kiitrichidae - In the EukRibo dataset, this group is also in an unspecified position in SAL. In Adl et al. the group is placed in Spirotrichea.

## Make files for the constraint groups

Constrain the trees according to the reference tree from Rajter and Dunthorn 2021 (http://dx.doi.org/10.3897/mbmg.5.69602). Make a file with a newick tree of the main groups (constraint.tree). 

Make one file for each major group to output all taxa to constrain:

```
cat all.18S28S.replaced.fasta | grep "Karyorelictea" | tr -d '>' > Karyorelictea.txt
cat all.18S28S.replaced.fasta | grep "Heterotrichea" | tr -d '>' > Heterotrichea.txt
cat all.18S28S.replaced.fasta | grep "Litostomatea" | tr -d '>' > Litostomatea.txt
cat all.18S28S.replaced.fasta | grep "Mesodinium" | tr -d '>' >> Litostomatea.txt
cat all.18S28S.replaced.fasta | grep "Armophorea" | tr -d '>' > Armophorea.txt
cat all.18S28S.replaced.fasta | grep "Caenomorphidae" | tr -d '>' >> Armophorea.txt
cat all.18S28S.replaced.fasta | grep "Cariacotrichea" | tr -d '>' >> Armophorea.txt
cat all.18S28S.replaced.fasta | grep "Muranotrichea" | tr -d '>' >> Armophorea.txt
cat all.18S28S.replaced.fasta | grep "Spirotrichea" | tr -d '>' > Spirotrichea.txt
cat all.18S28S.replaced.fasta | grep "Licnophoridae" | tr -d '>' >> Spirotrichea.txt
cat all.18S28S.replaced.fasta | grep "Colpodea" | tr -d '>' > Colpodea.txt
cat all.18S28S.replaced.fasta | grep "Oligohymenophorea" | tr -d '>' > Oligohymenophorea.txt
cat all.18S28S.replaced.fasta | grep "Nassophorea" | tr -d '>' > Nassophorea.txt
cat all.18S28S.replaced.fasta | grep "Prostomatea" | tr -d '>' > Prostomatea.txt
cat all.18S28S.replaced.fasta | grep "Prostomateans" | tr -d '>' >> Prostomatea.txt
cat all.18S28S.replaced.fasta | grep "prostomateans" | tr -d '>' >> Prostomatea.txt
cat all.18S28S.replaced.fasta | grep "Askenasia" | tr -d '>' >> Prostomatea.txt
cat all.18S28S.replaced.fasta | grep "Plagiopylea" | tr -d '>' > Plagiopylea.txt
cat all.18S28S.replaced.fasta | grep "Phyllopharyngea" | tr -d '>' > Phyllopharyngea.txt
cat all.18S28S.replaced.fasta | grep "Dinoflagellata" | tr -d '>' > Dinoflagellata.txt
cat all.18S28S.replaced.fasta | grep "Apicomplexa" | tr -d '>' > Apicomplexa.txt
cat all.18S28S.replaced.fasta | grep "Colponemidae" | tr -d '>' > Colponemidae.txt
cat all.18S28S.replaced.fasta | grep "Colpodellidea" | tr -d '>' > Colpodellidea.txt
```

Run the following for loop to remove duplicates, and process the files to have all taxon names on a single line separated by commas:

```
for i in *txt; do sort $i | uniq | sed -E 's/(.*)/\1, /' | tr -d '\n' | sed -E 's/, $//' > "$i".csv ; done
```

Run the script setup_constraint.pl to combine all the files.

## Create constraint tree

Make 100 maximum likelihood trees to take phylogenetic uncertainties into account. Run the constraint.sbatch script with this command to make 100 trees:

```
for i in $(seq 100); do echo $i; sbatch <name of sbatch script> ${i}; sleep 1; done
```

## Apply all statistical significance tests implemented in IQ-TREE to this set of 100 ML trees

### Information about the statistical tests performed using IQ-TREE:
- Kishino-Hasegawa test: Uses differences in support provided by individual sites for two trees to determine if the overall differences between the trees are significantly greater than expected from random sampling error. Assumes that characters are independant and identically distributed. Should be of trees that are selected a priori.
- Shimodaira-Hasegawa test: Similar to KH, but more statistical correct in cases where trees are not selected a priori. Can be used to test one tree against another tree that was found by searching for the best tree among a large set of candidate trees.
- RELL: A fast approximation of bootstrapping to assess variability in likelihood ratio test statistics. Instead of resampling characters and conducting a full phylogenetic analysis, we simply resample the site-likelihoods from the original.
- Approximately Unbiased (AU) test (Shimodaira): The SH test becomes too conservative when testing many trees. The AU test fixes this problem. Uses a multiscale bootstrap technique for hypothesis testing of regions to reduce test bias.
- c-ELW: Expected likelihood weight.

### Proceedure

First install iqtree.

Run the following command to find the tree with best likelihood value: 

```
grep "Final LogLikelihood: " all.18S28S.constrained.*.tree.raxml.log | awk '{print $NF}' | sort
```

We found that tree 70 had the best log likelihood value of the 100, and therefore we used this tree for test comparison (This is used as input in the iqtree.test script).    
    
Make a concatenated file with all the 100 trees:

```
cat all.18S28S.constrained.*.tree.raxml.bestTree > RAxML_bestTree.all100trees.constrained
```

To perform analyses, run the iqtree.test script. 

## Select trees

Assign ML trees to a “plausible” ML tree set that are not significantly worse than the best-scoring ML tree under any statistical significance test implemented in IQ-TREE. This assignment is conservative, as it will yield the smallest plausible tree set and circumvents the long-lasting debate about which phylogenetic significance test is most appropriate.

This implies that you should only accept trees with output plus sign (+) for every test. Extract these trees with the following command:

```
grep -A 101 "Tree      logL    deltaL  bp-RELL    p-KH     p-SH    p-WKH    p-WSH       c-ELW       p-AU" all.18S28S.replaced.phy.iqtree | sed -E 's/-104/104/' | grep -v "-" | sed -E 's/ */ /' | cut -f 2 -d ' ' > accepted.trees
```

This gave 62 trees, and we will use these as backbone constraint in our analyses.

To find the log likelihood of the accepted trees:

```
grep "Final LogLikelihood:" all.18S28S.constrained.{1,2,3,4,5,6,7,8,10,12,14,15,16,17,21,22,27,28,32,33,34,36,37,38,41,42,44,45,47,51,52,53,54,56,57,59,62,63,65,66,67,68,69,70,72,73,74,75,76,77,78,81,83,85,86,87,88,89,92,97,99,100}.tree.raxml.log | awk '{print $NF}' | sort > accepted_trees.logL.sorted
```
