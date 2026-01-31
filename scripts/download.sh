#!/bin/bash

# Arguments mapping for better readability
URL=$1
DEST_DIR=$2
UNCOMPRESS=$3
FILTER_PATTERN=$4

# 1 Download the file
# -nc: prevents re-downloading if the file already exists
wget -P "$DEST_DIR" -nc "$URL"

FILENAME=$(basename "$URL")
FILEPATH="${DEST_DIR}/${FILENAME}"

# 2 Decompress if the third argument is "yes"
if [ "$UNCOMPRESS" == "yes" ]; then
    echo "Decompressing $FILEPATH..."
    gunzip -f "$FILEPATH"
    # Update filepath as the .gz extension is removed
    FILEPATH="${FILEPATH%.gz}"
fi

# 3 Filter sequences if a pattern is provided
if [ -n "$FILTER_PATTERN" ]; then
    echo "Filtering sequences containing '$FILTER_PATTERN' in $FILEPATH..."
    # -v: exclude, -n: check by name, -p: pattern
    seqkit grep -v -n -p "$FILTER_PATTERN" "$FILEPATH" > "${FILEPATH}.tmp"
    mv "${FILEPATH}.tmp" "$FILEPATH"
fi

# 4 MD5 Integrity Check (Bonus)
MD5_URL="${URL}.md5"
echo "Verifying MD5 integrity for $FILENAME..."

# Calculate local hash
LOCAL_MD5=$(md5sum "$FILEPATH" | awk '{print $1}')
# Get remote hash without downloading the file
REMOTE_MD5=$(curl -s "$MD5_URL" | awk '{print $1}')

if [ -z "$REMOTE_MD5" ]; then
    echo "Warning: Remote .md5 file not found. Skipping integrity check."
else
    if [ "$LOCAL_MD5" == "$REMOTE_MD5" ]; then
        echo "MD5 Check: PASSED ($LOCAL_MD5)"
    else
        echo "CRITICAL ERROR: File corruption detected."
        exit 1
    fi
fi
