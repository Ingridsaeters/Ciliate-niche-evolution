#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;
use Data::Dumper;

# concat_fasta.pl
# Iker Irisarri. Jul 2016.
# This script will concatenate the files in the order given in the command line
# requirements: all taxa in individual fasta files should have matching headers

my $usage = "concat_fasta.pl infile1.fa infile2. etc. > outfile.fa";
my @infiles = @ARGV or die $usage; 

# declare hashes
my %new;
my %concat;
my $total_concat_length = 0;

# loop through the list of infiles
foreach my $infile (@infiles) {

	my $new_seq_length = 0;
	%new = ();
	
	# read file in with seqio
	my $seqio_obj = Bio::SeqIO->new(
		'-file' => "<$infile", 
		'-format' => "fasta", 
		);

	# store sequences of new file into hash %new
	while (my $inseq = $seqio_obj->next_seq) {

		$new{$inseq->primary_id}=$inseq->seq;
		$new_seq_length = $inseq->length;
	}


	# add sequences to %concat
	foreach my $k ( keys %new ) {

		# if not present in %concat
		if ( !exists $concat{$k} ) {
		
			# prior to concatenation, fill previous positions with "Ns" for $total_concat_length
			# for gene #1 this $total_concat_length == 0
			my $seq1 = 'N' x $total_concat_length . $new{$k};

			$concat{$k} = $seq1;
		}
		else {
	
			# concatenate
			my $seq2 = $concat{$k} . $new{$k};
			# reassign
			$concat{$k} = $seq2;
		}
	}
	# fill with Ns any taxa present in %concat but not in %new
	foreach my $j ( keys %concat ) {
	
		if ( !exists $new{$j} ) {
		
			my $seq3 = $concat{$j} . 'N' x $new_seq_length;
			$concat{$j} = $seq3;
		}
	}
	# add new gene length to total
	$total_concat_length += $new_seq_length;
}

# print out concatenated sequence
foreach my $taxa ( sort keys %concat ) {

	print ">$taxa\n";
	print $concat{$taxa}, "\n";
}

print STDERR "\ndone!\n\n";
