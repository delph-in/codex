#!/bin/bash

### Script to parse the grammars with ace

BUILD="${1:-build}"  # Default to 'build' if not prov

### get ace
case "$(uname -s)" in
    Linux)
        echo "Running on Linux"
        ACE="ace-0.9.31"
	# acetools-x86-0.9.31.tar.gz
	pushd etc 
	wget -c -N "https://sweaglesw.org/linguistics/ace/download/${ACE}-x86-64.tar.gz"
	tar xfz ${ACE}-x86-64.tar.gz
	popd
        ;;
    Darwin)
        echo "Running on macOS"
	ACE="ace-0.9.34"
	mkdir -p etc/"${ACE}"
	pushd etc/"${ACE}"
	wget -c -N "https://sweaglesw.org/linguistics/ace-0.9.34-m1-test"
	chmod +x ace-0.9.34-m1-test
	ln -s ace-0.9.34-m1-test ace
	popd
        ;;
    *)
        echo "Error: This OS is not supported"
        echo "Supported OS: Linux and macOS (Darwin)"
        exit 1
        ;;
esac


## find METADATA
files=$(find "${BUILD}" -type f -name "METADATA")

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

mkdir -p $BUILD/GRAMMARS/

echo $files

ACE_BIN="etc/${ACE}/ace"

for file in $files; do
    echo "Processing: $file"
    config_rel=$(get_toml "$file" "['ACE_CONFIG_FILE']")
    nam=$(get_toml "$file" "['SHORT_GRAMMAR_NAME']")
    
    if [[ -n "$config_rel" && -n "$nam" ]]; then
        dir=$(dirname "$file")
        config="$dir/$config_rel"
        outfile="$BUILD/GRAMMARS/${nam}.dat"
        logfile="$BUILD/GRAMMARS/${nam}-ace.log"
    
        echo "Compiling into $outfile, log at $logfile with ${ACE_BIN}"

	echo "# COMPILING WITH:  etc/${ACE}/ace -g $config -G $outfile"  > "$logfile"
	
        "${ACE_BIN}" -g "$config" -G "$outfile" 2>&1 | sed -r 's/\x1B\[[0-9;]*m//g' >> "$logfile"

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

echo "🚀 Successfully created the following grammars"
find build/GRAMMARS -type f -name '*.dat' -size +0c -exec du -h {} + | sort -h

