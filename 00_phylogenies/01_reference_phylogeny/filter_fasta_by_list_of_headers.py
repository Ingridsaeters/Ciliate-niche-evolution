#!/usr/bin/env python3

from Bio import SeqIO
import sys

# This script removes sequences from fasta file based on headers provided in a pattern file. 
# ./filter_fasta_by_list_of_headers.py <fasta.file> <list.file> > <output.file>

ffile = SeqIO.parse(sys.argv[1], "fasta")
header_set = set(line.strip() for line in open(sys.argv[2]))

for seq_record in ffile:
    try:
        header_set.remove(seq_record.name)
    except KeyError:
        print(seq_record.format("fasta"))
        continue
if len(header_set) != 0:
    print(len(header_set),'of the headers from list were not identified in the input fasta file.', file=sys.stderr)
