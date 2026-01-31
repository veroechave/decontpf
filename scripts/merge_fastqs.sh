## This script should merge all files from a given sample (the sample id is
## provided in the third argument ($3)) into a single file, which should be
## stored in the output directory specified by the second argument ($2).
## The directory containing the samples is indicated by the first argument ($1).

#!/bin/bash

# Assigning arguments for clarity
INPUT_DIR=$1
OUTPUT_DIR=$2
SAMPLE_ID=$3

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Merging technical replicates for sample: $SAMPLE_ID..."

# Concatenate all files starting with the Sample ID into one
cat "${INPUT_DIR}/${SAMPLE_ID}"*.fastq.gz > "${OUTPUT_DIR}/${SAMPLE_ID}.fastq.gz"
