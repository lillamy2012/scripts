#!/bin/bash


### to deal with space in file names
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")


### formating function to output numbers in right format.
function form_out {
## only number, . and e+ allowed
    case $1 in
        ''|*[!0-9.e+]*) err=1 ;;
            *) err=0 ;;
    esac
    if [ $err -eq 0 ];then
        fl=$(echo $1 | grep "^[0-9]*\.[0-9]*$" | wc -l )
        if [ $fl -ne 0 ]; then # means float as end of line $
            printf "%f:" "$1" >> $2.tmp
        else
            fl=$(echo $1 | grep "^[0-9]*\.[0-9]*" | wc -l )
            if [ $fl -ne 0 ]; then #mean exp
                printf "%E:" "$1" >> $2.tmp
            else
                printf "%d:" "$1" >> $2.tmp
            fi
        fi
    else
        echo $1 not a number, not written to $2.tmp
    fi

}


###################################################
###################################################

folders=$(find . -type d -maxdepth 1 -mindepth 1)

for folder in $folders; do
#for folder in "20170823_2d_rec_HS"; do
echo $folder
    ftmp=$folder/tmp
    mkdir -p $ftmp

#####################

    sub="CC"

    for file in "_Volume.csv" "_Intensity_Sum_Ch=1.csv"; do
        files=$(find $folder/$sub -name *$file)
        for i in $files; do
            name=$(basename $i)
            name_trim="${name%.ome*}"
            name_trim2="${name_trim%_Volume*}"
            name_trim3="${name_trim2%_Intensity*}"
#echo $name_trim3
            if [ "$file" = "_Volume.csv" ]; then
                printf "%s:" "$name_trim3" > $ftmp/$name_trim3.tmp
                nr=$(wc -l $i| awk '{print $1-4}')
                printf "%i:" "$nr" >> $ftmp/$name_trim3.tmp
            fi
            sum1=$(cat $i | awk '{sum+=$1} END {print sum}')
            case $sum1 in
                ''|*[!0-9.e+]*) echo sum in $i not a number, not written to $ftmp/$name_trim3 ;;
                    *) form_out $sum1 $ftmp/$name_trim3 ;;
            esac

        done
    done

#####################

    sub="Nuc"

    for file in "_Volume.csv" "_Intensity_Sum_Ch=1.csv" "_Sphericity.csv" ; do
        files=$(find $folder/$sub -name *$file)
        for i in $files; do
            name=$(basename $i)
            name_trim="${name%.ome*}"
            name_trim2="${name_trim%_Volume*}"
            name_trim3="${name_trim2%_Intensity_Sum_Ch=1.csv*}"
            name_trim4="${name_trim3%_Sphericity.csv*}"
            a5=$(awk -F"," 'FNR == 5 {print $1}' $i)
            case $a5 in
                ''|*[!0-9.e+]*) echo a5 in $i not a number, not written to $ftmp/$name_trim4 ;;
                *) form_out $a5 $ftmp/$name_trim4;;
            esac

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
#echo $nrE
        if [ "$nrE" -eq 7 ]; then
            awk -F':' 'BEGIN {OFS = "\t"}{$8=$3/$5}{$9=$4/$6}'1 $i >> ${filename}.tab
        else
            echo $i >> errors_${filename}.tab
            echo $nrE >> errors_${filename}.tab
            awk -F':' 'BEGIN {OFS = "\t"}{$1=$1}'1 $i >> errors_${filename}.tab
        fi
    done
    rm -rf $ftmp
done

IFS=$SAVEIFS




