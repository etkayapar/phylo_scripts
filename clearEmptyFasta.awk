#!/usr/bin/env awk -f

## Remove entries with empty sequences from a fasta formatted file.
## Expects the file to be in the "fasta-2line" format: sequences
## cannot span multiple lines. If this is not the case, pass your
## file through unwrapFasta.awk before.

BEGIN {
	RS=">"
	FS="\n"
}
{
	if ($2 != "")
		print ">"$1"\n"$2
}
