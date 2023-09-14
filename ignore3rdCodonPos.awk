#!/usr/bin/env awk -f

## Ignore the third codon position from all partitions.
##
## Operates only on the input NEXUS style partition file and writes a new partition file
## to stdout. Does not change the dataset in any way. By explicitly stating that we want
## 1st and the 2nd positions from each partition we effectively ignore the 3rd codon
## position.
## -------------------------------------------------------------------------------------
## Usage:
##
## $ ./exclude3rdCodonPos.awk <input_partitions.nex> > <output_partitions.nex>

BEGIN {
	FS="=|-|;"
	OFS=" "
}
$2 != "" {
	print $1,"=",$2"-"$3"\\3",$2+1"-"$3"\\3"";"

}
$2 == "" {
	print $0
}
