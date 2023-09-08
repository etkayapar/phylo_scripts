#!/bin/bash

### Quick and dirty conversion of PHYLIP (sequential and at least one space after taxon id) alignments to plain fasta.
### Looks super ugly so that works with both GNU and BSD sed and grep :))

inseq=$1

tail -n +2 $inseq | sed -e 's/^/>/;s/ \{1,\}/\n/'
