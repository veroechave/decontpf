## This script should index the genome file specified in the first argument ($1),
## creating the index in a directory specified by the second argument ($2).

## The STAR command is provided for you. You should replace the parts surrounded
## by "<>" and uncomment it.

## STAR --runThreadN 4 --runMode genomeGenerate --genomeDir <outdir> \
## --genomeFastaFiles <genomefile> --genomeSAindexNbases 9

#!/bin/bash

# Assigning arguments to descriptive variables
GENOME_FILE=$1
INDEX_OUTDIR=$2

echo "Creating index directory: $INDEX_OUTDIR"
mkdir -p "$INDEX_OUTDIR"

echo "Indexing $GENOME_FILE using STAR..."

# Run STAR genome generate mode
# --genomeSAindexNbases 9 is optimized for small genomes/contaminants
STAR --runThreadN 4 --runMode genomeGenerate --genomeDir "$INDEX_OUTDIR" \
--genomeFastaFiles "$GENOME_FILE" --genomeSAindexNbases 9
