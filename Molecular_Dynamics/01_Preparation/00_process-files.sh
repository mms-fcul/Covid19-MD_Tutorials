# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should work with GMX versions 2018-2020
#grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx
#
# System name to be used throughout this tutorial
Sys=MPro
#
# Isolate Protease from original PDB
egrep "ATOM" 6y2g.pdb > ${Sys}.pdb
#
# Now we process the 13b ligand (named O6K in the structure) into separate files
for lig in 1 2
do
    $grom editconf -f ligand${lig}_unitedatom_original_geometry.pdb -o ligand${lig}.gro
done
# File "SFY6_GROMACS_G54A7FF_unitedatom.itp" was downloaded from
# ATB and has several custom atom types. We can revert them back to
# the standard GROMOS 54A7 atomtypes, which are not optimized, but
# completely transferable. The ligand name can also be corrected from
# SFY6, which was created by ATB, to O6K, which is the name adopted
# in the original pdb file.

sed '
s/SFY6/O6K /g
s/  CPos/     C/g
s/ OEOpt/    OE/g
s/  HS14/     H/g
s/  CAro/     C/g
s/  NOpt/    NR/g' SFY6_GROMACS_G54A7FF_unitedatom.itp > ligand.itp

# The final files: "ligand.itp", "MPro.pdb" and "ligand{1,2}.gro"
# will be available for the next steps: topology, box creation and solvation

rm -f *~ *# .*~ .*# 
