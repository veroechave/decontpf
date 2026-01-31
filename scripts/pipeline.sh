#!/bin/bash

# 1 SETUP AND DATA DOWNLOAD
echo "Starting sequencing data download..."

# Download samples using the provided URLs file
# -N: Only download if the file is newer or missing (Idempotency)
wget -N -i data/urls -P data/

echo "Preparing contaminants database..."
# Official URL provided in the assignment instructions
CONTAMINANTS_URL="https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz"

# Execute the download script (handles filtering and decompression)
# We store results in the 'res' directory
bash scripts/download.sh "$CONTAMINANTS_URL" res yes "small nuclear"

echo "Generating index for STAR aligner..."
# Index the filtered contaminants using the dedicated script
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx


# 2 AUTOMATIC SAMPLE IDENTIFICATION
# Dynamically detect samples in the data folder instead of hardcoding names.
# It extracts the ID before the first dash (-) from .fastq.gz files.
SAMPLE_LIST=$(ls data/*.fastq.gz | xargs -n 1 basename | cut -d "-" -f 1 | sort -u)

echo "Samples detected for processing: $SAMPLE_LIST"


# 3 PROCESSING: MERGING AND ADAPTER TRIMMING
for SAMPLE_ID in $SAMPLE_LIST
do
    echo ">>> Processing sample: $SAMPLE_ID"

    # STEP A: Merge technical replicates
    MERGED_FILE="out/merged/${SAMPLE_ID}.fastq.gz"
    
    if [ -f "$MERGED_FILE" ]; then
        echo "Notice: Merged file for $SAMPLE_ID already exists. Skipping..."
    else
        bash scripts/merge_fastqs.sh data out/merged "$SAMPLE_ID"
    fi

    # STEP B: Adapter removal (Cutadapt)
    mkdir -p out/trimmed log/cutadapt
    TRIMMED_FILE="out/trimmed/${SAMPLE_ID}.trimmed.fastq.gz"
    
    if [ -f "$TRIMMED_FILE" ]; then
        echo "Notice: $SAMPLE_ID already has adapters removed. Skipping..."
    else
        echo "Running Cutadapt for $SAMPLE_ID..."
        # -m 18: Discards reads shorter than 18nt after trimming
        cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
            -o "$TRIMMED_FILE" "$MERGED_FILE" > log/cutadapt/${SAMPLE_ID}.log
    fi

    # STEP C: Alignment and Decontamination (STAR)
    STAR_OUTPUT_DIR="out/star/${SAMPLE_ID}"
    mkdir -p "$STAR_OUTPUT_DIR"

    # We are looking for UNMAPPED reads (the decontaminated data)
    CLEAN_READS="${STAR_OUTPUT_DIR}/Unmapped.out.mate1"

    if [ -f "$CLEAN_READS" ]; then
        echo "Notice: STAR analysis for $SAMPLE_ID is already complete. Skipping..."
    else
        echo "Aligning $SAMPLE_ID against contaminants list..."
        STAR --runThreadN 4 --genomeDir res/contaminants_idx \
             --outReadsUnmapped Fastx \
             --readFilesIn "$TRIMMED_FILE" \
             --readFilesCommand gunzip -c \
             --outFileNamePrefix "${STAR_OUTPUT_DIR}/"
    fi
done


# 4 FINAL REPORT GENERATION
REPORT_LOG="log/pipeline_summary.log"
echo "FINAL PIPELINE REPORT" > "$REPORT_LOG"
echo "Date: $(date)" >> "$REPORT_LOG"

for SAMPLE_ID in $SAMPLE_LIST
do
    echo -e "\n--- STATISTICS: $SAMPLE_ID ---" >> "$REPORT_LOG"
    grep "Reads with adapters" "log/cutadapt/${SAMPLE_ID}.log" >> "$REPORT_LOG"
    grep "Uniquely mapped reads %" "out/star/${SAMPLE_ID}/Log.final.out" >> "$REPORT_LOG"
done

echo "Pipeline finished successfully. Check the summary at $REPORT_LOG"
