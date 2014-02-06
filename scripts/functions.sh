function sqrt { echo "scale=9; sqrt($1)" | bc; }
function pure-max { cat $1 | gawk 'BEGIN{n=-10000000000000000} {l = l + 1; if (n < $1) {n = $1; line = l} } END { print n } '; }
function max { cat $1 | gawk 'BEGIN{n=-10000000000000000} {l = l + 1; if (n < $1) {n = $1; line = l} } END { print "MAX:",n,"at line",line } '; }
function min { cat $1 | gawk 'BEGIN{n=+10000000000000000} {l = l + 1; if (n > $1) {n = $1; line = l} } END { print "MIN:",n,"at line",line } '; }
function parse-rtt { cat $1 | grep microseconds | gawk -F'rtt = ' '{ print $2 }' | cut -f1 -d\   > $2; }
function parse-id-rtt { cat $1 | grep microseconds | gawk -F'=' '{ print $2,$4 }' | gawk '{ print $1,$3 }' > $2; }
function parse-wall-clock { cat $1 | grep 'Elapsed Wall Clock' | gawk '{ print $6 }'; }
function calc-jitter { cat $1 | gawk '{ last = $1; if (first > 0) {jitter = last - first; printf ("%f\n", jitter); }; first = last;}' > $2; }
function calc-cdf {
	local src=$1;
	local tempfile=/tmp/calc-cdf-$src;
	cat $src | sort --numeric-sort | gawk '{ last = $1; n = n + 1; if (n > 1) {if (first != last) {print n-1, first;}}; first = last; } END { print n, first; }' > $tempfile;
	local samplecount=$(tail $tempfile -n1 | cut -d\  -f1);
	cat $tempfile | gawk -v samplecount=$samplecount '{ percent = $1 / samplecount; printf ("%f %f\n", percent, $2); }' > $2
}
function remove-outlier { let "number=$2+1"; tail $1 -n +$number > $3; }
function hp-parse-rtt { cat $1 | grep rtt= | gawk -F'rtt=' '{ print $2 }' | cut -f1 -d\   > $2; }
function nsthree-parse-rtt { cat $1 | grep RTT\ =\ \+ | gawk -F'RTT = \\+' '{ print $2 }' | cut -dn -f1 > $2; }
function calc-avg {
	local summingstr=$(cat $1 | gawk '{ print $1,"+" }' | sed -n '1h;1!H;${g; s/\n/\ /g; p}');
	local countofitems=$(wc -l $1 | cut -d\  -f1);
	local avg=$(echo "scale=9; ($summingstr 0) / $countofitems" | bc);
	echo $avg
}
function calc-var { cat $1 | gawk -v avg=$2 '{ x = $1; sum = sum + x * x; n = n + 1; } END { if (n>1) {var = (sum - n*avg*avg)/(n-1);} else {var=0;}; printf ("%f", var); }'; }
function calc-jitter-moving-average { cat $1 | gawk '{ j = $1; if (j < 0) {j = -j;}; res = res*15/16 + j/16 } END { printf ("%f", res); }'; }
function calc-id-rtt-statistics {
	local src=$1;
	local alldelaysfile=$2
	local alljittersfile=$3
	local maxid=$(pure-max $src);
	local baseaddr=/tmp/calc-id-rtt-cdf/$src
	mkdir -p $baseaddr
	cat $src | gawk '{ print $2 }' > $baseaddr/delay.dat
	cat $baseaddr/delay.dat >> $alldelaysfile
	echo -n > $baseaddr/jitter.dat
	local i;
	for((i=0;$i<=$maxid;i=$i+1));
	do
		local file=$baseaddr/f$i;
		cat $src | grep "^$i " | gawk '{ print $2 }' > $file;
		calc-jitter $file $file.jitter
		local jj=$(calc-jitter-moving-average $file.jitter)
		echo $jj >> $baseaddr/jitter.dat
	done
	cat $baseaddr/jitter.dat >> $alljittersfile
}
function calc-confidence-interval-endpoints {
	local datafile=$1
	local t=$2
	local size=$(wc -l $datafile | cut -d\  -f1);
	local sqrtN=$(sqrt $size);
	local ybar=$(calc-avg $datafile);
	local sntwo=$(calc-var $datafile $ybar);
	local sn=$(sqrt $sntwo);
	# [Y-bar - t.S_N/sqrt(N), Y-bar + t.S_N/sqrt(N)]
	local leftpoint=$(echo "scale=9; $ybar - $t * $sn / $sqrtN" | bc)
	local rightpoint=$(echo "scale=9; $ybar + $t * $sn / $sqrtN" | bc)
	echo "$leftpoint $rightpoint"
}
function calc-cpu-memory-statistics {
	local avgcpu=$(cat $1 | cut -d% -f1)
	local maxmemory=$(cat $1 | cut -d\  -f2)
	echo "$avgcpu $maxmemory"
}
function calc-djcm-aggregate-value-and-ci {
	local delays=$1
	local jitters=$2
	local cpumemfile=$3
	local t=$4
	local avgdelay=$(calc-avg $delays);
	local delayconfint=$(calc-confidence-interval-endpoints $delays $t);
	local avgjitter=$(calc-avg $jitters);
	local jitterconfint=$(calc-confidence-interval-endpoints $jitters $t)
	cat $cpumemfile | gawk '{ print $1 }' > cpu.temp
	local avgcpu=$(calc-avg cpu.temp);
	local cpuconfint=$(calc-confidence-interval-endpoints cpu.temp $t)
	cat $cpumemfile | gawk '{ print $2 }' > memory.temp
	local avgmaxmemory=$(calc-avg memory.temp);
	local memoryconfint=$(calc-confidence-interval-endpoints memory.temp $t)
	# 12 columns output
	echo "$avgdelay $delayconfint $avgjitter $jitterconfint $avgcpu $cpuconfint $avgmaxmemory $memoryconfint"
}
function calc-djwm-aggregate-value-and-ci {
	local delays=$1
	local jitters=$2
	local wallclockmemfile=$3
	local t=$4
	local avgdelay=$(calc-avg $delays);
	local delayconfint=$(calc-confidence-interval-endpoints $delays $t);
	local avgjitter=$(calc-avg $jitters);
	local jitterconfint=$(calc-confidence-interval-endpoints $jitters $t);
	cat $wallclockmemfile | gawk '{ print $1 }' > wallclock.temp
	local avgewck=$(calc-avg wallclock.temp);
	local ewckconfint=$(calc-confidence-interval-endpoints wallclock.temp $t);
	cat $wallclockmemfile | gawk '{ print $2 }' > memory.temp
	local avgmaxmemory=$(calc-avg memory.temp);
	local memoryconfint=$(calc-confidence-interval-endpoints memory.temp $t);
	# 12 columns output
	echo "$avgdelay $delayconfint $avgjitter $jitterconfint $avgewck $ewckconfint $avgmaxmemory $memoryconfint"
}

