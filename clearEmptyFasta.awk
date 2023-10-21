#!/usr/bin/awk -f

## Remove entries with empty sequences from a fasta formatted file.
## Can handle both wrapped and unwrapped fasta files.

BEGIN {
	RS=">"
	FS="\n"
	OFS=""
}
{
	if ($2 != ""){
		header=$1
		$1=""
		print ">"header"\n"$0
	}
}
