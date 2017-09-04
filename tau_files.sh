#!/bin/bash


### to deal with space in file names
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")


### formating function to output numbers in right format.
function form_out {
    fl=$(echo $1 | grep "^[0-9]*\.[0-9]*$" | wc -l )
    if [ $fl -ne 0 ]; then # means float
        printf "%f:" "$1" >> $2.tmp
    else
        fl=$(echo $1 | grep "^[0-9]*\.[0-9]*" | wc -l )
        if [ $fl -ne 0 ]; then #mean exp
            printf "%E:" "$1" >> $2.tmp
        else
            printf "%d:" "$1" >> $2.tmp
        fi
    fi
}


###################################################
###################################################

folders=$(find . -type d -maxdepth 1 -mindepth 1)

for folder in $folders; do   #for folder in "T0"; do
    echo $folder
    ftmp=$folder/tmp
    mkdir -p $ftmp

#####################

    sub="CC"

    for file in "ome_Volume.csv" "ome_Intensity_Sum_Ch=1.csv"; do
        files=$(find $folder/$sub -name *$file)
        for i in $files; do
            name=$(basename $i)
            name_trim="${name%.ome*}"
            if [ "$file" = "ome_Volume.csv" ]; then
                printf "%s:" "$name_trim" > $ftmp/$name_trim.tmp
                nr=$(wc -l $i| awk '{print $1-4}')
                printf "%i:" "$nr" >> $ftmp/$name_trim.tmp
            fi
            sum1=$(cat $i | awk '{sum+=$1} END {print sum}')
            form_out $sum1 $ftmp/$name_trim
        done
    done

#####################

    sub="Nuc"

    for file in "ome_Volume.csv" "ome_Intensity_Sum_Ch=1.csv" "ome_Sphericity.csv" ; do
        files=$(find $folder/$sub -name *$file)
        for i in $files; do
            name=$(basename $i)
            name_trim="${name%.ome*}"
            a5=$(awk -F"," 'FNR == 5 {print $1}' $i)
            form_out $a5 $ftmp/$name_trim
        done
    done

#####################
### combine

    filename=$(basename $folder)
    tmps=$(find ./$ftmp -type f -name "*.tmp")
    printf "%s\t" "Nucleus+Name of the condition(ex T0)" "CC number" "Total CC volume" "Sum of CC intensity" "Nucleus volumne" "Nucleus SUM intensity" "Nucleus Sphericity" "RHV volume" "RHF intensity" > ${filename}.tab
    printf "\n" >> ${filename}.tab
    echo "${filename}" > errors_${filename}.tab
    printf "\n" >> errors_${filename}.tab
    for i in $tmps; do
        sed -i.bak 's/:$//' $i
        nrE=$(awk -F':' '{print NF}' $i )  #nrE=$(awk -F $'\t' 'BEGIN {OFS = "\t"}{print NF}' $i | sort -nu | tail -n 1)
        if [ "$nrE" -eq 7 ]; then
            awk -F':' 'BEGIN {OFS = "\t"}{$8=$3/$5}{$9=$4/$6}'1 $i >> ${filename}.tab
        else
            echo $i >> errors_${filename}.tab
            echo $nrE >> errors_${filename}.tab
            cat $i >> errors_${filename}.tab
            printf "\n" >> errors_${filename}.tab
        fi
    done
    rm -rf $ftmp
done

IFS=$SAVEIFS




