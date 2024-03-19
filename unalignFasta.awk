#!/usr/bin/awk -f

## "unalign" fasta formatted MSAs
## -----------------------------------------------------------
## Example usage:
## 1) $ cat file.fasta | unalignFasta.awk
## 2) $ unalignFasta.awk file.fasta

BEGIN{
	RS=">"
	FS="\n"
	OFS=""
}
{
	header=$1
	$1=""
	if(length($0) == 0){
		if(length(header) > 0){
			print ">"header"\n"$0
		}
		next
	}
	gsub(/-|\?/,"", $0)
	print ">"header"\n"$0
}
