# Data

In this folder we have the data we used in our analyses. A detailed description on how we extracted the data is given in this README file. 

## Eukbank
### Extracting ciliate sequences from EukBank

Need to specify where the EukBank data is extracted from. 

In the fasta file from EukBank we only had the amplicon-id and abundance (size) in the headers, not information about taxonomy. So to extract only the ciliate sequences, we had to first extract the ciliate headers from the taxonomy file:

```
grep "Ciliophora" eukbank_18SV4_asv.taxo > Ciliate_taxo
```

This was used as a pattern file to extract the ciliate sequences from the fasta file.

```
seqkit grep -r -f <(cut -f1 Ciliate_taxo) eukbank_18SV4_asv.fasta > eukbank_ciliate.fasta
```

We changed the fasta header for the ciliate fasta file so that in addition to containing the amplicon-id and abundance (size) it also contained supergroup, taxogroup 1 and taxogroup 2 (this information is given in the taxonomy file). We used the script replace_fasta_header.pl that replaces fasta headers with ones provided in a tab delimited file. 

We therefore first made a tab delimited file, with one column for the old headers, and one with the headers we wanted:

```
cat eukbank_18SV4_asv.taxo | grep "Ciliophora" | cut -f1-2,7-9 | sed -E 's/(.*)\t([0-9]+)\t(.*)\t(.*)\t(.*)/\1;size=\2\t\1;size=\2;tax=\3_\4_\5/' > replace_fasta_headers.tsv
```

Running the script replace_fasta_header.pl created a new fasta file eukbank_ciliate_replaced.fasta with the headers we wanted.

We removed sequences that had only NA in their taxonomy string, and saved this to a file called eukbank_ciliate_clean.fasta.

### Extracting metadata

We wanted to extract the following metadata:\
-sample\
-latitude\
-longitude\
-depth\
-altitude\
-biome\
-material\
-collection date

We extracted the columns with this information with the following command:

```
cat eukbank_18SV4_asv.metadata | cut -f 2,5-8,11,13,14 > eukbank_18SV4_asv.subset.metadata
```

We decided that the information we want to include in the fasta headers is sample and biome, so we made a new file with one column for only the sample name and another for <samplename_biome>. We also replaced tabs with underscore in the biome name. We removed the ENVO number at the end of the biome name as this is not necessary to include. We did so with the following command:

```
cat eukbank_18SV4_asv.subset.metadata | cut -f1,6 | sed -E 's/ENVO_[0-9]+//' | tr -d '()' | sed -E 's/(.*)\t(.*)/\1\t\1_\2/' | tr -s ' ' '_' | sed -E 's/biome_/biome/' > eukbank_18SV4_asv.metadata.headers
```

To implement this in the fasta headers, we need information from the ASV table. The number of samples in the eukbank ASV table is 15541. 
The number of ASVs is 460147. We made a pattern file with the ciliate ASVs, so that we can extract only the rows for the ciliates from the asv table.

```
cat eukbank_ciliate_clean.fasta | grep ">" | cut -f1 -d ";" | tr -d ">" > ciliate_asvs.list
```

The number of ciliate asvs is 18816.
This is the command for extracting the Ciliate rows from the table:

```
grep -f ciliate_asvs.list eukbank_18SV4_asv.table >> eukbank_18SV4_asv.subset.table
```

Then we made an R script to remove all columns with only 0s from the table. We installed R with this command:

```
module load R/4.2.1-foss-2022a
```

We ran the subset.R script which removes columns with only 0's.

The number of columns after removing 0's was 14735.

### Making an ASV table for ciliates with subset of metadata

The ASV table we have extracted (eukbank_18SV4_asv.subset.table) is in wide format, we want it to be in long format, and also to include the metadata we have extracted. To do so, we ran the Rscript long_asv_metadata.R. 

This made a table (asv_long_metadata) with the following column headers:\
-sample\
-amplicon\
-abundance\
-latitude\
-longitude\
-depth\
-altitude\
-biome\
-material\
-collection_date

We removed the " symbol from the file:

```
cat asv_long_metadata | tr -d '"' > asv_long_metadata
```

The script also gave the number of rows for each file:\
asv_wide: 18816\
asv_long: 1016195\
metadata: 13055\
asv_long_metadata: 773967\

### Extracting soil ciliate ASVs

To extract the soil ciliate ASVs we used the following command:

```
grep "soil" asv_long_metadata > asv_long_metadata_soil
```

But we want to only include the ASVs that have coordinates, so to make sure of this we used this command, which removes rows if they contain "NA" in the columns for latitude and longitude (column 4 and 5):

```
awk -F '\t' '$4$5~!/NA/' asv_long_metadata_soil > asv_long_metadata_soil_reduced
```

To extract only unique soil fasta sequences, we used the following command:

```
seqkit grep -r -f <(cat asv_long_metadata_soil_reduced | cut -f2 | sort | uniq) eukbank_ciliate_clean.fasta > soil/eukbank_ciliate_soil.fasta
```

## EukRibo 

EukRibo is a database of reference small-subunit ribosomal RNA gene (18S rDNA) sequences of eukaryotes. It's aim is to represent a subset of highly trustable sequences covering the whole known diversity of eukaryotes, with a special focus on protists, manually veryfied taxonomic identifications, and relatively low level of redundancy. The dataset is composedof the V4 hypervariable region of the nuclear small submit rRNA gene, along with the associated metadata. The V4 region is widely-used to uncover the diversity and distributions of most of the major protistan taxa.

### Extracting the data

The EukRibo_ciliate.fasta file is derived from the 46346_EukRibo-02_full_seqs_2022-07-22.fas file in "EukRibo: a manually curated eukaryotic 18S rDNA reference database" (https://zenodo.org/record/6896896).

We extracted the ciliate sequences with the following command:

```
seqkit grep -rp "Ciliophora" 46346_EukRibo-02_full_seqs_2022-07-22_nospace.fas > EukRibo_ciliate.fasta
```
### Formatting fasta headers

We replaced : with _ so that the file could be processed by RAxML. 

```
cat EukRibo_ciliate.fasta | tr ':' '_' > EukRibo_ciliate.formatted.fasta
```

### Reducing redundancy - Constructing a new EukRibo dataset with only unique species

To reduce redundancy, a new dataset for EukRibo was first constructed with only unique species. To check how many duplicate species the dataset contains the following command was used:

```
cat EukRibo_ciliate.formatted.fasta | grep ">" | sed -E 's/>.*_(Eukaryota.*)/\1/' | awk 'l[$0]++{d++}END{print d, "(lines are duplicates)"}'
```
This revealed that 129 species were duplicates.

To make a new file with only unique species, first a pattern file had to be created (with the pattern we wanted to extract from the original file with seqkit grep). The pattern file was created with the following command:

```
cat EukRibo_ciliate.formatted.fasta | grep ">" | sed -E 's/>.*_(Eukaryota.*)/\1/' | sort -u > EukRibo_unique
```

Adding accession numbers to the pattern file: 

```
cat EukRibo_unique | while read line; do grep -m1 "$line" EukRibo_ciliate.formatted.fasta; done | tr -d ">" > EukRibo_unique_headers
```

The new file that was created could then be used as a pattern file to get the unique sequences using this command:

```
seqkit grep -f EukRibo_unique_headers EukRibo_ciliate.formatted.fasta > EukRibo_unique.fasta
```

Then the new unique EukRibo file was formatted again for RAxML:

```
cat EukRibo_unique.fasta | tr ':' '_' > EukRibo_unique.formatted.fasta
```

## PacBio

This dataset consists of more than 1,000 taxonomically annotated ciliate OTUs from marine, terrestrial, and freshwater habitats. The long-read data have increased phylogenetic signal, which can be used to infer robust backbone phylogenies onto which the V4 metabarcoding data can be placed.

### long_read.18S

The long_read.18S.ciliate.fasta file is derived from the long_read.18S.otus.fasta file which can be found in Data for "Global patterns and rates of habitat transitions across the eukaryotic tree of life" (https://figshare.com/articles/dataset/Global_patterns_and_rates_of_habotat_transitions_across_the_eukaryotic_tree_of_life/15164772).

We extracted the ciliate sequences with the following command:

```
seqkit grep -rp "Ciliophora" long_read.18S.otus.fasta > long_read.18S.ciliate.fasta
```

### long_read.28S

The long_read.28S.ciliate.fasta file is derived from the long_read.28S.otus.fasta file which can be found in Data for "Global patterns and rates of habitat transitions across the eukaryotic tree of life" (https://figshare.com/articles/dataset/Global_patterns_and_rates_of_habotat_transitions_across_the_eukaryotic_tree_of_life/15164772).

We extracted the ciliate sequences with the follwing command:

```
seqkit grep -rp "Ciliophora" long_read.28S.otus.fasta > long_read.28S.ciliate.fasta
```

## Outgroup

My outgroup will include Dinoflagellates, Apicomplexa, Colpodellidea and Colponemids.

### EukRibo
I made a list with all EukRibo sequences for my outgroup called outgroup.EukRibo.list. Then I extracted the corresponding fasta sequences using the following commands:

```
grep -f outgroup.EukRibo.list 46346_EukRibo-02_full_seqs_2022-07-22.nospace.fas | tr -d ">" > outgroup.EukRibo.list1
```
```
seqkit grep -f outgroup.EukRibo.list1 46346_EukRibo-02_full_seqs_2022-07-22.nospace.fas > outgroup.EukRibo.fasta
```

#### Formatting

Replacing : with _ so that the file can be processed by RAxML: 

```
cat outgroup.EukRibo.fasta | tr ':' '_' > outgroup.EukRibo.formatted.fasta
```

### PacBio

I made a list with all PacBio sequences for my outgroup called outgroup.LongRead.list. Then I extracted the corresponding fasta sequences using the following commands:

```
grep -f outgroup.LongRead.list long_read.28S.otus.fasta | tr -d ">" > outgroup.LongRead28S.list
```
```
seqkit grep -f outgroup.LongRead28S.list long_read.28S.otus.fasta > outgroup.long_read.28S.fasta

```
grep -f outgroup.LongRead.list long_read.18S.otus.fasta | tr -d ">" > outgroup.LongRead18S.list
```
```
seqkit grep -f outgroup.LongRead18S.list long_read.18S.otus.fasta > outgroup.long_read.18S.fasta
```

## Concatination

We concatinated all 18S files and all 28S files using the following commands:

```
cat EukRibo_unique.formatted.fasta long_read.18S.ciliate.fasta outgroup.EukRibo.formatted.fasta outgroup.long_
read.18S.fasta > all.18S.fasta
```
```
cat long_read.28S.ciliate.fasta outgroup.28S.fasta > all.28S.fasta
```

We have the following statistics for these two files:

```
file           format  type  num_seqs    sum_len  min_len  avg_len  max_len
all.18S.fasta  FASTA   DNA      2,824  4,276,063      616  1,514.2   10,315
all.28S.fasta  FASTA   DNA      1,181  3,013,144    1,500  2,551.3    4,449
```

## Clustering sequences

To further reduce redundancy, the concatenated 18S sequences were clustered with vsearch. We chose a treshold of 100% to be conservative.

```
conda install -c bioconda vsearch
```
```
vsearch --cluster_fast all.18S.fasta --threads 4 --id 1 --uc 18S.cluster100.uc --centroids 18S.cluster100.fasta
```

This gave the following results:\
Clusters: 2671 Size min 1, max 5, avg 1.1\
Singletons: 2552, 90.4% of seqs, 95.5% of clusters\

