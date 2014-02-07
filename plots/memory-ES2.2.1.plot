#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'memory-ES2-2-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
YLABEL="Maximum  Resident Set Size (MB)"
set size SX+DX*1.5,SY+DY*1.5

#set title "Memory usage changes based on count of servers"

set xlabel "Count of servers"
set yrange [0<*:*]
set ylabel YLABEL offset character 1; set ytics nomirror; set xtics nomirror

plot 'djcmaci-ES2.2.1.dat' using 1:($11/1024):($12/1024):($13/1024) with yerrorbars lt 1 lc 8 lw 1 notitle, \
 'djcmaci-ES2.2.1.dat' using 1:($11/1024) with lines lt 3 lc 8 lw 1 notitle


