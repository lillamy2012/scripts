#!/bin/bash

pwd=$(pwd)
pre=$(basename $pwd)

## remove space
find . -type f -name "*.tab" -exec bash -c 'mv "$0" "${0// /_}"' {} \;


files=$(find . -name "*.tab")
for f in $files; do
    bf=$(basename $f)
    mv $bf ${pre}.${bf}
done
