#!/usr/bin/env bash

### Quick and dirty conversion of nexus formatted alignments to plain fasta. Works with gnu sed and grep
### haven't tested it with BSD versions

inseq=$1

ntaxa=`grep -oE "ntax=[0-9]+" "$inseq" | cut -d= -f2`
grep -A $ntaxa "matrix" $inseq | tail -n +2 | sed -e 's/^/>/;s/ \{1,\}/\n/'
