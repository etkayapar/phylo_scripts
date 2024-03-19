#!/usr/bin/awk -f

## Keep taxa with headers matching the ones in <taxafile> from a FASTA formatted file
## headers to remove should exactly match the headers in the FASTA file.
##
## ------------------------------------------------------------------------------------
## Usage:
## $ ./keep_taxa.awk -v taxafile=<taxafile> <INPUT_FASTA>

BEGIN{
	while(( getline line<taxafile) > 0 ) {
		taxa_to_rm[line] = ""
	}
	RS=">"
	FS="\n"
	OFS=""
}
$1 != ""{
	header=$1
	$1=""
	
	if( header in taxa_to_rm ){
		printf ">%s\n%s\n",header,$0
	}
}
