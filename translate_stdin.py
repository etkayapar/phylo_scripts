#!/usr/bin/env python3

"""
Quick and dirty DNA/RNA -> AA translation of what is passed in as stdin to stdout.
Always translates in frame 1, forward strand.
Roughly equivalent to running transeq from the EMBOSS suite as::
    cat alignment.fa | transeq -filter -frame 1
"""

from sys import stdin
from Bio.Seq import Seq


for l in stdin:
    l = l.strip()
    if l.startswith(">"):
        print(l)
        continue
    s = Seq(l)
    p = str(s.translate())
    print(p)
