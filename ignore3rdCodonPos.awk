#!/usr/bin/awk -f

## Ignore the third codon position from all partitions.
##
## Operates only on the input NEXUS style partition file and writes a new partition file
## to stdout. Does not change the dataset in any way. By explicitly stating that we want
## 1st and the 2nd positions from each partition we effectively ignore the 3rd codon
## position. This will also work with a larger NEXUS file with both the data matrix and the
## partition information, but the extremely long lines of the data matrix will cause a
## major slowdown.
## -------------------------------------------------------------------------------------
## Usage:
##
## $ ./ignore3rdCodonPos.awk <input_partitions.nex> > <output_partitions.nex>

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
	print $1,"=",$2"-"$3"\\3",$2+1"-"$3"\\3"";"

}
