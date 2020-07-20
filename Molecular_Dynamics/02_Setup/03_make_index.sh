#!/bin/bash -e

# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should work with GMX versions 2018-2020
# grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx

# Further simulation settings and system analyses will require the
# user to operate upon specific groups of atom/molecules. The
# "make_ndx" gromacs module allows the creation of an index file
# using either a gro or pdb files as input. The index file has
# named entries (ex.: Protein, Solvent) thus designating the
# respective atoms to different groups. Since we will be  mainly
# discussing the protease and the ligands, we will delete all the
# default groups that are not needed using "del 2-12" and "del 3"
# commands (note that the group list is updated upon each action),
# then we will rename the ligand group (13b) by selecting the 2nd
# index "name 2 13b", the protease (MPro) group "name 1 Mpro" and
# the group with atoms from both MPro+13b is designated Protein
# with "name 5 Protein".

$grom make_ndx -f dode_solv.gro -o index.ndx<<EOF
del 2-12
del 3
name 2 13b
name 1 MPro
name 4 Protein
q
EOF

rm -f *~ *# .*~ .*# 
