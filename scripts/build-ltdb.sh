#!/bin/bash

### Script to convert the Arasaac WordNet to WN-LMF

set -e  # Exit immediately on any error

TMPDIR="etc/"

mkdir -p "${TMPDIR}"

LTDBDIR="${TMPDIR}/ltdb"

# Ensure required repositories are available
if [ ! -d "${LTDBDIR}" ]; then
    git clone --branch "tdl-from-grammar" --single-branch  https://github.com/fcbond/ltdb.git "${LTDBDIR}"
fi

## find METADATA
files=$(find build local -type f -name "METADATA")


for file in $files; do
  echo "Creating ltdb for: $file"
  python etc/ltdb/scripts/grm2db.py \
   --outdir build/dbs "${file}" || true
done


# # Build Directories
# mkdir -p "${BLDDIR}"
# mkdir -p "${PREDIR}/log"

# URL='https://github.com/omwn/${WNBASE}/'

# #Check for xsltproc Command

# if ! command -v xsltproc &> /dev/null; then
#     echo "Error: xsltproc is not installed. Please install it first."
#     exit 1
# fi

# # Read languages from file safely
# while IFS='|' read -r local_code bp47 en_name native_name; do
#     # Skip empty lines
#     if [[ -z "$local_code" ]]; then
#         continue
#     fi
#     echo "Processing language: ${en_name} ($local_code ${native_name})"
    
#     INPUT_FILE="${PREDIR}/tab/${local_code}-${WNBASE}.tab"
    
#     # Check if file exists and has at least 10 lines
#     if [ ! -f "$INPUT_FILE" ] || [ $(wc -l < "$INPUT_FILE") -lt 10 ]; then
#         echo "Skipping ${en_name} ($local_code): File '$INPUT_FILE' has fewer than 10 lines."
#         continue
#     fi

#     mkdir -p "${BLDDIR}/${WNBASE}-${local_code}"
    
#     python "${OMWDATADIR}/scripts/tsv2lmf.py" \
#         --id "${WNBASE}-${local_code}" \
#         --version "${VERSION}" \
#         --label "Arasaac Wordnet for ${en_name} (${native_name})" \
#         --language "${bp47}" \
#         --email bond@ieee.org \
#         --license 'https://creativecommons.org/licenses/by/4.0/' \
#         --meta confidenceScore=1.0 \
#         --url "${URL}" \
#         --ili-map "${CILIDIR}/ili-map-pwn30.tab" \
#         --log "${PREDIR}/log/${WNBASE}-${local_code}.log" \
#         "${INPUT_FILE}" \
#         "${BLDDIR}/${WNBASE}-${local_code}/${WNBASE}-${local_code}-tmp.xml"

#     # Fix license and description
#     xsltproc scripts/update_license_description.xsl "${BLDDIR}/${WNBASE}-${local_code}/${WNBASE}-${local_code}-tmp.xml" \
#         > "${BLDDIR}/${WNBASE}-${local_code}/${WNBASE}-${local_code}.xml"
#     rm "${BLDDIR}/${WNBASE}-${local_code}/${WNBASE}-${local_code}-tmp.xml"

# done < "$LANGFILE"
