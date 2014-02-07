#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'delay-ES2-2-1.eps'

DX=0.1; DY=0.1; SX=0.8; SY=0.8
YLABEL="Average Delay (ms)"
set bmargin 0; set tmargin 0; set lmargin 0; set rmargin 0
set size SX+DX*1.5,SY+DY*1.5

#set title "Delay changes based on count of servers"
set multiplot

set size SX,SY
# the big picture...
set origin DX,DY
set border 3
set xlabel "Count of servers"
set yrange [0<*:*]
set ylabel YLABEL offset character 1; set ytics nomirror; set xtics nomirror
# arrows connecting two plots....
set arrow 1 from first 0,0 to screen 0.22,0.3 lt 3 lc 0 lw 2
set arrow 2 from first 524,0 to screen 0.78,0.3 lt 3 lc 0 lw 2

plot 'djcmaci-ES2.2.1.dat' using 1:($2/1000):($3/1000):($4/1000) with yerrorbars lt 1 lc 3 lw 1 notitle, \
 'djcmaci-ES2.2.1.dat' using 1:($2/1000) with lines lt 3 lc 3 lw 1 notitle

unset arrow 1; unset arrow 2;
# the zoomed in version...
set size SX*0.7,SY*0.7
set origin DX*2.2,DY*3

set border 15
unset xlabel; unset ylabel
unset y2tics; set ytics; set xtics mirror
set xrange [*:524]

set label "Maximum length of\n95%-Confidence Intervals\nis less than 1ms" at screen 0.45,0.48 font ',11'

plot 'djcmaci-ES2.2.1.dat' using 1:($2/1000):($3/1000):($4/1000) with yerrorbars lt 1 lc 3 lw 1 notitle, \
 'djcmaci-ES2.2.1.dat' using 1:($2/1000) with lines lt 3 lc 3 lw 1 notitle


unset multiplot

