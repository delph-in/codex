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
  python etc/ltdb/scripts/grm2db.py \
   --outdir build/dbs "${file}" || true
done

