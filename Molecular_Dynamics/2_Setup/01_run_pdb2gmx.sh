# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should work with GMX versions 2018-2020
#grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx
#
# System name to be used throughout this tutorial
Sys=MPro

# Module to generate a topology from a pdb file
$grom pdb2gmx -f ../1_Preparation/${Sys}.pdb \
      -p ${Sys}.top -o ${Sys}.gro -ff gromos54a7 \
      -water spc -ignh -merge all -renum -ter <<EOF
0
0
0
0
EOF

# The program generates a topology for a specific force field
# which was given with the -ff option "gromos54a7". The water
# model used with option "-water" was SPC. The option "-ignh"
# tells gromacs to ignore all hydrogen atoms if they are present
# in the original PDB file. With option "-merge all", GMX will
# convert all chains in the original PDB into a single topology.
# The "-renum" forces a renumbering in the residue numbers. The
# "-ter" option tell GMX to ask the user for the correct
# protonation states of the chain termini. Since there are two
# chains in this homodimer, the program asks twice for the
# N-ter/C-ter protonation states. The provided (0,0 and 0,0)
# stands for the ionized forms.

# Since we have only one single topology for the homodimer, 
# we can change the protein name from "Protein_chain_A" to "Protein"
sed -i 's/Protein_chain_A/Protein       /g' ${Sys}.top

# Until this point, the topology only has information about the
# protein. We will now add the call to the ligand topology using
# an "include" statement right after the call for the G54A7 force field:
sed "s/\#include \"gromos54a7.ff\/forcefield.itp\"/\#include \"gromos54a7.ff\/forcefield.itp\"\n\#include \"\.\.\/1_Preparation\/ligand.itp\"/" ${Sys}.top > ${Sys}-ligs.top

# 
# Add two copies of 13b ligand to the molecules listing:
echo "O6K                2" >> ${Sys}-ligs.top

# The next section it just a little cut/paste to add the ligand
# coordinates to the original protein GRO file, gerated by
# pdb2gmx. We start by storing everything but the box size vector
# (last line):
head  -n -1 ${Sys}.gro > aux_prot
# than we also store this line with the box vector:
tail -n 1 ${Sys}.gro > aux_box
# We will add ligand 1 and ligand 2 sequentially to the protein GRO:
egrep "1O6K" ../1_Preparation/ligand1.gro >> aux_prot
egrep "2O6K" ../1_Preparation/ligand2.gro >> aux_prot
# Finally, we add the box vector and correct the second line, which
# counts the total number of atoms in the system (which changed):
cat aux_prot aux_box | awk -v tot=`awk 'END{print NR-2}' aux_prot` \
    '{if (NR==2){print tot}else{print $0}}' > ${Sys}-ligs.gro

# cleanup
rm -f *~ *# .*~ .*# aux*
