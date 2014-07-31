#!/bin/bash

###This script removes all particles with grey values above/below two thresholds.
###Input should be IMAGIC file with particles, also corresponding star file is needed.

inputimg="total"
inputstar="particles.star"
output="particles_good.star"

th1="80"
th2="900"

IMAGIC_ROOT="/home/imagic/imagic_110308_64"

echo -ne "Extracting max and min pixel density values from [${inputimg}.img]..."
${IMAGIC_ROOT}/stand/headers.e <<EOF > /dev/null 2>&1
PLT_OUT
INDEX
NUMBER_OF_INDEX
22;23
YES
${inputimg}
${inputimg}.plt
EOF
[ $? -eq 0 ] && echo "OK!" || ( echo "ERROR!" && exit 1 )

awk -v th1=$th1 -v th2=$th2 '{ if ($2 > th2 || $3 < th1) {print $1}}' ${inputimg}.plt | cut -d'.' -f1 | uniq -u | sort -n > bad_ptcls.plt

echo -ne "Extracting bad particles to separate file [bad_particles.img]..."
${IMAGIC_ROOT}/incore/excopy.e <<EOF > /dev/null 2>&1
2D_IMAGES/SECTIONS
EXTRACT
${inputimg}
bad_particles
PLT_FILE
bad_ptcls.plt
EOF
[ $? -eq 0 ] && echo "OK!" || ( echo "ERROR!" && exit 1 )

total_num=`wc -l ${inputimg}.plt | awk '{print $1}'`
bad_num=`wc -l bad_ptcls.plt | awk '{print $1}'`

awk '(NF>3){print}' ${inputstar} > del.star #remove header
cat -b del.star > del2.star
awk '(NF<3){print}' ${inputstar} > ${output}  #put header in output
awk 'NR==FNR{a[$0];next}!($1 in a) {printf "%s%13s%13s%1s%s%13s%13s%13s%13s%13s%13s%13s%13s%13s\n",$2,$3,$4," ",$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' bad_ptcls.plt del2.star >> ${output} #remove lines with (numbers from bad_ptcls.plt) from star file
rm -f del.star del2.star

final_num=`grep mrcs ${output} | wc -l`
echo -e "Input: ${total_num} particles\nBad particles: ${bad_num}\nOutput: ${final_num} particles in file [${output}]"
