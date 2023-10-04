#!/usr/bin/env Rscript --vanilla

library(dplyr)

## Specify path
path <- getwd() 

## read in file
df <- read.table("eukbank_18SV4_asv.subset.table", header = TRUE, sep = "\t")

## subset file so that columns with all 0s are removed
df_subset <- df[, colSums(df != 0, na.rm = TRUE) > 0]

print(ncol(df_subset))
print(nrow(df_subset))

## export the dataframe
write.table(df_subset, "eukbank_18SV4_asv.subset.nozeros.table", sep = "\t", row.names = FALSE)
