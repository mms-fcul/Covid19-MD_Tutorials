## Definition of variables
#grom="/gromacs/gromacs-2018.8/bin/gmx"
grom=/usr/bin/gmx

# Variables to use the system information (.tpr),
# index and full trajectory of the simulation
tpr=../../3_Minimization/min1.gro
ndx=../../2_Setup/index.ndx
xtc=../1_traj/traj_all.xtc
#
# The do_dssp module provides an interface to the DSSP software
# which calculates the secondary structure of a given structure.
# A trajectory file can be provided in the -f flag and two
# distinct output files are generated, an assignment of secondary
# structure per residue per frame (in case of a trajectory was
# given as input) in a matrix file (.xpm) and a count of total
# number of residues with each secondary structure type per frame
# (.xvg).
# Here, we performed the calculations for each MPro monomer:

for r in Mon_A Mon_B
do
    $grom do_dssp -f $xtc \
	  -s $tpr \
	  -n $ndx \
	  -o dssp_${r}.xpm \
	  -sc ss_${r}.xvg \
	  <<EOF
$r	      	      	
EOF
    
    # The following lines refer to the processing of the output
    # file containg the count of total number of residues with
    # each secondary structure type per frame (.xvg). Due to the
    # fact that the number of columns in this output file depends
    # on the variety of secondary structure types that the module
    # do_dssp finds and assigns, a more robust processing procedure
    # of this output was necessary.    
    #
    # In the following commands, the column that contains the
    # total count of residues for each secondary structure type
    # was identified and used to extract the data

    awk -v l=`awk '/legend "Coil"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-coil_${r}.xvg

    awk -v l=`awk '/legend "A-Helix"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-a-helix_${r}.xvg

    awk -v l=`awk '/legend "3-Helix"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-3-helix_${r}.xvg
    
    awk -v l=`awk '/legend "5-Helix"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-5-helix_${r}.xvg

    awk -v l=`awk '/legend "Turn"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-turn_${r}.xvg
    
    awk -v l=`awk '/legend "Bend"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-bend_${r}.xvg
    
    awk -v l=`awk '/legend "B-Sheet"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-b-sheet_${r}.xvg

    awk -v l=`awk '/legend "B-Bridge"/{print substr($2,2,1)+2}' ss_${r}.xvg` '!/^(#|@)/{print $1, (l>2?$l:0)}' ss_${r}.xvg > ss-b-bridge_${r}.xvg

    #
    # After extracting all relevant secondary structure types, we
    # can join equivalent ones into more generic categories. For
    # example, the total helicity can be regarded as the summ of
    # alpha-helix (a-helix), 3-helix and 5-helix. On the other
    # hand, the beta structures can be obtained from summing the
    # beta-sheet to the beta-bridge:
    #
    
    paste ss-*-helix_${r}.xvg | awk '{print $1, $2+$4+$6}'  > ss-helicity_${r}.xvg
    paste ss-b-*_${r}.xvg | awk '{print $1, $2+$4}'  > ss-beta-content_${r}.xvg    

    # 
    # Application of a smoothing function (sliding window average)
    # to the data files and removal of headings. The 100 points
    # window (w=100) corresponds to sliding averages of 10 ns.

    for ss in coil turn bend helicity beta-content 
    do
	awk -v w=100 '{n++;h1[n]=$2};END{for (i=1;i<=n-w+1;i++){s1=0; for (k=0;k<=w-1;k++) {s1+=h1[i+k]}; print skip+(((i+w-1)-(w/2)))/10, s1/w}}' ss-${ss}_${r}.xvg > ss-${ss}_${r}_average.xvg
    done
done

for ss in coil turn bend helicity beta-content 
do
    paste ss-${ss}_Mon_?.xvg | awk -v w=100 '{n++;h1[n]=$2+$4};END{for (i=1;i<=n-w+1;i++){s1=0; for (k=0;k<=w-1;k++) {s1+=h1[i+k]}; print skip+(((i+w-1)-(w/2)))/10, s1/w}}' > ss-${ss}_average.xvg
done

#
# Cleanup
rm -f *~ *# aux* ss-?-*.xvg ss-*A.xvg ss-*B.xvg
