#!/usr/bin/gnuplot
set term postscript eps enhanced color
set output 'dj-bp-cdf-ES3-1.eps'

#set title "Packet delay/jitter boxplot for one flow"

DX=0.15; DY=0.1; SX=0.4; SY=0.6
set bmargin 0; set tmargin 0; set lmargin 0; set rmargin 0
set size SX*1.25+DX*0.5,SY*2+DY*2.25

set multiplot

# The CDFs
x1=-15.0; x2=15.0; x3=340.0; x4=400.0;
y1=-13.0; y2=11.0; y3=340.0; y4=400.0;
space=SY*2+DY*0.5
factor0=space*(abs(x2-x1)/abs(x4-x3+x2-x1))
factor1=space*(abs(x4-x3)/abs(x4-x3+x2-x1))
set size SX*0.5,factor0
set origin DX*0.25,DY*1.25

unset key
set style line 1 lt 4 lc 3 lw 1
set style line 2 lt 8 lc 4 lw 1
set style line 3 lt 10 lc 2 lw 1
edlkey=1; ejtkey=2; edlkeyar=3; ejtkeyar=4; prkey=5; djkey=6;
hdlkey=7; hjtkey=8; hdlkeyar=9; hjtkeyar=10;
ndlkey=15; njtkey=16; ndlkeyar = 17; njtkeyar = 18; cijkey = 19; cidkey = 20;
KEYY=0.05; KEYX=0.18; LEGENDY=0.15; LEGENDX=0.045; VERTDIFF=0.02; LENGTH=0.04
set label ejtkey "Partov Jitter" at screen LEGENDX+1*VERTDIFF,LEGENDY rotate by 90 font ',11';
	set arrow ejtkeyar from screen LEGENDX+1*VERTDIFF,LEGENDY+0.14 to screen LEGENDX+1*VERTDIFF,LEGENDY+0.14+LENGTH nohead ls 1
set label hjtkey "Hping3 Jitter" at screen LEGENDX+2*VERTDIFF,LEGENDY rotate by 90 font ',11';
	set arrow hjtkeyar from screen LEGENDX+2*VERTDIFF,LEGENDY+0.14 to screen LEGENDX+2*VERTDIFF,LEGENDY+0.14+LENGTH nohead ls 2
set label njtkey "NS-3 Jitter" at screen LEGENDX+3*VERTDIFF,LEGENDY rotate by 90 font ',11';
	set arrow njtkeyar from screen LEGENDX+3*VERTDIFF,LEGENDY+0.14 to screen LEGENDX+3*VERTDIFF,LEGENDY+0.14+LENGTH nohead ls 3
set label cijkey "95%-Confidence Interval\nof Expected Jitter" at screen LEGENDX+5*VERTDIFF,LEGENDY rotate by 90 font ',8';
set label prkey "Percent (%)" at screen KEYX,KEYY rotate by 180 font ',12'
#set label djkey "Jitter/Delay (ms)" at screen SX*0.67,0.7 rotate by 90 font ',12'
set xtics 0,0.2,1 offset character 0,-1.5 rotate by 90 nomirror font ',12'
set y2tics rotate by 90 offset 0-0.2,-0.2 font ',12'; set ytics offset -10
set xrange [0:1] reverse
#set yrange [*:*]
set yrange [x1:x2]

jtsclf=11; jtscls=12
dlsclf=13; dlscls=14
ARRH=0.31
set arrow jtsclf from first 0,y1 to screen ARRH,0.24 lt 3 lc 0 lw 2

set label 30 "Jitter (ms)" at screen ARRH-0.025,0.35 rotate by 90 font ',10'
set label 31 "Delay (ms)" at screen ARRH-0.025,0.85 rotate by 90 font ',10'

#red 1 1
#green 2 2
#blue dark 3 3
#magnet 4 4
#blue light 5 5
#magnet dark 7 7
set border 1+2+8 front linetype -1 linewidth 1.000

plot 'enhs-ES3.1-datfiles/esjcdf-ES3.1.dat' using 1:($2/1000) with lines ls 1 title "Partov Jitter", \
 'enhs-ES3.1-datfiles/ehpns3-sdjaci-ES3.1.dat' using (0.4):($4/1000):($5/1000):($6/1000) with yerrorbars lt 2 lc 3 lw 1 title "Partov Jitter Confidence Interval", \
 'enhs-ES3.1-datfiles/hsjcdf-ES3.1.dat' using 1:2 with lines ls 2 title "Hping3 Jitter", \
 'enhs-ES3.1-datfiles/ehpns3-sdjaci-ES3.1.dat' using (0.3):($10):($11):($12) with yerrorbars lt 3 lc 4 lw 1 title "Hping3 Jitter Confidence Interval", \
 'enhs-ES3.1-datfiles/ns3sjcdf-ES3.1.dat' using 1:($2/1000000) with lines ls 3 title "NS-3 Jitter", \
 'enhs-ES3.1-datfiles/ehpns3-sdjaci-ES3.1.dat' using (0.2):($16/1000000):($17/1000000):($18/1000000) with yerrorbars lt 4 lc 2 lw 1 title "NS-3 Jitter Confidence Interval"

set size SX*0.5,factor1-DY*0.5
set origin DX*0.25,DY*1.75+factor0
set border 2+4+8 front linetype -1 linewidth 1.000

unset xlabel; unset y2label; unset xtics;
unset label ejtkey; unset label hjtkey; unset label njtkey; unset label cijkey;
unset label prkey;

set x2tics 0,0.2,1 offset character 0,1.5 nomirror
set yrange [x3:x4]

unset arrow jtsclf;
#set arrow dlsclf from first 0,0 to first ARRH,0.4 lt 3 lc 0 lw 2
set arrow dlscls from first 0,y4 to screen ARRH,1.26 lt 3 lc 0 lw 2

zz=y2+5.5
set arrow 100 from first 6.8, zz-0.7 to first 7.0, zz+0.3 nohead
set arrow 101 from first 6.8, zz-1.5 to first 7.0, zz-0.5 nohead
set arrow 102 from first 4.6, zz-0.7 to first 4.8, zz+0.3 nohead
set arrow 103 from first 4.6, zz-1.5 to first 4.8, zz-0.5 nohead

set label edlkey "Partov Delay" at screen LEGENDX+1*VERTDIFF,LEGENDY+0.45 rotate by 90 font ',11';
	set arrow edlkeyar from screen LEGENDX+1*VERTDIFF,LEGENDY+0.6 to screen LEGENDX+1*VERTDIFF,LEGENDY+0.6+LENGTH nohead ls 1
set label hdlkey "Hping3 Delay" at screen LEGENDX+2*VERTDIFF,LEGENDY+0.45 rotate by 90 font ',11';
	set arrow hdlkeyar from screen LEGENDX+2*VERTDIFF,LEGENDY+0.6 to screen LEGENDX+2*VERTDIFF,LEGENDY+0.6+LENGTH nohead ls 2
set label ndlkey "NS-3 Delay" at screen LEGENDX+3*VERTDIFF,LEGENDY+0.45 rotate by 90 font ',11';
	set arrow ndlkeyar from screen LEGENDX+3*VERTDIFF,LEGENDY+0.6 to screen LEGENDX+3*VERTDIFF,LEGENDY+0.6+LENGTH nohead ls 3
set label cidkey "95%-Confidence Interval\nof Expected Delay" at screen LEGENDX+5*VERTDIFF,LEGENDY+0.45 rotate by 90 font ',8';

unset label 30; unset label 31;

plot 'enhs-ES3.1-datfiles/esdcdf-ES3.1.dat' using 1:($2/1000) with lines ls 1 title "Partov Delay", \
 'enhs-ES3.1-datfiles/ehpns3-sdjaci-ES3.1.dat' using (0.4):($1/1000):($2/1000):($3/1000) with yerrorbars lt 2 lc 3 lw 1 title "Partov Delay Confidence Interval", \
 'enhs-ES3.1-datfiles/hsdcdf-ES3.1.dat' using 1:2 with lines ls 2 title "Hping3 Delay", \
 'enhs-ES3.1-datfiles/ehpns3-sdjaci-ES3.1.dat' using (0.3):($7):($8):($9) with yerrorbars lt 3 lc 4 lw 1 title "Hping3 Delay Confidence Interval", \
 'enhs-ES3.1-datfiles/ns3sdcdf-ES3.1.dat' using 1:($2/1000000) with lines ls 3 title "NS-3 Delay", \
 'enhs-ES3.1-datfiles/ehpns3-sdjaci-ES3.1.dat' using (0.2):($13/1000000):($14/1000000):($15/1000000) with yerrorbars lt 4 lc 2 lw 1 title "NS-3 Delay Confidence Interval"

set xrange [*:*]
#unset arrow jtscls;
#unset arrow dlsclf;
unset arrow dlscls;
unset label edlkey; unset label hdlkey; unset label ndlkey; unset label cidkey;
unset arrow edlkeyar; unset arrow ejtkeyar;
unset arrow hdlkeyar; unset arrow hjtkeyar;
unset arrow ndlkeyar; unset arrow njtkeyar;
unset label prkey;
#unset label djkey;
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

set xtics ("" 1.0, "" 2.0, "" 3.0)
set ytics border in scale 1,0.5 nomirror rotate by 120 offset character 2, 0, 0 autojustify
set yrange [y3:y4]  noreverse nowriteback
set ytics y3,10,y4 font ',12'
plot 'enhs-ES3.1-datfiles/esdbp-ES3.1.dat' using (3):($1/1000), \
  'enhs-ES3.1-datfiles/hsdbp-ES3.1.dat' using (2):1, \
  'enhs-ES3.1-datfiles/ns3sdbp-ES3.1.dat' using (1):($1/1000000)

# Jitter boxplot...
set size SX*0.75,factor3
set origin BPH,DY*2.4

set xtics ("NS-3" 1.0, "Hping3" 2.0, "Partov" 3.0) rotate by 90 offset -0.5,-5 font ',12'
set yrange [y1:y2]  noreverse nowriteback
set ytics y1,3,y2 font ',12'
plot 'enhs-ES3.1-datfiles/esjbp-ES3.1.dat' using (3):($1/1000), \
  'enhs-ES3.1-datfiles/hsjbp-ES3.1.dat' using (2):1, \
  'enhs-ES3.1-datfiles/ns3sjbp-ES3.1.dat' using (1):($1/1000000)

unset multiplot
