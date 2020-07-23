#!/bin/bash -e 

#grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx
#
# Variables to use the system information (.tpr), index and full
# trajectory of the simulation
tpr=../../3_Minimization/min1.tpr
index=../../2_Setup/index.ndx
xtc=../1_traj/traj_all.xtc

# The sasa module provides the surface area acessible to solvent
# of a structure or trajectory provided in the -f flag. The -tu
# flag defines the unit of time to be used on the x-axis The
# -surface flag defines a group of atoms from the index file on
# whose surface the calculation will be done. The -output flag
# defines another group, which is a sub-group of -surface for
# which the calues will be written.
# Here, we performed five separate calculations:
# - the first will calculate the surface of the whole complex
#   (protein: MPro (2 subunits) + 13b (2 copies)) and write the
#   total values to the output;
# - the two following calculations were performed on the whole
#   complex, as the first, but only the values related to the
#   surface of each ligand were written;
# - finally, in the last two calculations, the SAS is calculated
#   and written for the two ligands as if the MPro protein was
#   not there.

$grom sasa -f $xtc \
	   -s $tpr \
	   -o sasa_protein.xvg \
	   -n $index \
	   -tu ns \
           -surface Protein \
           -output Protein

$grom sasa -f $xtc \
	   -s $tpr \
	   -o sasa_Prot-MonA_13b.xvg \
	   -n $index \
	   -tu ns \
           -surface Protein \
           -output Mon_A_13b

$grom sasa -f $xtc \
	   -s $tpr \
	   -o sasa_Prot-MonB_13b.xvg \
	   -n $index \
	   -tu ns \
           -surface Protein \
           -output Mon_B_13b

$grom sasa -f $xtc \
	   -s $tpr \
	   -o sasa_Mon-A_13b-MonA_13b.xvg \
	   -n $index \
	   -tu ns \
           -surface Mon_A_13b \
           -output Mon_A_13b

$grom sasa -f $xtc \
	   -s $tpr \
	   -o sasa_Mon-B_13b-MonB_13b.xvg \
	   -n $index \
	   -tu ns \
           -surface Mon_B_13b \
           -output Mon_B_13b

# By calculating these separate SAS values, we can estimate the
# magnitude of the interfacial surface area between MPro and
# each of the two ligands.
for mon in A B
do
    paste sasa_Mon-${mon}_13b-Mon${mon}_13b.xvg sasa_Prot-Mon${mon}_13b.xvg \
	  | awk '!/^[@;#]/{print $1, $3-$6}' >  sasa_interface_MPro-13b_${mon}.xvg

# 
# Application of a smoothing function (sliding window average)
# to the data files and removal of headings. The 100 points
# window (w=100) corresponds to sliding averages of 10 ns.

     awk -v w=100 '{n++;h1[n]=$2};END{for (i=1;i<=n-w+1;i++){s1=0; for (k=0;k<=w-1;k++) {s1+=h1[i+k]}; print skip+(((i+w-1)-(w/2)))/10, s1/w}}' sasa_interface_MPro-13b_${mon}.xvg > sasa_interface_MPro-13b_${mon}_average.xvg
done

# Cleanup
rm -f *~ *# .*~ .*#

exit 0
