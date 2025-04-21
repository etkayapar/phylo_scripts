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
	usage = " Convert *_best_model.nex or *_best_scheme.nex output from IQ-TREE's ModelFinder to RAxML's partition format\n"
	usage = usage " WARNING: to be used with DNA models ONLY!!!\n"
	usage = usage " -------------------------------------------------------------------------------------\n"
	usage = usage " Usage:\n"
	usage = usage "\n"
	usage = usage " $ ./iqtree_to_raxml_models.awk <input_partitions.nex> > <output_partitions.part>\n"

	if(h){
		print usage
		exit
	}

	iq_to_rax["TN"] = "TrN"
	iq_to_rax["TNe"] = "TrNef"
	iq_to_rax["K81"] = "TPM1"
	iq_to_rax["K81u"] = "TPM1uf"
	iq_to_rax["TPM2u"] = "TPM2uf"
	iq_to_rax["TPM3u"] = "TPM3uf"

	iq_to_rax["TIM"] = "TIM1uf"
	iq_to_rax["TIMe"] = "TIM1"
	iq_to_rax["TIM2"] = "TIM2uf"
	iq_to_rax["TIM2e"] = "TIM2"
	iq_to_rax["TIM3"] = "TIM3uf"
	iq_to_rax["TIM3e"] = "TIM3"
	iq_to_rax["TVMe"] = "TVMef"
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
	split($1, model, "+")
	modellen = length(model)
	modelclass = model[1]
	if (modelclass in iq_to_rax){
		modelclass = iq_to_rax[modelclass]
	}
	modelstring = join(model, 1, modellen, "+")
	gsub(/\+I\+I/, "+I", modelstring) ## Remove double +I s due to IQ-TREE bug
	partName=$2
	printf "%s, %s=%s\n", modelstring, partName, partitions[partName]
}

function join(array, start, end, sep,    result, i)
{
## Taken from
## https://www.gnu.org/software/gawk/manual/html_node/Join-Function.html
	if (sep == "")
	sep = " "
	else if (sep == SUBSEP) # magic value
	sep = ""
	result = array[start]
	for (i = start + 1; i <= end; i++)
		result = result sep array[i]
	return result
}
