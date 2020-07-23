#!/bin/bash -e
# Variable to invoke the program GROMACS
#grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx
#
# Input files:
tpr=../../5_MD/MPro-ligs.tpr
xtc=../../5_MD/MPro-ligs.xtc
index=../../2_Setup/index.ndx

# With our simulation segments concluded (only one segment in our
# case), several analyses can be performed. To proceed, it is more
# efficient to process the trajectory obtained, center our protein
# in the box and correct any PBC artifacts that may arise. Please
# note that, in case there are several segments, an initial
# concatenation step shoul be performed using the "trjcat" module.
# We have identified a central residue in MPro (Tyr126) and, as
# previously indicated in Setup, we included its alpha carbon in the
# global index file for system centering purposes. 
# Using the "trjconv" module, we give the obtained trajectory file
# as input (-f .xtc) from which the atoms' coordinates will be read.
# To correctly identify the atoms from the .xtc file, we need 
# topology (-s .tpr) and index (-n .ndx) files. The "-center" flag,
# "-ur compact and "-pbc atom" are required to center our protein
# and correct the periodic boundary condition as previously explained,
# in this case, "-pbc atom" will place  every atom inside the box,
# which will be the original dodecahedron. The desired output file
# is chosen with "-o traj_all.xtc". The center ("center") and output
# ("Protein") groups were also provided. 

$grom trjconv -f $xtc \
      -s $tpr \
      -n $index \
      -o traj_all.xtc \
      -center -ur compact -pbc atom <<EOF
center
Protein
EOF

# After obtaining the centered and corrected trajectory, we can
# extract the frames in the pdb format for further visualization
# or analytical purposes using pymol and/or other tools. Since the
# trajectory is usually long, we should only write to the output
# every N frames: use "-skip 10" or using "-dt 10" if we want to
# use the trajectory's time reference. To align the trajectory to
# our reference structure, we can use the option "-fit rot+trans"
# and select the MPro molecule, which will be fitted using its
# RMSD value. The output .pdb file is named "-o traj_all-skip10.pdb"
# to highlight the fact that only 10% of the trajectory was kept.
$grom trjconv -f traj_all.xtc \
      -s $tpr  \
      -n $index \
      -o traj_all-skip10.pdb \
      -fit rot+trans -skip 10 <<EOF
MPro
Protein
EOF

rm -f *~ *# .*~ .*# 
