#!/usr/bin/env bash

set -e  # Exit on error

# Paths
VENV_DIR=".venv"

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

# Step 3: Run the script
echo "🚀 Download grammars"

python scripts/download_grammars.py codex.toml build

# Step 3: Run the script
echo "🚀 Compile ltdb"

bash scripts/build-ltdb.sh
