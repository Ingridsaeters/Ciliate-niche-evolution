# Inferring 100 Maximum Likelihood backbone trees

We made symlink copies to the datasets we are using:

```
ln -s ~/nn8118k/ingrid/ciliate_niche/data/18S.cluster100.fasta .
ln -s ~/nn8118k/ingrid/ciliate_niche/data/all.28S.fasta .
```

## Alignments

Load MAFFT. 

```
module load MAFFT/7.490-GCC-11.2.0-with-extensions
```

Run MAFFT-L-ins-i on the 18S and 28S sequences. The advantage of L-ins-i is that it can align a set of sequences containing sequences flanking around one alignable domain. Since L-ins-i is very computationally intensive, we made ran the jobs with the sbatch scripts 18S.mafft_linsi.sbatch and 28S.mafft_linsi.sbatch, with 20 threads. 

Preliminary analyses have showed that some of the 18S sequences are very long, spanning the 18S gene, and so the alignment for the 18S sequences were taking a very long time. Therefore we did the following steps for the 18S sequences:

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

4. Align with mafft-linsi (3 days)


Using seqkit stats gave the following information:

```
file                   format  type  num_seqs     sum_len  min_len  avg_len  max_len
all.18S.aligned.fasta  FASTA   DNA      2,671  17,105,084    6,404    6,404    6,404
all.28S.aligned.fasta  FASTA   DNA      1,181  10,238,089    8,669    8,669    8,669
```

## Trimming

The 18S and 28S alignemnts were trimmed using trimal following the eukref pipeline (https://pr2-database.org/eukref/pipeline_overview/).

First i downloaded trimal version 1.2 from http://trimal.cgenomics.org/downloads.

After making the command executable I added it to my path by going into vim ~/.bash_profile and adding /trimAl/source to the path.

 I ran trimal with different tresholds (99.5%, 99%, 98% and 97%) to see the differences. To be concervative we chose a trimming treshold of 99.5%.

```
trimal -in all.28S.aligned.fasta -out all.28S.aligned.trimal99.5.fasta -gt 0.005
trimal -in all.18S.aligned.fasta -out all.18S.aligned.trimal99.5.fasta -gt 0.005
```

Statistics:

file                              format  type  num_seqs    sum_len  min_len  avg_len  max_len
all.18S.aligned.trimal99.5.fasta  FASTA   DNA      2,671  5,526,299    2,069    2,069    2,069
all.28S.aligned.trimal99.5.fasta  FASTA   DNA      1,181  4,623,615    3,915    3,915    3,915

## Formatting sequences to remove the text that trimal adds.

```
cat all.28S.aligned.trimal99.5.fasta | sed 's/ 3915 bp//' | tr '.' '-' >all.28S.aligned.trimal99.5.formatted.fasta
cat all.18S.aligned.trimal99.5.fasta | sed 's/ 2069 bp//' | tr '.' '-' > all.18S.aligned.trimal99.5.formatted.fasta
```

## Concatenating sequences

I concatenated the sequences using the concat perl script:

```
perl ./concat all.18S.aligned.trimal99.5.formatted.fasta all.28S.aligned.trimal99.5.formatted.fasta > all.18S28S.fasta
```

To run the script, I made a conda environment called bioperl and installed the following program:
```
conda install -c "bioconda/label/cf201901" snippy
```

After concatenating the number of sequences was 2789, while the number of sequences in the 18S file was 2671, so something had gone wrong. 118 sequeces must be different. To find the sequences with different headers, the following commands were run:

```
diff <(cat all.18S.aligned.trimal99.5.formatted.fasta | grep ">" | sort)  <(cat all.28S.aligned.trimal99.5.formatted.fasta | grep ">" | sort) | grep "^>" | awk -F\> '{print $3}' > diff
wc -l diff
```

This gave an output of 118 sequences with different heaeders. Checking the different files, we found that these 118 sequences were removed from the 18S file during the clustering step. Therefore we decided to remove them from the 28S file before concatenating. They were removed with the filter_fasta_by_list_of_headers.py python script (biopython was installed with pip install):

The sequences were removed with this command:

```
./filter_fasta_by_list_of_headers.py all.28S.aligned.trimal99.5.formatted.fasta diff > 28S.filtered.fasta
```

Then concatination was repeated:

```
perl ./concat all.18S.aligned.trimal99.5.formatted.fasta 28S.filtered.fasta > all.18S28S.fasta
```

Now the number of sequences is 2671, which is the same as the number of sequences in the 18S file, so this is correct.
file              format  type  num_seqs     sum_len  min_len  avg_len  max_len
all.18S28S.fasta  FASTA   DNA      2,671  15,983,264    5,984    5,984    5,984

## Reannotating

Plagiopylea had been wrongly annotated to Prosteomatea, but should be it's own main group. We therefore need to reannotate it.

Some groups had been wrongly annotated to a main group, they should be incertae sedis (not placed within a specific group). Their headers were changed. This was done for the following groups:
- Discotrichidae should not be grouped as nassophorea – This is incertae sedis within CONthreeP.
- Cyclotrichium and Pseudotrachelocerca are grouped as a Prostomatean, needs to be reannotated. These are incertae sedis within CONthreeP.

Numbers of changed sequences:
- Plagiopylea: 28
- Discotrichidae: 57
- Cyclotrichium: 3
- Pseudotrachelocerca: 1

Also, looking through preliminary trees indicated that this sequence hould be renamed:
c-7036_conseq_Otu0060_466_freshwater_permafrost_Eukaryota_TSAR_Alveolata_Ciliophora_Prostomatea_2_Prostomatea_2_X_Placidae_Placus_Genus

Checking it on BLAST gave a percentage identity of 92,99% for the 18S sequence, and 89,2% for the 28S sequence. This indicates that it has been wrongly annotated to Prostomatea, since it appears in a different part of the tree, and has such low percentage identity. We renamed it to this:
c-7036_conseq_Otu0060_466_freshwater_permafrost_Eukaryota_TSAR_Alveolata_Ciliophora

Headers were changed with the replace_fasta_header.pl script. To run this script we needed to make a tsv file with one column for old headers and one column for new headers:

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
-F'\t' says that it should use tab as the field delimiter on input. -v OFS='\t' says that it should use tab as the field delimiter on output. NR>=2 {sub(/Discotrichidae_NASSO_1_NASSO_1_/, "Discotrichidae_", $2)} says that it should remove /Discotrichidae_NASSO_1_NASSO_1_ from field 2 only for lines after the first line, and replace it with Discotrichidae_. 1 is awk's cryptic shorthand for print-the-line.

To check that the correct number of headers had been changed, the following command was run between each step to count the differences between the header files:

```
diff <(cat all.18S28S.headers.tsv3 | grep ">" | sort)  <(cat all.18S28S.headers.tsv4 | grep ">" | sort) | grep "^>" | awk -F\> '{print $3}' | wc -l
```

In this specific command you get the number of differences between the tsv4 and tsv3 file.

The fasta headers shouldn't have the character > in the tsv file, so this was removed:

```
cat all.18S28S.headers.tsv5 | tr -d ">" > all.18S28S.headers.tsv6
```
The changing of headers script was run with the following command:

```
perl replace_fasta_header.pl all.18S28S.fasta all.18S28S.headers.tsv6 all.18S28S.replaced.fasta
```


We also noted the following:
1. Odontostomatida. In the EukRibo dataset, the group is in SAL (no further group specified). But in Adl et al, we see that Odontostomatida are placed within Armophorea. In our phylogenies, the group falls within Litostomatea (we havent computed bootstrap support for it though).
2. Kiitrichidae. In the EukRibo dataset, this group is also in an unspecified position in SAL. In Adl et al. the group is placed in Spirotrichea (which is also consistent with our phylogenies).

## Making files for the constraint groups

We will follow the reference tree from Rajter and Dunthorn 2021 (file:///C:/Users/ingri/Downloads/MBMG_article_69602_en_1.pdf). We made a file called constraint.tree with a newick tree of the main groups. 

Mesodonium was constrained to be within Litostomatea.
Caenomorphidae, Cariacotrichea and Muranotrichea were constrained to be within Armophorea.
Licnophoridae was constrained to be within Spirotrichea.
Microthoracida was constrained to be within Nassophorea.
Askenasia and Paraspathidium were constrained to be within Prostomatea.

To output all taxa that we want to constrain, we made one file for each major group using the following commands:

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

All sequences of Microthoracida were already annotated to Nassophorea. Sequences of Paraspathidium were already annotated to Prostomatea.

To remove duplicates, and process the files to have all taxon names on a single line separated by commas, the following for loop was run:

```
for i in *txt; do sort $i | uniq | sed -E 's/(.*)/\1, /' | tr -d '\n' | sed -E 's/, $//' > "$i".csv ; done
```

To combine all the files, a script called setup_constraint.pl was constructed.Running this script created two files:
- Ciliate_constraint.txt
- Ciliate_constraint.txt.tre

The constraint tree file has 2425 taxa.

## Create constraint tree

Then the constraint.sbatch script was made to create a constraint tree. 

Run the script with this command to make 100 trees:

```
for i in $(seq 100); do echo $i; sbatch <name of sbatch script> ${i}; sleep 1; done
```

## Apply all statistical significance tests implemented in IQ-TREE to this set of 100 ML trees.

First install iqtree.

We found the tree with the best likelihood value with the following command:

```
grep "Final LogLikelihood: " all.18S28S.constrained.*.tree.raxml.log | awk '{print $NF}' | sort
```

We found that tree 70 had the best log likelihood value of the 100, and therefore we used this tree for test comparison. We made a concatenated file with all the 100 trees:

```
cat all.18S28S.constrained.*.tree.raxml.bestTree > RAxML_bestTree.all100trees.constrained
```

Then we used the iqtree.test script. 

Information about the statistical tests: 
- Kishino-Hasegawa test: Uses differences in support provided by individual sites for two trees to determine if the overall differences between the trees are significantly greater than expected from random sampling error. Assumes that characters are independant and identically distributed. Should be of trees that are selected a priori.
- Shimodaira-Hasegawa test: Similar to KH, but more statistical correct in cases where trees are not selected a priori. Can be used to test one tree against another tree that was found by searching for the best tree among a large set of candidate trees.
- RELL: A fast approximation of bootstrapping to assess variability in likelihood ratio test statistics. Instead of resampling characters and conducting a full phylogenetic analysis, we simply resample the site-likelihoods from the original.
- Approximately Unbiased (AU) test (Shimodaira): The SH test becomes too conservative when testing many trees. The AU test fixes this problem. Uses a multiscale bootstrap technique for hypothesis testing of regions to reduce test bias.
- c-ELW: Expected likelihood weight.

## Select trees

Assign ML trees to a “plausible” ML tree set that are not significantly worse than the best-scoring ML tree under any statistical significance test implemented in IQ-TREE. This assignment is conservative, as it will yield the smallest plausible tree set and circumvents the long-lasting debate about which phylogenetic significance test is most appropriate.

That means that we would only accept trees with output plus sign (+) for every test. We found these trees with the following command:

```
grep -A 101 "Tree      logL    deltaL  bp-RELL    p-KH     p-SH    p-WKH    p-WSH       c-ELW       p-AU" all.18S28S.replaced.phy.iqtree | sed -E 's/-104/104/' | grep -v "-" | sed -E 's/ */ /' | cut -f 2 -d ' ' > accepted.trees
```

This gave 62 trees, and we will use these as backbone constraint in our analyses.

To find the log likelihood of our accepted trees:

```
grep "Final LogLikelihood:" all.18S28S.constrained.{1,2,3,4,5,6,7,8,10,12,14,15,16,17,21,22,27,28,32,33,34,36,37,38,41,42,44,45,47,51,52,53,54,56,57,59,62,63,65,66,67,68,69,70,72,73,74,75,76,77,78,81,83,85,86,87,88,89,92,97,99,100}.tree.raxml.log | awk '{print $NF}' | sort > accepted_trees.logL.sorted
```
