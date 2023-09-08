#! /usr/bin/env bash

### Use ncbi datasets cli tool to download a list of genomes. requires the executable 'datasets' to be in the PATH
### or the path to the 'datasets' executable needs to be passed as the -d option like -d /path/to/datasets

### This script works for datasets version 13.31.0 and probably not with newer versions as they have changed the args syntax

### arg parsing -----------------------------
while getopts ":a:d:" opt; do
  case $opt in
    a) acclist="$OPTARG"
    ;;
    d) datasets="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

[[ -z ${datasets+x} ]] && export datasets=$(which datasets)
[[ $datasets == "" ]]  && { echo "datasets not found" && exit 1; }
############################################

echo $acclist
echo $datasets
get_latest_acc() {
	fn=$1
	cat $fn | xargs -I{} -n1 -P 8  sh -c "$datasets summary genome accession --assmaccs {} 2>/dev/null | jq '.assemblies | .[] | .assembly.assembly_accession' | tail -n 1 | tr -d '\"' "

}

get_latest_acc $acclist > latest_accs.txt
acc_list=$(cat latest_accs.txt | tr '\n' ',' | sed 's/,$//')
rm latest_accs.txt

download() {
	acc_arg=$1
	$datasets download genome accession $acc_arg 
}

download $acc_list

