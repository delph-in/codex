#!/usr/bin/env bash

set -e  # Exit on error

# Paths
VENV_DIR=".venv"
BUILD="build"


# Step 1: Create .venv if missing
if [ ! -d "$VENV_DIR" ]; then
  echo "🔧 Creating virtual environment with uv..."
  if ! command -v uv &> /dev/null; then
    echo "❌ 'uv' is not installed. Please install it: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
  fi
  uv venv "$VENV_DIR" --python 3.13
fi

source .venv/bin/activate

# Step 2: Install dependencies
echo "📦 Installing requirements..."
uv pip install -r requirements.txt

# Step 3: Download grammars
echo "🚀 Download grammars"

# DPF commented out
python scripts/download_grammars.py codex.toml "${BUILD}"

echo "🩹 Overlay local files"

rsync -rv local/ build/

## Download the treebank for SRG
echo "🌲 Download Treebanks"
bash scripts/add-treebanks.sh

# make directory for external software
mkdir -p etc

# Step 4: Compile with ltdb
echo "🚀 Compile with ltdb"

bash scripts/build-ltdb.sh "${BUILD}"

echo
echo "🏗️   Copying to etc/ltdb/web/db/"
find "${BUILD}/DBS" -type f -name '*.db' -size +0c -exec cp {} etc/ltdb/web/db/ \;


# Step 5: Compile grammars with ace
echo "🚀 Compile with ace"

bash scripts/build-ace.sh "${BUILD}"

echo
echo "To see the ltdb:"
echo "cd etc/ltdb; bash deploy.sh"
echo
