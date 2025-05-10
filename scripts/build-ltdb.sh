#!/bin/bash

### Script to parse the grammars with ltdb

set -e  # Exit immediately on any error

BUILD="${1:-build}"  # Default to 'build' if not prov

TMPDIR="etc/"

mkdir -p "${TMPDIR}"

LTDBDIR="${TMPDIR}/ltdb"

# Ensure required repositories are available
if [ ! -d "${LTDBDIR}" ]; then
    git clone --branch "tdl-from-grammar" --single-branch  https://github.com/fcbond/ltdb.git "${LTDBDIR}"
fi

## find METADATA
files=$(find "${BUILD}" local -type f -name "METADATA")


for file in $files; do
    echo "Creating ltdb for: $file"
    ## only make compatible trees
    python etc/ltdb/scripts/grm2db.py --checkgrm \
	   --outdir build/dbs "${file}" || true
    echo
done

echo
echo "🚀 Successfully created the following grammars"
find build/dbs -type f -name '*.db' -size +0c -exec du -h {} + | sort -h
