#!/usr/bin/env bash

set -e  # Exit on error

# Paths
VENV_DIR=".venv"
BUILD="build"


# Step 1: Create .venv if missing
if [ ! -d "$VENV_DIR" ]; then
  echo "🔧 Creating virtual environment with uv..."
  if ! command -v uv &> /dev/null; then
    echo "❌ 'uv' is not installed. Please install it: pip install uv"
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



# make directory for 
mkdir -p etc

# Step 3: Compile with ltdb
echo "🚀 Compile with ltdb"

bash scripts/build-ltdb.sh "${BUILD}"

echo
echo "🏗️   Copying to etc/ltdb/web/db/"
find "${BUILD}/DBS" -type f -name '*.db' -size +0c -exec cp {} etc/ltdb/web/db/ \;


# Step 4: Compile grammars with ace
echo "🚀 Compile wtih ace"

bash scripts/build-ace.sh "${BUILD}"

