#!/usr/bin/awk -f

## Print entries with empty sequences from a fasta formatted file.
## Can handle both wrapped and unwrapped fasta files.

BEGIN {
	RS=">"
	FS="\n"
	OFS=""
}
$1!=""{
	if ($2 == ""){
		header=$1
		$1=""
		print header
	}
}
