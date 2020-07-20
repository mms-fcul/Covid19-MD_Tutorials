#!/bin/sh -e
# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should work with GMX versions 2018-2020
# grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx

# System name to be used throughout this step
Sys=MPro-ligs

# After setting up our system with the protease, ligands and solvent,
# we noticed that the protein has an imbalance between anionic and
# cationic residues. A surplus of four anionic residues per monomer
# results in a total charge of -8, which needs to be neutralized with
# the addition of ions (cations in this case). The genion GMX tool
# can be used, but it requires a .tpr input file, which needs to be
# created "a priori". The "grompp" module creates this .tpr file that
# comprises the atom coordinates, topology information, index and
# simulation parameters. All files are available but the parameters
# one which needs to be created. With the following command an empty
# parameters file is created, which means that grompp will use all
# default values, which is fine for this purpose.
echo ";" >aux.mdp
# The grompp input files are provided with "-f aux.mdp", for the
# simulation parameters; "-c dode_solv.gro" for the atom coordinates;
# and "-p MPro-ligs.top" for the topology. As usual, the output is
# given by "-o MPro-ligs_genion.tpr" and the flag "-maxwarn 10"
# increases the number of acceptable warnings before the program
# exits, which are not problematic in this case and should be
# ignored.
$grom grompp -f aux.mdp -c dode_solv.gro -p ${Sys}.top -n index.ndx -o ${Sys}_genion.tpr -maxwarn 10

# The "genion" module adds ions to the system by changing a molecule
# from the chosen group (usually solvent) to an ion. The group is
# selected from the index file "-n index.ndx" and, in our case, we
# selected "SOL", which contains the water molecules. In our case,
# we need cationic residues, hence we chose 8 sodium atoms (Na+) to
# reach the overall system neutrality. The positive cations can be
# selected with flags "-pname NA", for name, and "-np 8", for the
# amount. The negative anions, which are not required in our case,
# can be evoked with "-nname CL", as an example of chlorine ions,
# and with "-nn 0" to select the amount.
$grom genion -s ${Sys}_genion.tpr -n index.ndx -o dode_ion.gro -pname NA -nname CL -np 8 -nn 0 -p ${Sys}.top <<EOF
SOL
EOF

rm -f *~ *# .*~ .*# aux* mdout.mdp

exit 0
