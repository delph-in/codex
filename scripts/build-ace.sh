#!/bin/bash

### Script to parse the grammars with ace

BUILD="${1:-build}"  # Default to 'build' if not prov

### get ace
ACE="ace-0.9.31"
# acetools-x86-0.9.31.tar.gz
pushd etc 
wget -c -N "https://sweaglesw.org/linguistics/ace/download/${ACE}-x86-64.tar.gz"
tar xfz ${ACE}-x86-64.tar.gz
popd

## find METADATA
files=$(find "${BUILD}" local -type f -name "METADATA")

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

mkdir -p $BUILD/grammars/

echo $files

for file in $files; do
    echo "Processing: $file"
    config_rel=$(get_toml "$file" "['ACE_CONFIG_FILE']")
    nam=$(get_toml "$file" "['SHORT_GRAMMAR_NAME']")
    
    if [[ -n "$config_rel" && -n "$nam" ]]; then
        dir=$(dirname "$file")
        config="$dir/$config_rel"
        outfile="$BUILD/grammars/${nam}.dat"
        logfile="$BUILD/grammars/${nam}-ace.log"
    
        echo "Compiling into $outfile, log at $logfile with etc/${ACE}/ace"

	echo "# COMPILING WITH:  ace -g $config -G $outfile"  > "$logfile"
	
        etc/"${ACE}/ace" -g "$config" -G "$outfile" 2>&1 | sed -r 's/\x1B\[[0-9;]*m//g' > "$logfile"

        ace_status=${PIPESTATUS[0]}
    
        if [[ $ace_status -eq 0 ]]; then
            echo "✅ ACE succeeded for $nam"
        else
            echo "❌ ACE failed for $nam (exit code $ace_status)"
        fi
    else
        echo "⚠️ Skipping: missing ACE_CONFIG_FILE or SHORT_GRAMMAR_NAME"
    fi
    echo
done

