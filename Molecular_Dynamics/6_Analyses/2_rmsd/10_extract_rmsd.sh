#!/bin/bash -e 
# Variable to invoke the program GROMACS
#grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx

#
# Input files:
tpr=../../5_MD/MPro-ligs.tpr
xtc=../1_traj/traj_all.xtc
index=../../2_Setup/index.ndx

# In this first analysis, we will calculate the root mean
# square deviation (RMSD) of MPro monomers and the ligand
# structures along the trajectory against a reference
# structure. This type of analysis allows us to understand
# how the protease structure deviates from its initial
# structure, over time. Also, we can also measure how the
# ligands change their conformations (binding modes)
# compared to their crystal structures.
# The system index file, created in the system Setup, has
# several entries that will be usefull for this analysis.
# These are the groups to be selected:
# MPro - protease main chain;
# CA - alpha carbon atoms of each MPro residue;
# 13b - the two ligands bound to MPro;
# Mon_A and Mon_B - the individual monomers of MPro;
# Mon_A_CA and Mon_B_CA - the alpha carbons of each monomer;
# Mon_A_13b and Mon_B_13b - the individual ligands;
#
# To calculate the RMSD, we use the "rms" gromacs module
# and use as input the extracted trajectory file (-f .xtc).
# As a reference structure, we could use the Xray structure,
# it's relaxed form (after initialization), or any other
# structure that we find a good reference. We opted for the
# relaxed structure, corresponding to time = 0. The output
# files (-o .xvg) present the deviations between both
# structures in nanometers(nm) over time in picoseconds (ps).
# A rotational and translational (-fit rot+trans) fit to the
# reference structure was necessary to remove these effects
# from the calculation.

$grom rms -f $xtc \
          -s $tpr \
          -n $index \
          -o rms-MPro_all.xvg \
          -fit rot+trans <<EOF
MPro
MPro
EOF

$grom rms -f $xtc \
          -s $tpr \
          -n $index \
          -o rms-MPro_CA.xvg \
          -fit rot+trans <<EOF
CA
CA
EOF

$grom rms -f $xtc \
          -s $tpr \
          -n $index \
          -o rms-MonA_CA.xvg \
          -fit rot+trans <<EOF
Mon-A_CA
Mon-A_CA
EOF

$grom rms -f $xtc \
          -s $tpr \
          -n $index \
          -o rms-MonB_CA.xvg \
          -fit rot+trans <<EOF
Mon-B_CA
Mon-B_CA
EOF

$grom rms -f $xtc \
          -s $tpr \
          -n $index \
          -o rms-MonA_13b.xvg \
          -fit rot+trans <<EOF
Mon-A_CA
Mon-A_13b
EOF

$grom rms -f $xtc \
          -s $tpr \
          -n $index \
          -o rms-MonB_13b.xvg \
          -fit rot+trans <<EOF
Mon-B_CA
Mon-B_13b
EOF

# 
# Application of a smoothing function (sliding window average)
# to the data files and removal of headings. The 50 points
# window (w=50) corresponds to sliding averages of 5 ns.
for output in MPro_all MPro_CA MonA_CA MonB_CA MonA_13b MonB_13b
do
    awk -v w=50 '!/^(#|@)/{n++;h1[n]=$2};END{for (i=1;i<=n-w+1;i++){s1=0; for (k=0;k<=w-1;k++) {s1+=h1[i+k]}; print skip+(((i+w-1)-(w/2)))/10, s1/w}}' \
        rms-${output}.xvg > rms-${output}_average.xvg
done

rm -f *~ *# .*~ .*#

exit 0
