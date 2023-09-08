#!/usr/bin/env bash

### Quick and dirty conversion of nexus formatted alignments to plain fasta.
### Looks super ugly so that works with both GNU and BSD sed and grep :))

inseq=$1

ntaxa=`grep -oE "ntax=[0-9]+" "$inseq" | cut -d= -f2`
grep -A $ntaxa "matrix" $inseq | tail -n +2 | sed -e 's/^/>/;s/ \{1,\}/\n/'
