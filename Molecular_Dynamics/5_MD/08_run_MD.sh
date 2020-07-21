#! /bin/bash -e
# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should worth with gromacs versions 2018-2020
#grom=/gromacs/gromacs-2020.2-GPU/bin/gmx
grom=/usr/bin/gmx
#
# Variable to define a standard name for the current step
Sys=MPro-ligs
#
# Input files needed:
top=../2_Setup/${Sys}.top
index=../2_Setup/index.ndx
prev=../4_Initialization/init3.gro
#
# Variables to define the number of CPU cores used in the machine
CPUs=16 

#
# Run the grompp module to obtain the coordinate .tpr file required
# to run the mdrun command, as previously:
$grom grompp -f ${Sys}.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -o ${Sys}.tpr \
      -maxwarn 10
#
# Run MD segment if only using CPUs, use this first line:
# $grom mdrun -nt $CPUs -pin auto \

# If using a GPU enabled GMX version, please use this modified line:
$grom mdrun -ntomp $CPUs -ntmpi 1 -pin on \
      -s ${Sys}.tpr \
      -x ${Sys}.xtc \
      -c ${Sys}.gro \
      -e ${Sys}.edr \
      -g ${Sys}.log \
      -nice 19
#
#cleanup
rm -f *~ *# .*~ .*# mdout.mdp state*.cpt

exit 0
