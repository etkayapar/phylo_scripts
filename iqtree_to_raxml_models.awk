#!/usr/bin/awk -f

## Convert *_best_model.nex output from IQ-TREE's ModelFinder to RAxML's partition format
##
## -------------------------------------------------------------------------------------
## Usage:
##
## $ ./iqtree_to_raxml_models.awk <input_partitions.nex> > <output_partitions.part>

BEGIN {
	FS="=|;"
	OFS=" "
}
/^[ \t]*charset/{
	for(i=1;i<=NF;i++){
		gsub(/[ \t\r\n]+$/, "", $i)
		gsub(/^[ \t\r\n]+/, "", $i)
	}
	gsub(/[ ]+/,",", $2)
	split($1, firstColArr, " ")
	partName=firstColArr[2]
	partitions[partName] = $2

}
$0 ~ /charpartition/, $0 ~ /^end/ {
	FS=":|;|,"

	if ($0 ~ /charpartition/ || $0 ~ /^end/){
		next
	}

	for(i=1;i<=NF;i++){
		gsub(/[ \t\r\n]+$/, "", $i)
		gsub(/^[ \t\r\n]+/, "", $i)
	}
	model=$1
	gsub(/\+I\+I/, "+I", model) ## Remove double +I s due to IQ-TREE bug
	partName=$2
	printf "%s, %s=%s\n", model, partName, partitions[partName]
}
