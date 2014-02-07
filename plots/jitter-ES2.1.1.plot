#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'jitter-ES2-1-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
YLABEL="Average Jitter (ms)"
set size SX+DX*1.5,SY+DY*1.5

#set title "Jitter changes based on count of servers"
set xlabel "Transmission Rate (pps)"
x1=350; x2=2800;
set xrange [x1:x2]
set xtics x1,250,x2;
set ylabel YLABEL;

plot 'djcmaci-ES2.1.1.dat' using 1:($5/1000):($6/1000):($7/1000) with yerrorbars lt 1 lc 1 lw 3 notitle, \
 'djcmaci-ES2.1.1.dat' using 1:($5/1000) with lines lt 3 lc 1 lw 3 notitle

