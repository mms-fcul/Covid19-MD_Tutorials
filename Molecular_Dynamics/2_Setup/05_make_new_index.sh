#!/bin/bash -e
# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should work with GMX versions 2018-2020
grom=/gromacs/gromacs-2020.2/bin/gmx
#grom=/usr/bin/gmx

# At the end of our system setup, we have performed several
# modifications to our initial pdb files: adding ligands,
# renumbering our residues, include solvent and ions. As such,
# we now need to update our index file with every added group.
# We start by removing non-interesting default groups using
# "del 2-12", "del 3" and "del 4-6". We rename the "Protein"
# group to "MPro" through "name 1 MPro" and create the new
# "Protein" group by merging the MPro and ligand groups with
# "1 | 4". We also create a new "SOL" group by merging the
# water and ions groups, third and fifth groups respectively,
# using " 3|5" and renaming it in "name 8 SOL". In the end,
# we will create a group with all alpha carbons from the
# protease, which will be usefull for structure fitting and
# RMSD analyses.
$grom make_ndx -f dode_ion.gro -o index.ndx <<EOF
del 2-12
del 3
del 4-6
name 1 MPro
1|4
name 7 Protein
3|5
name 8 SOL
name 4 13b
a CA
a 1250
name 10 center
r 605
name 11 Mon_A_13b
r 606
name 12 Mon_B_13b
r 1-301
name 13 Mon_A
r 302-602
name 14 Mon_B
9&13
name 15 Mon_A_CA
9&14
name 16 Mon_B_CA
q
EOF

rm -f *~ *# .*~ .*# 
