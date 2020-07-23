#!/bin/bash -e 

#grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx
#
# Variables to use the system information (.tpr), index and full
# trajectory of the simulation
tpr=../../3_Minimization/min1.tpr
index=../../2_Setup/index.ndx
xtc=../1_traj/traj_all.xtc
#
# The gyrate module will calculate the radius of gyration for a
# given trajectory or structure file provided in the -f flag.
# This property calculates the square root of the sum of the
# square of the distance from each atom to its center of mass.
# This gives the user a measure of how compact the protein is
# during the simulation. The "Protein" and "MPro" options denote
# the index groups choosen for the calculation. In this case,
# two separate calculations are done, one for the whole complex
# of protein+ligands, and another for the protein in apo state.

$grom gyrate -f $xtc \
	     -s $tpr \
	     -o gyration_MPro-and-Ligands.xvg \
	     -n $index <<EOF
Protein
EOF

$grom gyrate -f $xtc \
	     -s $tpr \
	     -o gyration_MPro.xvg \
	     -n $index  <<EOF
MPro
EOF

# 
# Application of a smoothing function (sliding window average)
# to the data files and removal of headings. The 50 points
# window (w=50) corresponds to sliding averages of 5 ns.
for output in MPro MPro-and-Ligands
do
    awk -v w=50 '!/^(#|@)/{n++;h1[n]=$2};END{for (i=1;i<=n-w+1;i++){s1=0; for (k=0;k<=w-1;k++) {s1+=h1[i+k]}; print skip+(((i+w-1)-(w/2)))/10, s1/w}}' \
        gyration_${output}.xvg > gyration_${output}_average.xvg
done


# Cleanup
rm -f *~ *# .*~ .*#

exit 0
