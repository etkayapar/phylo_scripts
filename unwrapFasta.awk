#!/usr/bin/env awk -f

## Unwraps fasta sequences
## Directly taken from [1] all credits goes to the authors.
## --------------------------------------------------------
## [1] Haubold, B., & Börsch-Haubold, A. (2023). Chapter 3: Exact Matching. In Bioinformatics for evolutionary biologists: A problems approach (2nd ed.). essay, Springer. 


!/^>/ {
	t = t $0
}
/^>/ {
	if (NR > 1) {
		print t
		t = ""
	}
	print
}
END {
	print t
}
