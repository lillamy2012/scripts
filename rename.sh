#!/bin/bash

pwd=$(pwd)
pre=$(basename $pwd)

files=$(find . -name "*.tab")
for f in $files; do
    bf=$(basename $f)
    mv $bf ${pre}.${bf}
done