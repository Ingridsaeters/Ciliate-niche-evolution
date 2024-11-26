# Data
## 1. Eukbank (ASVs)
Download data from EukBank: https://zenodo.org/records/7804946

### 1.1. Extract ciliate fasta sequences from EukBank

The EukBank fasta file does not contain information about taxonomy, it only has information about amplicon-id and abundance. Extract ciliate headers from the taxonomy file to make a pattern file to extract ciliate fasta sequences.  

```
grep "Ciliophora" eukbank_18S_V4_asvs.tsv > Ciliate_taxo

seqkit grep -r -f <(cut -f1 Ciliate_taxo) eukbank_18S_V4_asvs.fasta > eukbank_ciliate.fasta
```

We have 22896 ciliate sequences. 

Change the fasta header for the ciliate fasta file so that in addition to containing the amplicon-id, it also contains number of samples, number of reads (size), supergroup, taxogroup 1 and taxogroup 2 (this information is given in the taxonomy file). Use the script [replace_fasta_header.pl](./eukbank/replace_fasta_header.pl) that replaces fasta headers with ones provided in a tab delimited file. 

Create a tab delimited file, with one column for the old headers, and one with the new:

```
cat eukbank_18S_V4_asvs.tsv | grep "Ciliophora" | cut -f1-2,4,9-11 | sed -E 's/(.*)\t([0-9]+)\t([0-9]+)\t(.*)\t(.*)\t(.*)/\1\t\1_samples=\2_size=\3_tax=\4_\5_\6/' > replace_fasta_headers.tsv
```

Replace the headers with the replace_fasta_header.pl script.   

```
perl replace_fasta_header.pl eukbank_ciliate.fasta replace_fasta_headers.tsv eukbank_ciliate_replaced.fasta
```

Remove sequences with only NAs in the taxonomy string.  

Make a list of sequences to keep: 

```
grep "Ciliophora" eukbank_ciliate_replaced.fasta > eukbank_ciliate_clean.list
cat eukbank_ciliate_clean.list | tr -d '>' > clean_list
```

Make a fasta file with these sequences

```
seqkit grep -r -f clean_list eukbank_ciliate_replaced.fasta > eukbank_ciliate_clean.fasta
```


After removing sequences with only NAs we have 17705 sequences. 

```
file                         format  type  num_seqs    sum_len  min_len  avg_len  max_len
eukbank_ciliate_clean.fasta  FASTA   DNA     17,705  6,367,340      152    359.6      453
```

### 1.2. Extract corresponding metadata 

We are interested in the following metadata provided in the eukabnk file `eukbank_18S_V4_samples.tsv`:
- sample
- latitude
- longitude
- depth
- altitude
- biome
- collection date
- feature material
- raw_env
- temperature
- salinity

We keep only the columns containing this information.

```
cat eukbank_18S_V4_samples.tsv | cut -f1,6-14,16-17 > eukbank_18SV4_asv.subset.metadata
```

Make a pattern file with ciliate fasta headers, to extract only the rows for ciliates from the ASV table.

```
cat eukbank_ciliate_clean.fasta | grep ">" | cut -f1 -d ";" | tr -d ">" > ciliate_asvs.list
```

The eukbank_18S_V4_counts.tsv file contains information about sample and amplicon. Make a list with only ciliate amplicons. 

```
grep -f ciliate_asvs.list eukbank_18S_V4_counts.tsv > sample_amplicon
```

Make a file to add the ASV with extra information, so it matches the fasta file and trees: 

```
cat clean_list | sed -E 's/(.*)_samples(.*)/\1 \1_samples\2/g' > substitute.list
```

Make a preliminary metadata file for ciliates using the R script `metadata_ciliates.R`. This file will be updated in the steps below to create the final metadata table for our ASVs. 

### 1.3. Assign ASVs to environments

We used the biome, feature_material, and raw_env information to assign ASVs to six different environments: (1) Marine pelagic, (2) Marine benthic, (3) Soil, (4) Freshwater, (5) Inland saline/hypersaline, and (6) animal-associated environment. This information is in the file [biomes_to_envs.txt](./eukbank/biomes_to_envs.txt).

Add the environment information to the metadata file.

```
cat biomes_to_envs.txt| grep -v "Comments" | while read line; do biome=$(echo $line | cut -f 1); env=$(echo $line | cut -f 2); grep "$biome" metadata_ciliates.csv | sed -E 's/(.*)/\1,'$env'/' >> metadata_ciliates_env.csv; done
```

We now have a file listing ASVs found in each sample, the corresponding metadata, and the environment to which we assign the sample to (marine pelagic, marine benthic, soil, freshwater, inland saline/hypersaline, animal-associated). However, many ASVs can be found in multiple environments. We used a custom R script [prevalence_envs.R](./eukbank/prevalence_envs.R) to: 

(1) Generate a presence-absence table indicating which ASVs are found in which environment. This table `ciliate_env_prevalence.tsv` is used in later steps to decorate the dated ciliate tree in anvio.

(2) Generate lists of marine pelagic, and soil ASVs. An ASV is considered to belong to an enviornment if at least 75% of the signal stems from that environment.

In order to do this, we also need the abundance of each ASV in every sample. We generate this file `ciliate_asvs_V4_counts.tsv` as follows:

Download the file `eukbank_18S_V4_counts.tsv` from the eukbank Zenodo repository. 

```
## Subset counts file to get only ciliate ASVs

awk 'NR==FNR{a[$1]} NR!=FNR{if ($1 in a){print $0}}' ciliate_asvs.list eukbank_18S_V4_counts.tsv > ciliate_asvs_V4_counts.tsv

### Add amplicon column to metadata file. This will help in the next step to join the metadata file with the counts file.
cat metadata_ciliates_env.csv| sed -E 's/(.*)(_samples.*)/\1,\1\2/' > csv
mv csv > metadata_ciliates_env.csv 
```

Run `prevalence_envs.R` with the input files `ciliate_asvs_V4_counts.tsv` and `metadata_ciliates_env.csv`!

### Make metadata files for soil and marine pelagic ASVs

After constructing phylogenies, use the script subset_metadata.R to create separate metadata files for soil and marine pelagic ASVs. The list files are based on the marine pelagic and soil ASVs that are in the final phylogenies. 


## 2. EukRibo (QUESTION FOR INGRID - DIDNT WE SPEND TIME RELABELLING SOME EUKRIBO SEQUENCES BASED ON TAXONOMY??)

EukRibo is a database of reference small-subunit ribosomal RNA gene (18S rDNA) sequences of eukaryotes. It's aim is to represent a subset of highly trustable sequences covering the whole known diversity of eukaryotes, with a special focus on protists, manually veryfied taxonomic identifications, and relatively low level of redundancy. The dataset is composed of the V4 hypervariable region of the nuclear small submit rRNA gene, along with the associated metadata. The V4 region is widely-used to uncover the diversity and distributions of most of the major protistan taxa.

### 2.1. Extract ciliate sequences

The EukRibo_ciliate.fasta file is derived from the 46346_EukRibo-02_full_seqs_2022-07-22.fas file in "EukRibo: a manually curated eukaryotic 18S rDNA reference database" (https://zenodo.org/record/6896896).

Extract ciliate sequences:

```
seqkit grep -rp "Ciliophora" 46346_EukRibo-02_full_seqs_2022-07-22_nospace.fas > EukRibo_ciliate.fasta
```

### 2.2. Reduce redundancy - Construct a new EukRibo dataset with only unique sequences

Reduce redundancy by constructing a new EukRibo dataset with unique sequences. Check how many duplicate sequences the dataset contains:

```
cat EukRibo_ciliate.formatted.fasta | grep ">" | sed -E 's/>.*_(Eukaryota.*)/\1/' | awk 'l[$0]++{d++}END{print d, "(lines are duplicates)"}'
```

129 sequences were duplicates.

Make a pattern file with headers for the unique ASVs:

```
cat EukRibo_ciliate.formatted.fasta | grep ">" | sed -E 's/>.*_(Eukaryota.*)/\1/' | sort -u > EukRibo_unique
```

Add accession numbers to the pattern file: 

```
cat EukRibo_unique | while read line; do grep -m1 "$line" EukRibo_ciliate.formatted.fasta; done | tr -d ">" > EukRibo_unique_headers
```

Use pattern file to extract unique ASVs: 

```
seqkit grep -f EukRibo_unique_headers EukRibo_ciliate.formatted.fasta > EukRibo_unique.fasta
```

### Format fasta headers

Replace : with _ so that the file can be processed by RAxML.

```
cat EukRibo_unique.fasta | tr ':' '_' > EukRibo_unique.formatted.fasta
```

## 3. Long-read metabarcoding data

This dataset (derived from [Jamy et al 2022](https://doi.org/10.1038/s41559-022-01838-4) consists of more than 1,000 taxonomically annotated ciliate OTUs from marine, terrestrial, and freshwater habitats. The long-read data have increased phylogenetic signal, which can be used to infer robust backbone phylogenies onto which the V4 metabarcoding data can be placed.

### 3.1. long_read.18S

The `long_read.18S.ciliate.fasta` file is derived from the `long_read.18S.otus.fasta` file downloaded from  [Data for "Global patterns and rates of habitat transitions across the eukaryotic tree of life"](https://figshare.com/articles/dataset/Global_patterns_and_rates_of_habotat_transitions_across_the_eukaryotic_tree_of_life/15164772).

Extract ciliate sequences: 

```
seqkit grep -rp "Ciliophora" long_read.18S.otus.fasta > long_read.18S.ciliate.fasta
```

### 3.2. long_read.28S

The `long_read.28S.ciliate.fasta` file is derived from the `long_read.28S.otus.fasta` file downloaded from  [Data for "Global patterns and rates of habitat transitions across the eukaryotic tree of life"](https://figshare.com/articles/dataset/Global_patterns_and_rates_of_habotat_transitions_across_the_eukaryotic_tree_of_life/15164772).

Extract ciliate sequences: 

```
seqkit grep -rp "Ciliophora" long_read.28S.otus.fasta > long_read.28S.ciliate.fasta
```

## 4. Outgroup

The outgroup includes Dinoflagellates, Apicomplexa, Colpodellidea and Colponemids.

### 4.1. EukRibo

Make a list with all EukRibo sequences for the outgroup called outgroup.EukRibo.list. Extract corresponding fasta sequences: 

```
grep -f outgroup.EukRibo.list 46346_EukRibo-02_full_seqs_2022-07-22.nospace.fas | tr -d ">" > outgroup.EukRibo.list1
```
```
seqkit grep -f outgroup.EukRibo.list1 46346_EukRibo-02_full_seqs_2022-07-22.nospace.fas > outgroup.EukRibo.fasta
```

#### Formatting

Replace : with _ so that the file can be processed by RAxML: 

```
cat outgroup.EukRibo.fasta | tr ':' '_' > outgroup.EukRibo.formatted.fasta
```

### 4.2. PacBio

Make a list with all PacBio sequences for the outgroup called outgroup.LongRead.list. Extract corresponding fasta sequences: 

```
grep -f outgroup.LongRead.list long_read.28S.otus.fasta | tr -d ">" > outgroup.LongRead28S.list
seqkit grep -f outgroup.LongRead28S.list long_read.28S.otus.fasta > outgroup.long_read.28S.fasta

grep -f outgroup.LongRead.list long_read.18S.otus.fasta | tr -d ">" > outgroup.LongRead18S.list
seqkit grep -f outgroup.LongRead18S.list long_read.18S.otus.fasta > outgroup.long_read.18S.fasta
```

## 5. Concatenation

Concatenate all 18S files and all 28S files:

```
cat EukRibo_unique.formatted.fasta long_read.18S.ciliate.fasta outgroup.EukRibo.formatted.fasta outgroup.long_
read.18S.fasta > all.18S.fasta

cat long_read.28S.ciliate.fasta outgroup.28S.fasta > all.28S.fasta
```

Statistics after concatenation:

```
file           format  type  num_seqs    sum_len  min_len  avg_len  max_len
all.18S.fasta  FASTA   DNA      2,824  4,276,063      616  1,514.2   10,315
all.28S.fasta  FASTA   DNA      1,181  3,013,144    1,500  2,551.3    4,449
```

## 6. Cluster sequences

To further reduce redundancy, cluster the concatenated 18S sequences with vsearch.     

We chose a threshold of 100% to be conservative.

```
vsearch --cluster_fast all.18S.fasta --threads 4 --id 1 --uc 18S.cluster100.uc --centroids 18S.cluster100.fasta
```

This gave the following results:\
Clusters: 2671 Size min 1, max 5, avg 1.1\
Singletons: 2552, 90.4% of seqs, 95.5% of clusters

