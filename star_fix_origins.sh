#!/bin/bash
echo "
This script will parse input particle star file and will create corrected coordinate star files
for the particle re-extraction in Relion as well as micrograph star file.
This can be useful e.g. after 3D refinement to decrease interpolation.

It is recommended to start the script in Relion project folder so it can locate micrographs correctly!"
#
# Usage: star_fix_origins.sh file.star
# Output: for each micrograph creates MicName_corr.star coordinate file

if [ "$#" -ne 1 ] || [ ! `echo "$1" | grep ".star"` ]; then
        echo -e "\nUsage: `basename $0` file.star\n"
        exit 1
fi
echo -n "It is assumed that micrographs are uncoarsed, while particles might be not. Provide a coarse factor for this particle star file (default 1): "
read coarse
coarse=${coarse:-1}
re='^[0-9]+$'
if ! [[ $coarse =~ $re ]]; then
        echo "Error: provide a number!" >&2; exit 1
fi

# create header for output
cat <<EOF > .tmp_header_ptcls

data_

loop_ 
_rlnCoordinateX #1 
_rlnCoordinateY #2 
_rlnAnglePsi #3 
_rlnClassNumber #4 
_rlnAutopickFigureOfMerit #5
EOF

cat <<EOF > .tmp_header_mics

data_

loop_ 
_rlnMicrographName #1 
_rlnCtfImage #2 
_rlnDefocusU #3 
_rlnDefocusV #4 
_rlnDefocusAngle #5 
_rlnVoltage #6 
_rlnSphericalAberration #7 
_rlnAmplitudeContrast #8 
_rlnMagnification #9 
_rlnDetectorPixelSize #10  
_rlnCtfFigureOfMerit #11
EOF

# get header column numbers from star file
[ -f $1 ] || (echo "Error: input file does not exist!" && exit 1)
xcrd=`awk 'NF<3{print}' $1 | grep "_rlnCoordinateX" | cut -d'#' -f2`
ycrd=`awk 'NF<3{print}' $1 | grep "_rlnCoordinateY" | cut -d'#' -f2`
psi=`awk 'NF<3{print}' $1 | grep "_rlnAnglePsi" | cut -d'#' -f2`
cls=`awk 'NF<3{print}' $1 | grep "_rlnClassNumber" | cut -d'#' -f2`
fom=`awk 'NF<3{print}' $1 | grep "_rlnAutopickFigureOfMerit" | cut -d'#' -f2`
mic=`awk 'NF<3{print}' $1 | grep "_rlnMicrographName" | cut -d'#' -f2`
oriX=`awk 'NF<3{print}' $1 | grep "_rlnOriginX" | cut -d'#' -f2`
oriY=`awk 'NF<3{print}' $1 | grep "_rlnOriginY" | cut -d'#' -f2`
ctfim=`awk 'NF<3{print}' $1 | grep "_rlnCtfImage" | cut -d'#' -f2`
defu=`awk 'NF<3{print}' $1 | grep "_rlnDefocusU" | cut -d'#' -f2`
defv=`awk 'NF<3{print}' $1 | grep "_rlnDefocusV" | cut -d'#' -f2`
defa=`awk 'NF<3{print}' $1 | grep "_rlnDefocusAngle" | cut -d'#' -f2`
vol=`awk 'NF<3{print}' $1 | grep "_rlnVoltage" | cut -d'#' -f2`
sa=`awk 'NF<3{print}' $1 | grep "_rlnSphericalAberration" | cut -d'#' -f2`
ac=`awk 'NF<3{print}' $1 | grep "_rlnAmplitudeContrast" | cut -d'#' -f2`
mag=`awk 'NF<3{print}' $1 | grep "_rlnMagnification" | cut -d'#' -f2`
det=`awk 'NF<3{print}' $1 | grep "_rlnDetectorPixelSize" | cut -d'#' -f2`
ctffom=`awk 'NF<3{print}' $1 | grep "_rlnCtfFigureOfMerit" | cut -d'#' -f2`
star="$1"

# print required fields to tmp file
rm -f .tmp_coords
function FOM {
awk_command='NF>3{print $mic,$xcrd-coarse*$oriX,$ycrd-coarse*$oriY,$psi,$cls,$fom}'
awk -v coarse=$coarse -v xcrd=$xcrd -v ycrd=$ycrd -v psi=$psi -v cls=$cls -v fom=$fom -v mic=$mic -v oriX=$oriX -v oriY=$oriY "${awk_command}" "$star" > .tmp_coords
}

if [ -z $fom ]; then fom=999; FOM; fi

# create new coord star files
awk '{print $1}' .tmp_coords | sort | uniq > .tmp_mics
total=`wc -l < .tmp_mics`
count=1
while read line
do
        coordfile=`echo "$line" | sed 's/.mrc/_corr.star/'`
        echo -ne "Processing micrograph ${count}/${total}...\r"
        cat .tmp_header_ptcls > "$coordfile"
        awk '{if($1=="'$line'") {printf "%12.6f%13.6f%13.6f%13d%13.6f\n",$2,$3,$4,$5,$6}}' .tmp_coords >> "$coordfile"
((count++))
done < .tmp_mics

# create new mics star file
awk_command2='NF>3{print $mic,$mic,$defu,$defv,$defa,$vol,$sa,$ac,$mag,$det,$ctffom}'
awk -v mic=$mic -v defu=$defu -v defv=$defv -v defa=$defa -v vol=$vol -v sa=$sa -v ac=$ac -v mag=$mag -v det=$det -v ctffom=$ctffom "${awk_command2}" "$star" > .tmp_mics2
sed -i 's/.mrc/.ctf/2' .tmp_mics2
cat .tmp_mics2 | uniq > .tmp_mics2b
cat .tmp_header_mics > micrographs_corr.star
awk '{printf "%s %s%13.6f%13.6f%13.6f%13.6f%13.6f%13.6f %13s%13.6f%13.6f\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' .tmp_mics2b >> micrographs_corr.star
echo -e "\nDONE!\nNew coordinate files are *_corr.star. Micrographs are in micrographs_corr.star file"
rm -f .tmp_*
