#! /bin/bash
Dir=`pwd`

# Gnuplot is a command-line utility program for data visualization and generate graphics. 
# This script will generate a .gp file with several inscrutions for example:
#  -Border settings;  -Axis manipulation (range and tics); 
#  -File type;        -Size, color and type of data representation (lines, points, etc.)
#  -Data selection by column; -Font type and size:
#  -Labels and keys;  -Multiplot and more advanced type of graphical plots.

file=RMSD

cat <<EOF > $file.gp

set term postscript enhanced color solid "Helvetica" 20 
set encoding iso_8859_1
set border 31 lt -1 lw 2
set output "$file.eps"
set rmargin 0
set tmargin 0
set lmargin 3.3
set bmargin 1.5

set xlabel "Time (ns)"
set xrange [0:]
set xtics 0,20 nomirror
set mxtics 2

set ylabel "RMSD (nm)"
set yrange [0:]
set ytics 0,0.2 nomirror
set mytics 2

set key top horizontal right maxcols 2 font ",22"

plot \
     "rms-MonA_CA_average.xvg"  u 1:2 w l lt 1 lw 8 lc rgb "#6495ED" title "MonA", \
     "rms-MonB_CA_average.xvg"  u 1:2 w l lt 1 lw 8 lc rgb "#996600" title "MonB", \
     "rms-MPro_CA_average.xvg"  u 1:2 w l lt 1 lw 8 title "M^{Pro}", \
     "rms-MonA_13b_average.xvg" u 1:2 w l lt 1 lw 8 lc rgb "#0000FF" title "LigA", \
     "rms-MonB_13b_average.xvg" u 1:2 w l lt 1 lw 8 lc rgb "#FF0000" title "LigB", \

EOF

# After generating the .gp file, we run the program gnuplot by giving the file as input.
# If no error is reported, a ".eps" should be in your folder and it will be converted to a .pdf file. 
gnuplot $file.gp
ps2pdf $file.eps
# cleanup
rm -f $file.{gp,eps}

