#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'jitter-ES2-2-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
YLABEL="Average Jitter (ms)"
set size SX+DX*1.5,SY+DY*1.5

#set title "Jitter changes based on count of servers"

# the big picture...
set xlabel "Count of servers"
set border 1+2+4+8 lw 1
set yrange [0<*:*]
set ylabel YLABEL offset character 1;

plot 'djcmaci-ES2.2.1.dat' using 1:($5/1000):($6/1000):($7/1000) with yerrorbars lt 1 lc 1 lw 1 notitle, \
 'djcmaci-ES2.2.1.dat' using 1:($5/1000) with lines lt 3 lc 1 lw 1 notitle

