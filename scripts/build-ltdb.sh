#!/bin/bash

### Script to parse the grammars with ltdb

set -e  # Exit immediately on any error

BUILD="${1:-build}"  # Default to 'build' if not prov

TMPDIR="etc/"

mkdir -p "${TMPDIR}"

LTDBDIR="${TMPDIR}/ltdb"

# Ensure required repositories are available
if [ ! -d "${LTDBDIR}" ]; then
    git clone --branch "flask" --single-branch  https://github.com/fcbond/ltdb.git "${LTDBDIR}"
fi

get_toml() {
  local file="$1"
  shift
  local key_expr="$*"

  python -c "
import toml, sys
data = toml.load(open('$file', 'r'))
try:
    value = data${key_expr}
    print(value)
except KeyError:
    print('')
"
}



## find METADATA
files=$(find "${BUILD}" -type f -name "METADATA")


for file in $files; do
    echo "Creating ltdb for: $file"
    config_rel=$(get_toml "$file" "['ACE_CONFIG_FILE']")
    if [[ -n "$config_rel" ]]; then
	## only make compatible trees
	python etc/ltdb/scripts/grm2db.py --checkgrm \
	--outdir build/DBS "${file}" || true
    else
	echo "⚠️ Skipping: missing ACE_CONFIG_FILE"
    fi
    echo
done

echo
echo "🚀 Successfully created the following grammars"
find build/DBS -type f -name '*.db' -size +0c -exec du -h {} + | sort -h

echo
echo "🏗️   Copying to etc/ltdb/web/db/"
find build/DBS -type f -name '*.db' -size +0c -exec cp {} etc/ltdb/web/db/ \;
