#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'cpu-ES2-1-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
#Having 4 cores, max will be 400%
YLABEL="Average CPU Utilization (%)"
set size SX+DX*1.5,SY+DY*1.5

#set title "CPU changes based on count of servers"
set xlabel "Transmission Rate (pps)"
x1=350; x2=2800;
set xrange [x1:x2]
set xtics x1,250,x2;
set ylabel YLABEL;

plot 'djcmaci-ES2.1.1.dat' using 1:8:9:10 with yerrorbars lt 1 lc 3 lw 0.1 notitle, \
 'djcmaci-ES2.1.1.dat' using 1:8 with lines lt 3 lc 3 lw 0.1 notitle

