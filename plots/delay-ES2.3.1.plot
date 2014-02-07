#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'delay-ES2-3-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
set bmargin 0; set tmargin 0; set lmargin 0; set rmargin 0
YLABEL="Percent of Packets Sharing a Common RTT (%)"
set size SX+DX*1.5,SY+DY*1.75

set multiplot


y1=0; y2=0.18; y3=99.8; y4=99.85;
space=SY
factor0=space*(abs(y2-y1)/abs(y4-y3+y2-y1))
factor1=space*(abs(y4-y3)/abs(y4-y3+y2-y1))
set size SX,factor1
set origin DX,DY*1.5+factor0
set border 2+4+8
#set title "Delay changes based on count of servers"
unset xtics; set x2tics offset character 0,10;

set yrange [y3:y4]
set ytics y3,0.02,y4 offset character 0,0;

plot 'dcdf-ES2.3.1.dat' using 1:($2 * 100) with linespoints lt 1 title "10 ms delay"

set size SX,factor0
set origin DX,DY
set border 1+2+8
set xtics nomirror; unset x2tics;
set yrange [y1:y2]
set ytics y1,0.02,y2 offset character 0,-0.5;

set ylabel YLABEL offset character 1,4;
set xlabel "Count of servers"

set xrange [0:610]

xl=0.1; xr=0.9; xdiff=0.012; yy=0.75; ydiff=0.02
set arrow 100 from screen xl-xdiff*2, yy-ydiff to screen xl+xdiff*1, yy+ydiff nohead lw 0.5
set arrow 101 from screen xl-xdiff*1, yy-ydiff to screen xl+xdiff*2, yy+ydiff nohead lw 0.5
set arrow 102 from screen xr-xdiff*2, yy-ydiff to screen xr+xdiff*1, yy+ydiff nohead lw 0.5
set arrow 103 from screen xr-xdiff*1, yy-ydiff to screen xr+xdiff*2, yy+ydiff nohead lw 0.5


plot 'dcdf-ES2.3.1.dat' using 1:(($4 - $2) * 100) with linespoints lt 11 title "12 ms delay", \
 'dcdf-ES2.3.1.dat' using 1:(($6 - $4) * 100) with linespoints lt 13 title "14 ms delay", \
 'dcdf-ES2.3.1.dat' using 1:(($8 - $6) * 100) with linespoints lt 12 title "16 ms delay", \
 'dcdf-ES2.3.1.dat' using 1:(($10 - $8) * 100) with linespoints lt 10 title "20 ms delay"

unset multiplot

