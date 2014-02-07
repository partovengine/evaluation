#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'dj-bp-cdf-ES1-1.eps'

#set title "Packet delay/jitter for one simulated link with 1ms latency"

DX=0.15; DY=0.1; SX=0.4; SY=0.6
set bmargin 0; set tmargin 0; set lmargin 0; set rmargin 0
set size SX*1.25+DX*0.5,SY*2+DY*2.25

set multiplot

# The CDFs
x1=-0.035; x2=0.030; x3=2.080; x4=2.150;
y1=-0.030; y2=0.025; y3=2.085; y4=2.140;
space=SY*2+DY*0.5
factor0=space*(abs(x2-x1)/abs(x4-x3+x2-x1))
factor1=space*(abs(x4-x3)/abs(x4-x3+x2-x1))
set size SX*0.5,factor0
set origin DX*0.25,DY*1.25

unset key
set style line 1 lt 4 lc 3 lw 1
set style line 2 lt 8 lc 4 lw 1
set style line 3 lt 10 lc 2 lw 1
ejtkey=1; ejtkeyar=2; prkey=3; cijkey=4;
KEYY=0.05; KEYX=0.18; LEGENDY=0.15; LEGENDX=0.045; VERTDIFF=0.02; LENGTH=0.04
set label ejtkey "Jitter" at screen LEGENDX+1*VERTDIFF,LEGENDY rotate by 90 font ',11';
	set arrow ejtkeyar from screen LEGENDX+1*VERTDIFF,LEGENDY+0.06 to screen LEGENDX+1*VERTDIFF,LEGENDY+0.06+LENGTH nohead ls 1
set label cijkey "95%-Confidence Interval\nof Expected Jitter" at screen LEGENDX+5*VERTDIFF,LEGENDY rotate by 90 font ',8';
set label prkey "Percent (%)" at screen KEYX,KEYY rotate by 180 font ',12'
set xtics 0,0.2,1 offset character 0,-1.5 rotate by 90 nomirror font ',12'
set y2tics rotate by 90 offset 0-0.2,0-1.2 mirror font ',12'; unset ytics;
set xrange [0:1] reverse
set yrange [x1:x2]

jtsclf=11;
ARRH=0.31
set arrow jtsclf from first 0,y1 to screen ARRH,0.24 lt 3 lc 0 lw 2

set label 30 "Jitter (ms)" at screen ARRH-0.018,0.45 rotate by 90 font ',10'
set label 31 "Delay (ms)" at screen ARRH-0.018,0.98 rotate by 90 font ',10'

set border 1+2+8 front linetype -1 linewidth 1.000

plot 'sim-ES1.1-datfiles/simjcdf-ES1.1.dat' using 1:($2/1000) with lines ls 1 title "Partov Jitter", \
 'sim-ES1.1-datfiles/simdj-aci-ES1.1.dat' using (0.4):($4/1000):($5/1000):($6/1000) with yerrorbars lt 1 lc 3 lw 1 title "Partov Jitter Confidence Interval"

unset label 30; unset label 31;

set size SX*0.5,factor1-DY*0.5
set origin DX*0.25,DY*1.75+factor0
set border 2+4+8 front linetype -1 linewidth 1.000

unset xlabel; unset y2label; unset xtics;
unset label ejtkey; unset label cijkey; unset label prkey; unset arrow ejtkeyar;

set x2tics 0,0.2,1 offset character 0,1.5 nomirror
set y2tics rotate by 90 offset 0-0.2,0-0.5 mirror font ',12';
set yrange [x3:x4]

dlscls=12;
unset arrow jtsclf;
set arrow dlscls from first 0,y4 to screen ARRH,1.26 lt 3 lc 0 lw 2

zz=y2+0.0045
set arrow 100 from first 2.1, zz-0.003 to first 2.2, zz-0.001 nohead
set arrow 101 from first 2.1, zz-0.001 to first 2.2, zz+0.001 nohead
set arrow 102 from first 3.05, zz-0.003 to first 3.15, zz-0.001 nohead
set arrow 103 from first 3.05, zz-0.001 to first 3.15, zz+0.001 nohead

edlkey=5; edlkeyar=6; cidkey=7;
set label edlkey "Delay" at screen LEGENDX+1*VERTDIFF,LEGENDY+0.65 rotate by 90 font ',11';
	set arrow edlkeyar from screen LEGENDX+1*VERTDIFF,LEGENDY+0.73 to screen LEGENDX+1*VERTDIFF,LEGENDY+0.73+LENGTH nohead ls 2
set label cidkey "95%-Confidence Interval\nof Expected Delay" at screen LEGENDX+5*VERTDIFF,LEGENDY+0.65 rotate by 90 font ',8';

plot 'sim-ES1.1-datfiles/simdcdf-ES1.1.dat' using 1:($2/1000) with lines ls 2 title "Partov Delay", \
 'sim-ES1.1-datfiles/simdj-aci-ES1.1.dat' using (0.4):($1/1000):($2/1000):($3/1000) with yerrorbars lt 1 lc 4 lw 1 title "Partov Delay Confidence Interval"

set xrange [*:*]
unset arrow dlscls;
unset label edlkey; unset label cidkey; unset arrow edlkeyar;
unset y2tics; unset ytics; unset x2tics;
space=1.6;
factor2=SY*space*(abs(y4-y3)/abs(y4-y3+y2-y1))
factor3=SY*space*(abs(y2-y1)/abs(y4-y3+y2-y1))
set size SX*0.75,factor2
# Delay boxplot...
BPH=DX*0.75+SX*0.5
set origin BPH,DY*2.4+factor3+SY*0.1

set border 2 front linetype -1 linewidth 1.000
set boxwidth 0.5 absolute
set style fill solid 0.25 border lt -1
unset key
set pointsize 0.5
set style data boxplot
set style boxplot outliers
set xtics border in scale 0,0 nomirror norotate  offset character 0, 0, 0 autojustify
set xtics  norangelimit

set xtics ("" 1.0)
set ytics border in scale 1,0.5 nomirror rotate by 120 offset character 2, 0, 0 autojustify
set yrange [y3:y4]  noreverse nowriteback
set ytics y3,0.005,y4 font ',12'
plot 'sim-ES1.1-datfiles/simdbp-ES1.1.dat' using (1):($1/1000)

# Jitter boxplot...
set size SX*0.75,factor3
set origin BPH,DY*2.4

set xtics ("" 1.0) rotate by 90 offset -0.5,-5 font ',12'
set yrange [y1:y2]  noreverse nowriteback
set ytics y1,0.005,y2 font ',12'
plot 'sim-ES1.1-datfiles/simjbp-ES1.1.dat' using (1):($1/1000)

unset multiplot
