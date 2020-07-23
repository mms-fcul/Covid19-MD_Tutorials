#!/bin/bash -e 

#grom=/gromacs/gromacs-2020.2/bin/gmx
grom=/usr/bin/gmx
#
# Variables to use the system information (.tpr), index and full
# trajectory of the simulation
tpr=../../3_Minimization/min1.tpr
index=../../2_Setup/index.ndx
xtc=../1_traj/traj_all.xtc

# When simulating homodimers or any other symmetric complexes,
# we can calculate the level of symmetry of the different
# monomers. It is a simple trick, where pymol is used to align
# one image to the other and report the best RMSD obtained.
# Here, we can perform this calculation for the symmetry
# deviations between either the MPro monomers and the ligands.

# We will do this by extracting a number of conformations from
# the trajectories, feed them to the script, on the fly, and
# collect the obtained RMSD value to an output.

$grom trjconv -f $xtc \
      -s $tpr  \
      -n $index \
      -o frame.gro \
      -fit rot+trans \
      -skip 100 -sep <<EOF
MPro
Protein
EOF

rm -f *.xvg
for t in {0..1000}
do
    if [ -f frame$t.gro ]
    then
	
# Calculate MPro monomer symmetry
cat >aux.pml <<EOF
load frame$t.gro, monA
cmd.remove("(solvent and (all))")
sel Na, resn Na*
cmd.remove("Na");cmd.delete("Na")
sel Ligs, resi 603-606
cmd.remove("Ligs");cmd.delete("Ligs")
sel AAA, resi 302-602
cmd.extract(None,"AAA",zoom=0)
set_name obj01, monB
cmd.delete("AAA")
alter monB, resi=str(int(resi)-301)
sort monB
align monB, monA
EOF

pymol -c aux.pml >aux.out

awk -v time=`awk 'NR==1{print substr($0,20,10)/1000}' frame$t.gro` \
    '$1=="Executive:" && $2=="RMSD"{print time, $4/10}' \
    aux.out >> symm-MPro.xvg

rm -f aux.{pml,out}

# Calculate Ligands symmetry
cat >aux.pml <<EOF
load frame$t.gro, compA
cmd.remove("(solvent and (all))")
sel Na, resn Na*
cmd.remove("Na");cmd.delete("Na")
sel extra, resi 603-604
cmd.remove("extra");cmd.delete("extra")
sel AAA, resi 302-602+606
cmd.extract(None,"AAA",zoom=0)
set_name obj01, compB
cmd.delete("AAA")
sel monA, resi 1-301
sel monB, resi 302-602
alter monB, resi=str(int(resi)-301)
sort monB
sel LigA, resi 605
sel LigB, resi 606
alter LigB, resi=str(int(resi)-1)
sort LigB
align monB, monA
rms_cur LigA, LigB

EOF

pymol -c aux.pml >aux.out

awk -v time=`awk 'NR==1{print substr($0,20,6)/1000}' frame$t.gro` \
    '$1=="Executive:" && $2=="RMSD" && $7==57 {print time, $4/10}' \
    aux.out >> symm-Ligands.xvg

rm -f aux.{pml,out}
	
    fi
    

done


# 
# Application of a smoothing function (sliding window average)
# to the data files and removal of headings. The 50 points
# window (w=50) corresponds to sliding averages of 5 ns.
for output in MPro Ligands 
do
    awk -v w=50 '!/^(#|@)/{n++;h1[n]=$2};END{for (i=1;i<=n-w+1;i++){s1=0; for (k=0;k<=w-1;k++) {s1+=h1[i+k]}; print skip+(((i+w-1)-(w/2)))/10, s1/w}}' \
        symm-${output}.xvg > symm-${output}_average.xvg
done

# Cleanup
rm -f *~ *# .*~ .*# *.gro

exit 0
