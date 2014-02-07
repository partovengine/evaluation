#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'delay-ES2-1-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
YLABEL="Average Delay (ms)"
set size SX+DX*1.5,SY+DY*1.5

#set title "Delay changes based on count of servers"
set xlabel "Transmission Rate (pps)"
x1=350; x2=2800;
set xrange [x1:x2]
set xtics x1,250,x2; set xtics add ("\n2500" 2500)
set ylabel YLABEL offset character 1;
set label "Maximum length of\n95%-Confidence Intervals\nis less than 0.05ms" at screen 0.11,0.22 font ',11'
set label "Congestion Point" at screen 0.7,0.18 font ',11'
set arrow from first 2500,11.855 to screen 0.78,0.16 lt 3 lc 0 lw 1

plot 'djcmaci-ES2.1.1.dat' using 1:($2/1000):($3/1000):($4/1000) with yerrorbars lt 1 lc 3 lw 1 notitle, \
 'djcmaci-ES2.1.1.dat' using 1:($2/1000) with lines lt 3 lc 3 lw 1 title "Average Measured End-to-End Delay", \
 'djcmaci-ES2.1.1.dat' using 1:14 with linespoints lt 1 title "Maximum Analytical Tolerable Delay Before Congestion Point"

