#!/bin/sh -e 
# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should worth with gromacs versions 2018-2020
#grom=/gromacs/gromacs-2020.2-GPU/bin/gmx
grom=/usr/bin/gmx

# After obtaining a well solvated electroneutral system using the
# previous Setup steps, we will perform a stepwise energy minimization
# protocol. This will eliminate high energy conformations and correct
# undesired interactions that would lead to system instabilities and
# possibly the simulations' collapse. Each step of the minimization
# procedure will lower the overall system energy towards a minimum,
# ideally, approaching the global energy minimum of the system.

# System name to be used throughout this step
Sys=MPro-ligs

# Input files needed:
top=../02_Setup/${Sys}.top
index=../02_Setup/index.ndx
prev=../02_Setup/dode_ion.gro
# Variable defining the name for the first step of the minimization
curr=min1

# Number of CPU cores to be used in the calculation
CPUs=8

# The following minimization steps use the same protocol and the
# same gromacs modules and flags, however the .mdp files (MD
# parameters) differ from each other and you should inspect it
# before running this script. The grompp module prepares a .tpr
# file with all the compiled simulation settings of our system,
# incorporatinf the information from the parameters (-f .mdp),
# the topology (-p .top), the coordinates (-c .gro) and the index
# (-n .ndx). It writes a thorough output parameter file with the
# currently used .mdp parameters (-po .mdp), the ones suplied by
# the user and the remaining default ones. It also writes a
# processed topology (-pp .top) with all topological information
# of our system, completely independent of the force field used.
# Finally, the "-maxwarn 1000" overrides the halt order when
# multiple warning occurs. For this tutorial, the occurring warnings
# are not problematic and can be ignored, but for future cases
# the user should always check for any problematic warnings.

### First minimization procedure ###

## Make the tpr file for Minimization
$grom grompp -f ${curr}.mdp \
      -po ${curr}_out.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -pp ${curr}_processed.top \
      -o ${curr}.tpr \
      -maxwarn 1000

# After creating the .tpr input file with the processed simulation
# parameters, the "mdrun" gromacs module is ready to run the MD
# integrator. It reads the input (-s .tpr) and performs a steepest
# descent minimization procedure. This module writes several outputs:
# a .xtc compressed trajectory file (-x .xtc) which contains only the
# atom positions; a .trr full precision trajectory file (-o .trr)
# which comprise the coordinates, velocities, and optionally the
# forces; a .gro file (-c .gro) with a snapshot of the final system
# configuration, containing both the atoms coordinates and velocities;
# an energy file (-e .edr) where the system's energy parameters are
# stored; and a log file (-g .log) of the simulation run.
# The additional flags "-nice 19" decrease the job priority level of
# the process in your system, "-nt 2" indicates the total number of
# cpu threads to use and "-pin auto" is to adress core thread affinities
# which should be left to auto if you are not an advanced user.

# Run Minimization
$grom mdrun -s ${curr}.tpr \
      -x ${curr}.xtc \
      -c ${curr}.gro \
      -e ${curr}.edr \
      -g ${curr}.log \
      -v -nice 19 \
      -nt $CPUs -pin auto

# The following two minimization procedures use the same logic and
# commands, with slight differences in the input files (min{2,3}.mdp).
# The user should now inspect each .mdp file to understand what type
# of input parameters exist and which require more fine-tuning.

### Second minimization procedure ###
#
# Updated block names and input configuration
prev=./min1.gro
curr=min2
#
# Make the tpr file for the Minimization
$grom grompp -f ${curr}.mdp \
      -po ${curr}_out.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -pp ${curr}_processed.top \
      -o ${curr}.tpr \
      -maxwarn 1000
#
# Run Minimization
$grom mdrun -s ${curr}.tpr \
      -x ${curr}.xtc \
      -c ${curr}.gro \
      -e ${curr}.edr \
      -g ${curr}.log \
      -v -nice 19 \
      -nt $CPUs -pin auto
#

# Prepare the two output .gro files for visualization:
for i in 1 2
do
    $grom trjconv -f min${i}.gro \
	  -s min1.tpr \
	  -o min${i}.pdb \
	  -n $index \
	  -center -pbc mol <<EOF
center
Protein
EOF
done

# cleanup
rm -f *~ *# .*~ .*# traj.trr
