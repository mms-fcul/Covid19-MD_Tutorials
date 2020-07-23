#! /bin/bash
Dir=`pwd`

# Gnuplot is a command-line utility program for data visualization and generate graphics. 
# This script will generate a .gp file with several inscrutions for example:
#  -Border settings;  -Axis manipulation (range and tics); 
#  -File type;        -Size, color and type of data representation (lines, points, etc.)
#  -Data selection by column; -Font type and size:
#  -Labels and keys;  -Multiplot and more advanced type of graphical plots.

file=Gyration

cat <<EOF > $file.gp

set term postscript enhanced color solid "Helvetica" 20
set encoding iso_8859_1
set border 31 lt -1 lw 2
set output "$file.eps"
set rmargin 0
set tmargin 0
set lmargin 4.5
set bmargin 1.5

set xlabel "Time (ns)"
set xrange [0:]
set xtics 0,20 nomirror
set mxtics 2

set ylabel "R_{g} (nm)"
set yrange [2.576:2.60]
set ytics 0,0.01 nomirror
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot \
     "gyration_MPro_average.xvg"  u 1:2 w l lt 1 lw 8 title "M^{Pro}", \
     "gyration_MPro-and-Ligands_average.xvg" u 1:2 w l lt 2 lw 8 title "M^{Pro}+Ligands", \

EOF

# After generating the .gp file, we run the program gnuplot by giving the file as input.
# If no error is reported, a ".eps" should be in your folder and it will be converted to a .pdf file. 
gnuplot $file.gp
ps2pdf $file.eps
# cleanup
rm -f $file.{gp,eps}

