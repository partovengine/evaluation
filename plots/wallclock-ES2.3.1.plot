#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'wallclock-ES2-3-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
#Having 4 cores, max will be 400%
YLABEL="Average Elapsed Wall Clock (s)"
set size SX+DX*1.5,SY+DY*1.5

#set title "Wall clock changes based on count of servers"
set xlabel "Count of servers"
set ylabel YLABEL offset character 1;
set xtics 0,50,650

plot 'djwmaci-ES2.3.1.dat' using 1:8:9:10 with yerrorbars lt 1 lc 3 lw 1 notitle, \
 'djwmaci-ES2.3.1.dat' using 1:8 with lines lt 3 lc 3 lw 1 notitle

