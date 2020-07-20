#!/bin/bash -e 
# Variable to invoke the program GROMACS
# Please change according to your gromacs instalation
# This tutorial should worth with gromacs versions 2018-2020
grom=/gromacs/gromacs-2020.2-GPU/bin/gmx
#grom=/usr/bin/gmx

# In this initialization procedure, we start the MD simulation by
# introducing temperature and pressure to a frozen still system.
# We should be very gentle when first allowing movement in our system
# due to large interaction energies inside the box. Once we heat up
# our system on the first step of the equilibration (init1), the
# solvent/solute interactions are not optimal and thus we must
# restrain the position of the protein atoms while water molecules
# accommodate themselves. 
#
# System name to be used throughout this step
SysName=MPro-ligs
#
# Input files needed:
top=../02_Setup/${SysName}.top
index=../02_Setup/index.ndx
prev=../03_Minimization/min2.gro

# Variable defining the name for the first step of the initialization
curr=init1
#
# Number of CPU cores to be used in the calculation
CPUs=8
#
## First initialization procedure (init1) ##
# These initialization steps follow a similar procedure from the
# minimization. Grompp creates an input file (-o .tpr) required to
# run the MD segment and uses the parameters (-f .mdp), the coordinates
# (-c .gro), which should be the final configuration obtained in
# the minimization procedure, the system topology (-p .top) and an
# index (-n .ndx). In this initial step, the temperature coupling
# is turned on and the initiation is done at a constant number of
# particles, volume and temperature (NVT), and exclusive to this
# step, random initial velocities are generated for all atoms.
$grom grompp -f ${curr}.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -o ${curr}.tpr \
      -maxwarn 10 
#
# Run initiation
# The -nt flag defines the number of threads, or CPU cores in order
# to perform the MD segment using multiple CPUs (and GPU if available).
$grom mdrun -s ${curr}.tpr \
        -x ${curr}.xtc \
        -c ${curr}.gro \
        -e ${curr}.edr \
        -g ${curr}.log \
	-nice 19 -v \
	-nt $CPUs -pin auto

## Second initiation procedure ###
#
# After the temperature is equilibrated, we introduce pressure. The
# protocol is very similar, and we only need to create a new segment
# and update the settings in the .mdp input file. The pressure coupling
# is turned on and the initiation is done at a constant number of
# particles, pressure and temperature (NPT), and from this step onward,
# velocities are read from the previous trajectory
#
# Updated block names and input configuration
prev=./init1.gro
curr=init2
#
# Make the tpr file for initiation
$grom grompp -f ${curr}.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -o ${curr}.tpr \
      -maxwarn 10
#
# Run initiation
$grom mdrun -nt $CPUs -pin auto\
        -s ${curr}.tpr \
        -x ${curr}.xtc \
        -c ${curr}.gro \
        -e ${curr}.edr \
        -g ${curr}.log \
	-nice 19 -v

### Third initialization procedure ###
# In this step the only change is the integrator step from 0.001
# to 0.002 (compare "dt" line of init1.mdp or init2.mdp to init3.mdp
# file), which corresponds to the time step used for the production
# MD run, adressed later in this tutorial
#
# Updated block names and input configuration
prev=./init2.gro
curr=init3
#
# Make the tpr file for initiation
$grom grompp -f ${curr}.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -o ${curr}.tpr \
      -maxwarn 10

# Run initiation
$grom mdrun -nt $CPUs -pin auto\
        -s ${curr}.tpr \
        -x ${curr}.xtc \
        -c ${curr}.gro \
        -e ${curr}.edr \
        -g ${curr}.log \
	-nice 19 -v



# Prepare the two output trajectories for visualization:
cat init?.xtc > traj.xtc
$grom trjconv -f traj.xtc \
      -s init1.tpr \
      -o traj.pdb \
      -n $index \
      -center -fit rot+trans <<EOF
MPro
center
Protein
EOF

# cleanup
rm -f *~ *# .*~ .*# traj.xtc mdout.mdp state*.cpt

exit 0
