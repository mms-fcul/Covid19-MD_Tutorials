#! /bin/bash
Dir=`pwd`

# Gnuplot is a command-line utility program for data visualization and generate graphics. 
# This script will generate a .gp file with several inscrutions for example:
#  -Border settings;  -Axis manipulation (range and tics); 
#  -File type;        -Size, color and type of data representation (lines, points, etc.)
#  -Data selection by column; -Font type and size:
#  -Labels and keys;  -Multiplot and more advanced type of graphical plots.

file=DSSP

cat <<EOF > $file.gp

set term postscript enhanced color solid "Helvetica" 20
set encoding iso_8859_1
set border 31 lt -1 lw 2
set output "$file.eps"
set rmargin 0
set tmargin 0
set lmargin 3.7
set bmargin 1.5

set xlabel "Time (ns)"
set xrange [0:]
set xtics 0,20 nomirror
set mxtics 2

set ylabel "N{\260} of Residues"
set yrange [150:172]
set ytics 0,5 nomirror
set mytics 5

set key top horizontal right maxcols 2 font ",22"

plot \
     "ss-helicity_average.xvg" u 1:2 w l lt 3 lw 8 title "helicity", \
     "ss-beta-content_average.xvg" u 1:2 w l lt 4 lw 8 title "beta-sheet", \

EOF

# After generating the .gp file, we run the program gnuplot by giving the file as input.
# If no error is reported, a ".eps" should be in your folder and it will be converted to a .pdf file. 
gnuplot $file.gp
ps2pdf $file.eps
# cleanup
rm -f $file.{gp,eps}

