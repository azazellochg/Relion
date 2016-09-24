#!/bin/bash
# This script removes X particles within specified angular range
if [ "$#" -lt 5 ]; then
        echo -e "This script removes over-represented views within Relion STAR files.\n"
        echo -e "Usage: `basename $0` <relion_star_file> <angle> <min> <max> <number_to_remove>\n\nOptions:"
        printf "%-25s%s\n" "<relion_star_file>" "Relion star file that will be reweighted based upon Euler angles."
        printf "%-25s%s\n" "<angle>" "Angle to be used: rot, tilt or psi."
        printf "%-25s%s\n" "<min>" "(INT) Lower limit for <angle>. Default ranges are: -180<rot<180, 0<tilt<180, -180<psi<180."
        printf "%-25s%s\n" "<max>" "(INT) Upper limit for <angle>. Default ranges are: -180<rot<180, 0<tilt<180, -180<psi<180."
        printf "%-25s%s\n" "<number_to_remove>" "(INT) Number of particles to remove from preferential view, specified WITHIN the limits above."
        printf "%-25s%s\n" "-v" "Verbose output, used for debug."
        echo -e "\nExample: `basename $0` particles.star rot 120 150 2000\nThis will remove 2000 particles with AngleRot within 120-150 degrees."
        exit 1
fi
echo "Do you want to sort particles by MaxValueProbDistribution or LogLikeliContribution before proceeding with analysis? "
echo "In this case particles with the worst values will be removed (within selected angular range, of course)"
echo -n "Your answer: (1 - yes, 0 - no) [default: 0] "
read ans
ans=${ans:-0}
re='^[0-1]+$'
if ! [[ $ans =~ $re ]]; then
        echo "Error: wrong answer" && exit 1
fi
if [ $ans -eq 1 ]; then
        echo -n "Choose sorting parameter: MaxValueProbDistribution (1) or LogLikeliContribution (2), default (2): "
        read param
        param=${param:-2}
        re2='^[1-2]+$'
        if ! [[ $param =~ $re2 ]]; then
                echo "Error: wrong answer" && exit 1
        fi
fi

#check inputs
[ ! -f $1 ] && echo "Error: file $1 does not exist" && exit 1
[[ $2 != "rot" && $2 != "tilt" && $2 != "psi" ]] && echo "Error: unknown angle $2. Please, specify rot, tilt or psi" && exit 1
[ $3 -gt $4 ] && echo "Error: min > max angle" && exit 1
[[ $3 -le -180 || $3 -ge 180 || $4 -le -180 || $4 -ge 180 ]] && \
echo "Error: wrong angles. Default ranges are: -180<rot<180, 0<tilt<180, -180<psi<180" && exit 1
output=`echo $1 | sed 's/.star/_reweighted.star/'`
[ -f $output ] && echo "Error: output file $output already exists" && exit 1

#get number of input particles
tot=`grep -c mrcs $1`
[ $5 -ge $tot ] && echo "Error: number of particles to remove is greater than the total number of particles" && exit 1

#get relion header
rot=`awk 'NF<3{print}' $1 | grep "_rlnAngleRot" | cut -d'#' -f2`
tilt=`awk 'NF<3{print}' $1 | grep "_rlnAngleTilt" | cut -d'#' -f2`
psi=`awk 'NF<3{print}' $1 | grep "_rlnAnglePsi" | cut -d'#' -f2`
[[ -z $rot || -z $tilt || -z $psi ]] && echo "Error: required angles not found in Relion header" && exit 1
if [ $ans -eq 1 ]; then
        mvpd=`awk 'NF<3{print}' $1 | grep "_rlnMaxValueProbDistribution" | cut -d'#' -f2`
        llc=`awk 'NF<3{print}' $1 | grep "_rlnLogLikeliContribution" | cut -d'#' -f2`
        [[ -z $mvpd || -z $llc ]] && echo "Error: MaxValueProbDistribution or LogLikeliContribution not found in Relion header" && exit 1
fi

#check tilt range
testTilt=`awk -v tilt=$tilt 'NF>3{print $tilt}' $1 | sort -rn | head -n1`
if echo "$testTilt" | grep "-" > /dev/null 2>&1; then
        echo "Warning: AngleTilt is within -180<tilt<0 range."
        [ $2 == "tilt" ] && [ $3 -gt 0 -o $4 -gt 0 ] && echo "Error: AngleTilt must be within -180<tilt<0 range" && exit 1
else
        [ $2 == "tilt" ] && [ $3 -lt 0 ] && echo "Error: AngleTilt must be within 0<tilt<180 range" && exit 1
fi

#select angle
[ -f .tmp_input ] && rm -f .tmp_input
case $2 in
"rot")
        ang=$rot
        ;;
"tilt")
        ang=$tilt
        ;;
"psi")
        ang=$psi
        ;;
*)
        echo "Error: this should not happen" && exit 1
        ;;
esac

#sort by param if requested: lower/worse mvpd/llc will be at the end of file
if [[ $ans -eq 1 && $param -eq 1 ]]; then
        awk 'NF>3' $1 | sort -nr -k $mvpd > .tmp_input_sorted
elif [[ $ans -eq 1 && $param -eq 2 ]]; then
        awk 'NF>3' $1 | sort -nr -k $llc > .tmp_input_sorted
fi

#save selected particles
if [ $ans -eq 0 ]; then
        awk -v ang=$ang -v min=$3 -v max=$4 '{if (NF>3 && $ang>min && $ang<max){print}}' $1 > .tmp_input
else
        awk -v ang=$ang -v min=$3 -v max=$4 '{if ($ang>min && $ang<max){print}}' .tmp_input_sorted > .tmp_input
fi

remove=`wc -l < .tmp_input`
[ $remove -eq 0 ] && echo "Error: no particles found within specified angular range" && exit 1
[ $5 -gt $remove ] && echo "Error: number of particles to remove ($5) is greater than the number of particles WITHIN specified range ($remove)" && exit 1

#remove specified number of particles
echo -e "Found $remove particles (out of $tot) within angular range $3 < $2 < $4.\nGoing to remove $5 particles.." 
if [ $ans -eq 0 ]; then
        sort -r .tmp_input | head -n $5 > .tmp_bad
else
        tail -n $5 .tmp_input > .tmp_bad
fi

awk 'NR==FNR{a[$0];next}NF<3||!($0 in a)' .tmp_bad $1 > $output 
totNew=`grep -c mrcs $output`
echo "New star file $output with $totNew particles created"

#debug
if [[ $6 == "-v" ]]; then
        outputBad=`echo $1 | sed 's/.star/_discarded.star/'`
        outputSel=`echo $1 | sed 's/.star/_selected.star/'`
        outputSort=`echo $1 | sed 's/.star/_sorted.star/'`
        mv .tmp_bad $outputBad
        mv .tmp_input $outputSel
        [ -f .tmp_input_sorted ] && mv .tmp_input_sorted $outputSort
        grep -c mrcs `echo $1 | sed 's/.star/*/'`
else
        rm -f .tmp_input .tmp_bad .tmp_input_sorted
fi
