#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'delay-ES3-2.eps'

#set title "Delay changes based on count of emulated maps / hping3 processes"
set xlabel "Count of concurrent flows"
set ylabel "Average Delay (s)"

#set yrange [0:15]
set key right

plot 'enhs-ES3.2-datfiles/edjcmlaci-ES3.2.dat' using 1:($2/1000000):($3/1000000):($4/1000000) with yerrorbars lt 4 lc 3 lw 3 title "Partov", \
 'enhs-ES3.2-datfiles/edjcmlaci-ES3.2.dat' using 1:($2/1000000) with lines lt 2 lc 3 lw 3 notitle, \
 'enhs-ES3.2-datfiles/hdjcmlaci-ES3.2.dat' using 1:($2/1000):($3/1000):($4/1000) with yerrorbars lt 8 lc 4 lw 3 title "Hping3", \
 'enhs-ES3.2-datfiles/hdjcmlaci-ES3.2.dat' using 1:($2/1000) with lines lt 3 lc 4 lw 3 notitle, \
 'enhs-ES3.2-datfiles/ns3djcmlaci-ES3.2.dat' using 1:($2/1000000000):($3/1000000000):($4/1000000000) with yerrorbars lt 10 lc 2 lw 3 title "NS-3", \
 'enhs-ES3.2-datfiles/ns3djcmlaci-ES3.2.dat' using 1:($2/1000000000) with lines lt 4 lc 2 lw 3 notitle

