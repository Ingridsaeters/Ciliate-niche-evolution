# Data
## Eukbank
Download data from EukBank: https://zenodo.org/records/7804946Download data from EukBank: https://zenodo.org/records/7804946  

### Extract ciliate fasta sequences from EukBank

The EukBank fasta file does not contain information about taxonomy, it only has information about amplicon-id and abundance. Extract ciliate headers from the taxonomy file to make a pattern file to extract ciliate fasta sequences.  

```
grep "Ciliophora" eukbank_18S_V4_asvs.tsv > Ciliate_taxo
```

```
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

### Extract metadata

Extract the following metadata:
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

```
cat eukbank_18S_V4_samples.tsv | cut -f1,6-14,16-17 > eukbank_18SV4_asv.subset.metadata
```

### Extract ciliate ASVs

Make a pattern file with ciliate fasta headers, to extract only the rows for ciliates from the ASV table.

```
cat eukbank_ciliate_clean.fasta | grep ">" | cut -f1 -d ";" | tr -d ">" > ciliate_asvs.list
```

The eukbank_18S_V4_counts.tsv file contains information about sample and amplicon. Make a list with only ciliate ampicons. 

```
grep -f ciliate_asvs.list eukbank_18S_V4_counts.tsv > sample_amplicon
```

Make a file to add the ASV with extra information, so it matches the fasta file and trees: 

```
cat clean_list | sed -E 's/(.*)_samples(.*)/\1 \1_samples\2/g' > substitute.list
```

Make a metadata file for ciliates using the R script `metadata_ciliates.R`. 

### Assign ASVs to environments

We used the biome, feature_material, and raw_env information to assign ASVs to six different environments: (1) Marine pelagic, (2) Marine benthic, (3) Soil, (4) Freshwater, (5) Inland saline/hypersaline, and (6) animal-associated environment. This information is in the file `biomes_to_envs.txt`.

Add the environment information to the metadata file.

```
cat biomes_to_envs.txt| grep -v "Comments" | while read line; do biome=$(echo $line | cut -f 1); env=$(echo $line | cut -f 2); grep "$biome" metadata_ciliates.csv | sed -E 's/(.*)/\1,'$env'/' >> metadata_ciliates_env.csv; done
```

### Extract soil ciliate ASVs

Extract soil ciliate ASVs: 

```
grep "soil" metadata_ciliates_formatted > metadata_soil
```

Exclude ASVs that does not have coordinates by removing rows if they contain "NA" in the columns for latitude and longitude: 

```
awk -F '\t' '$4$5~!/NA/' metadata_soil > metadata_soil_reduced
```

Extract unique soil fasta sequences:

```
seqkit grep -f <(cat metadata_soil_reduced | cut -f1 | sort | uniq) eukbank_ciliate_clean.fasta > soil/eukbank_ciliate_soil.fasta
```

Repeat for marine and feshwater. 


## EukRibo 

EukRibo is a database of reference small-subunit ribosomal RNA gene (18S rDNA) sequences of eukaryotes. It's aim is to represent a subset of highly trustable sequences covering the whole known diversity of eukaryotes, with a special focus on protists, manually veryfied taxonomic identifications, and relatively low level of redundancy. The dataset is composed of the V4 hypervariable region of the nuclear small submit rRNA gene, along with the associated metadata. The V4 region is widely-used to uncover the diversity and distributions of most of the major protistan taxa.

### Extract data

The EukRibo_ciliate.fasta file is derived from the 46346_EukRibo-02_full_seqs_2022-07-22.fas file in "EukRibo: a manually curated eukaryotic 18S rDNA reference database" (https://zenodo.org/record/6896896).

Extract ciliate sequences:

```
seqkit grep -rp "Ciliophora" 46346_EukRibo-02_full_seqs_2022-07-22_nospace.fas > EukRibo_ciliate.fasta
```

### Reduce redundancy - Construct a new EukRibo dataset with only unique ASVs

Reduce redundancy by constructing a new EukRibo dataset with unique ASVs. Check how many duplicate ASVs the dataset contains:

```
cat EukRibo_ciliate.formatted.fasta | grep ">" | sed -E 's/>.*_(Eukaryota.*)/\1/' | awk 'l[$0]++{d++}END{print d, "(lines are duplicates)"}'
```

129 ASVs were duplicates.

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

## PacBio

This dataset consists of more than 1,000 taxonomically annotated ciliate OTUs from marine, terrestrial, and freshwater habitats. The long-read data have increased phylogenetic signal, which can be used to infer robust backbone phylogenies onto which the V4 metabarcoding data can be placed.

### long_read.18S

The long_read.18S.ciliate.fasta file is derived from the long_read.18S.otus.fasta file which can be found in Data for "Global patterns and rates of habitat transitions across the eukaryotic tree of life" (https://figshare.com/articles/dataset/Global_patterns_and_rates_of_habotat_transitions_across_the_eukaryotic_tree_of_life/15164772).

Extract ciliate sequences: 

```
seqkit grep -rp "Ciliophora" long_read.18S.otus.fasta > long_read.18S.ciliate.fasta
```

### long_read.28S

The long_read.28S.ciliate.fasta file is derived from the long_read.28S.otus.fasta file which can be found in Data for "Global patterns and rates of habitat transitions across the eukaryotic tree of life" (https://figshare.com/articles/dataset/Global_patterns_and_rates_of_habotat_transitions_across_the_eukaryotic_tree_of_life/15164772).

Extract ciliate sequences: 

```
seqkit grep -rp "Ciliophora" long_read.28S.otus.fasta > long_read.28S.ciliate.fasta
```

## Outgroup

My outgroup includes Dinoflagellates, Apicomplexa, Colpodellidea and Colponemids.

### EukRibo

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

### PacBio

Make a list with all PacBio sequences for the outgroup called outgroup.LongRead.list. Extract corresponding fasta sequences: 

```
grep -f outgroup.LongRead.list long_read.28S.otus.fasta | tr -d ">" > outgroup.LongRead28S.list
```
```
seqkit grep -f outgroup.LongRead28S.list long_read.28S.otus.fasta > outgroup.long_read.28S.fasta
```
```
grep -f outgroup.LongRead.list long_read.18S.otus.fasta | tr -d ">" > outgroup.LongRead18S.list
```
```
seqkit grep -f outgroup.LongRead18S.list long_read.18S.otus.fasta > outgroup.long_read.18S.fasta
```

## Concatenation

Concatenate all 18S files and all 28S files:

```
cat EukRibo_unique.formatted.fasta long_read.18S.ciliate.fasta outgroup.EukRibo.formatted.fasta outgroup.long_
read.18S.fasta > all.18S.fasta
```
```
cat long_read.28S.ciliate.fasta outgroup.28S.fasta > all.28S.fasta
```

Statistics after concatenation:

```
file           format  type  num_seqs    sum_len  min_len  avg_len  max_len
all.18S.fasta  FASTA   DNA      2,824  4,276,063      616  1,514.2   10,315
all.28S.fasta  FASTA   DNA      1,181  3,013,144    1,500  2,551.3    4,449
```

## Cluster sequences

To further reduce redundancy, cluster the concatenated 18S sequences with vsearch.     

We chose a treshold of 100% to be conservative.

```
conda install -c bioconda vsearch
```
```
vsearch --cluster_fast all.18S.fasta --threads 4 --id 1 --uc 18S.cluster100.uc --centroids 18S.cluster100.fasta
```

This gave the following results:\
Clusters: 2671 Size min 1, max 5, avg 1.1\
Singletons: 2552, 90.4% of seqs, 95.5% of clusters

