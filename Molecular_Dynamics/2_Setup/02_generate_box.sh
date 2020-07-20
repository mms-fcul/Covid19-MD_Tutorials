#!/bin/sh -e
# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should work with GMX versions 2018-2020
# grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx

# System name to be used throughout this step
Sys=MPro-ligs

# The gromacs module "editconf" creates a box with a dodecahedrical
# shape using the option "-bt dodecahedron", with a certain distance
# in nanometers (nm)  "-d 0.8" between the solute and the box side.
# The input file is defined using "-f Mpro-ligs.gro" and the output
# file with "-o dode.gro". The -c flag is used to center the system
# in the box. Similarly with the pdg2gmx step, we will renumber the
# residue order by using the flag "-resnr 1". 
# Note: The distance between solute and the box needs to be large
# enough to avoid the molecule to see it's periodic image.

$grom editconf -f ${Sys}.gro -o dode.gro -bt dodecahedron -d 0.8 -c -resnr 1

# Afterwards, it is necessary to add solvent molecules, in this case
# spc water molecules, to solvate our system in the box. That is done by
# using the "-cp dode.gro" to select the input file and "-cs spc216.gro"
# to select the reference solvent molecule. The number of water
# molecules to be added are automatically calculated by the program
# to fill the volume of the box. Since we are adding new molecules
# to our system, the program needs to update the topology in the
# molecules section, hence we provide it with flag "-p Mpro-ligs.top".

$grom solvate -cp dode.gro -cs spc216.gro -p ${Sys}.top -o dode_solv.gro

# This final command uses the "trjconv" module to convert our .gro file
# to a .pdb and perform a periodic boundary conditions (pbc) correction
# in the system "-pbc atom", while keeping the compact dodecahedron box
# shape "-ur compact". With this step, we obtain the real system shape,
# as was created and regardless of how the visualization software is able
# to deal with the different box vectors. We provide an input file
# "-f dode_solv.gro"  and a reference structure file "-s dode_solv.gro".
# Note: The trjconv module as several features and options which should
# be carefully examined with the "-h" flag.

$grom trjconv -f dode_solv.gro -s dode_solv.gro -o dode_solv.pdb -ur compact -pbc atom <<EOF
0
EOF

rm -f *~ *# .*~ .*# 

exit 0
