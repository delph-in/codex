# codex
A collection of grammars, made as accessible as possible

## 🗂 Codex Table

See [codex-table.md](codex-table.md) for a list of all grammars and their settings.

## Setup

You must install `subversion` to get the grammars that use svn

$ bash compile.sh


## Individual commands

### Download grammars with:

$ python scripts/download_grammars.py codex.toml build

### Compile ltdb with

$ bash scripts/build-ace.sh build

### Compile grammars using ace

$ bash scripts/build-ace.sh build

### codex.toml

Grammars are listed in the file `codex.toml`

 * `vcs` is the way to download the grammar
 * `tree` is the treebank (if it is seperate, we only handle this for the SRG)

A project will be used to make as many grammars as it has METADATA files

#### size

Very rough distinctions so that people can have a general idea about how big the grammar is.  More detail can be gotten from the ltdb.

* large: lexicon above 30,000
* medium: lexicon above 5,000
* small: lexicon above 1,000 
* matrix: matrix derived grammar with minimal changes


### Make grew corpora

*Unfinished*

First install `grew`: https://grew.fr/usage/install/
and `grewpy`: https://grew.fr/usage/python/


