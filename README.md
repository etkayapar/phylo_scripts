# phylo_scripts

This is an unsorted collection of small(mostly) and handy scripts I use for my daily work. 

- [phylip2fasta.sh](./phylip2fasta.sh) and [nexus2fasta.sh](./nexus2fasta.sh): For quickly converting a PHYLIP or nexus formatted supermatrix to a simple FASTA file. PHYLIP file does not have any taxon id restrictions other than there needs to be at least one space after each taxon id.
- [concat-aln](./concat-aln): concatenate a set of fasta formatted alignments to a relaxed PHYLIP formatted supermatrix using [Biopython](https://github.com/biopython/biopython). Also writes a nexus file with partition information.
- [translate\_stdin.py](./translate_stdin.py): Translate fasta formatted alignments (or codon sequences) passed in to standard input using [Biopython](https://github.com/biopython/biopython).
- [clearEmptyFasta.awk](./clearEmptyFasta.awk): Clear fasta entries with empty sequences.
- [unwrapFasta.awk](./unwrapFasta.awk): Unwrap a fasta formatted file so that the sequence for each entry can only span a single line.
- [ncbi\_download.sh](./ncbi_download.sh): Find the latest versions of the list of genome accessions and download all genomes using [ncbi command-line tools](https://github.com/ncbi/datasets)
