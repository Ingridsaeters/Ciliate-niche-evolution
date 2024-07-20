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

4. Align with mafft-linsi (18S.mafft_linsi.sbatch)


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

Check if the 18S file and 28S file have the same number of sequences. Some might have been removed from the 18S file during the clustering step. If the number of sequences in the two files are different, find out which sequences these are: 

```
diff <(cat all.18S.aligned.trimal99.5.formatted.fasta | grep ">" | sort)  <(cat all.28S.aligned.trimal99.5.formatted.fasta | grep ">" | sort) | grep "^>" | awk -F\> '{print $3}' > difference.list
wc -l differece.list
```

Remove these sequences from the 28S file, using the filter_fasta_by_list_of_headers.py python script (this requires that biopython is installed):

```
./filter_fasta_by_list_of_headers.py all.28S.aligned.trimal99.5.formatted.fasta difference.list > 28S.filtered.fasta
```

Before concatenating, make a conda environment and install the following program:

```
conda install -c "bioconda/label/cf201901" snippy
```

Then concatenate sequences with the concat.pl script:

```
perl ./concat.pl all.18S.aligned.trimal99.5.formatted.fasta all.28S.aligned.trimal99.5.formatted.fasta > all.18S28S.fasta
```

Statistics for concatenated file: 

```
file              format  type  num_seqs     sum_len  min_len  avg_len  max_len
all.18S28S.fasta  FASTA   DNA      2,671  15,983,264    5,984    5,984    5,984
```

## Taxonomic annotation

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
## Compute bootstrap support
Use the script bootstrap.sbatch to get support values. Activate the script with this command:

```
for i in $(seq 10); do echo $i; sbatch boostrap.sbatch ${i}; sleep 1; done
```

This creates 100 bootstrap replicates (10 in each bootstrap file)

Then concatenate the bootstrap files:

```
cat *.bootstraps > all.18S28S.constrained.bs.bootstraps
```

And compute support for a tree, here exemplified by tree 15:

```
raxml-ng --support --tree all.18S28S.constrained.15.tree.raxml.bestTree --bs-trees all.18S28S.constrained.bs.bootstraps --prefix support --threads 2
```

Check how many nodes in the tree have support of over 50% using the python script compute_support_over_50.py. 

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

Decide on a reasonable threshold value to choose which cluster level to select trees from. Choose one arbitrary tree from each level below this cluster. We chose a treshold of 400 differences. We moved forward with tree 49, 11, 79, 82, 62, 46, 64, 37, 75, 70, 50, 65, 17, 4, 18, 33, 90, 21, 72, 51, 48, 13. 
