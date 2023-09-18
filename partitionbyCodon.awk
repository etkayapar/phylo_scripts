#!/usr/bin/awk -f

## Treat all codon positions as separate partitions (part by gene -> part by geneXcodon)
##
## Operates only on the input NEXUS style partition file and writes a new partition file
## to stdout. Does not change the dataset in any way.This will also work with a larger
## NEXUS file with both the data matrix and the partition information, but the extremely
## long lines of the data matrix will cause a major slowdown.
## -------------------------------------------------------------------------------------
## Usage:
##
## $ ./partitionbyCodon.awk <input_partitions.nex> > <output_partitions.nex>

BEGIN {
	FS="=|-|;"
	OFS=" "
}
!/^[ \t]*charset/{
	print
}
/^[ \t]*charset/{
	for(i=1;i<=NF;i++){
		gsub(/[ \t\r\n]+$/, "", $i)
		gsub(/^[ \t\r\n]+/, "", $i)
	}
	print $1"_pos1","=",$2"-"$3"\\3;"
	print $1"_pos2","=",$2+1"-"$3"\\3;"
	print $1"_pos3","=",$2+2"-"$3"\\3;"

}
