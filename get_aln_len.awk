#!/usr/bin/awk -f

## Get the alignment length from a FASTA formatted MSA. This is a super dumb script with
## no sanity checks. Run it on files you are absolutely sure that are MSAs!
##
## -------------------------------------------------------------------------------------
## Usage:
##
## $ ./get_aln_len.awk <INPUT_MSA>

BEGIN{
	FS="\n"
	RS=">"
}
$1!=""{
	if (NR > 2){
		exit
	}
	print length($2)
}
