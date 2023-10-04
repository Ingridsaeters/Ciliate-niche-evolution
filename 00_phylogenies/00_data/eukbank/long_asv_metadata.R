#!/usr/bin/env Rscript --vanilla

library(tidyverse)

asv_wide <- read.table("eukbank_18SV4_asv.subset.nozeros.table",
                       header = TRUE,
                       sep = "\t")

print(nrow(asv_wide))

asv_long <- gather(asv_wide, sample, abundance, X1:VA133_RNA, factor_key=TRUE) %>% filter(abundance>0) 

print(nrow(asv_long))

metadata <- read.table("eukbank_18SV4_asv.subset.metadata",
                       header=TRUE,
                       sep= "\t")

print(nrow(metadata))

asv_long_metadata <- merge(asv_long, metadata, by = "sample", all.x = FALSE)

write.table(asv_long_metadata, "asv_long_metadata", sep = "\t", row.names = FALSE)

print(nrow(asv_long_metadata))
