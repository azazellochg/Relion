#!/bin/bash
# This script will renumber ClassNumber field in star file
if [ $# -eq 0 ]; then
        echo "Usage: $0 [star file name]" && exit 1
fi
starFile="$1"
output="`basename ${starFile} | sed 's/.star//'`_renum.star"
classNumField=`awk 'NF<3{print}' ${starFile} | grep "_rlnClassNumber" | cut -d'#' -f2`

# get class numbers
rm -f .classes.tmp
key=1
for classNum in `awk -v class=$classNumField 'NF>3{print $class}' $starFile | sort -n | uniq`
do
        echo "$key $classNum" >> .classes.tmp
        ((key++))
done

# replace column $classNumField in starFile with new values in column 1 from file .classes.tmp
awk 'NF>3{print}' ${starFile} > ${starFile}.tmp
awk 'NF<3{print}' ${starFile} > ${output}
awk -v class=$classNumField 'NR==FNR{a[$2]=$1} NR>FNR{$class=a[$class];print}' .classes.tmp ${starFile}.tmp >> ${output}
echo "Ready! Output star file: ${output}"
rm -f .classes.tmp ${starFile}.tmp
