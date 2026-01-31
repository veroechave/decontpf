#!/bin/bash

# Help function
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: bash scripts/cleanup.sh [data] [res] [out] [log]"
    echo "If no arguments are provided, EVERYTHING will be deleted."
    exit 0
fi

# If no arguments, set target to all
if [ $# -eq 0 ]; then
    echo "No arguments provided: Full cleanup mode activated."
    TARGETS="data res out log"
else
    TARGETS="$@"
fi

for TARGET in $TARGETS
do
    case $TARGET in
        "data")
            echo "Deleting data/ folder..."
            rm -rf data/ ;;
        "res")
            echo "Deleting res/ folder..."
            rm -rf res/ ;;
        "out")
            echo "Deleting out/ folder..."
            rm -rf out/ ;;
        "log"|"logs")
            echo "Deleting log/ folder..."
            rm -rf log/
            rm -f Log.out ;;
        *)
            echo "Notice: Unknown target '$TARGET'. Skipping." ;;
    esac
done

echo "Workspace reset successfully."
