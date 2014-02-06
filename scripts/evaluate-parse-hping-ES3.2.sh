
N=$1
t=1.960
. functions.sh
MAX_FLOWS=154
STEP=9

cd ../outputs/

echo "Parsing hping3 results........................................"
rm -f ss-*.dat
for((round=1;$round<=$N;round=$round+1)); do
for((n=1;$n<=$MAX_FLOWS;n=$n+$STEP)); do
	echo -n > hping3-multi-${n}-allflows-delay-round-${round}.dat
	echo -n > hping3-multi-${n}-allflows-jitter-round-${round}.dat
	echo -n > ss-${n}-round-${round}.dat
	for((i=0;$i<$n;i=$i+1)); do
		hp-parse-rtt hping3-multi-${n}-flow-${i}-raw-round-${round}.txt hping3-multi-${n}-flow-${i}-parsed-round-${round}.txt
		cat hping3-multi-${n}-flow-${i}-parsed-round-${round}.txt >> hping3-multi-${n}-allflows-delay-round-${round}.dat

		calc-jitter hping3-multi-${n}-flow-${i}-parsed-round-${round}.txt hping3-multi-${n}-flow-${i}-jitter-round-${round}.dat
		jj=$(calc-jitter-moving-average hping3-multi-${n}-flow-${i}-jitter-round-${round}.dat)
		echo $jj >> hping3-multi-${n}-allflows-jitter-round-${round}.dat
		cat hping3-multi-${n}-flow-${i}-raw-round-${round}.txt | grep received, | gawk '{ print $1, $4 }' >> ss-${n}-round-${round}.dat
	done
	calc-cpu-memory-statistics hping3-multi-${n}-cpu-memory-round-${round}.log >> ss-cm-${n}.dat
	loss=$(cat ss-${n}-round-${round}.dat | gawk -v n=$n '{ b=b+$2; } END { a=60*n; print (a-b)/a*100; }');
	cat hping3-multi-${n}-allflows-delay-round-${round}.dat >> ss-alldelays-${n}.dat
	cat hping3-multi-${n}-allflows-jitter-round-${round}.dat >> ss-alljitters-${n}.dat
	echo "$loss" >> ss-loss-${n}.dat;
done
done
for((n=1;$n<=$MAX_FLOWS;n=$n+$STEP)); do
	djcmtwelvecolumns=$(calc-djcm-aggregate-value-and-ci ss-alldelays-${n}.dat ss-alljitters-${n}.dat ss-cm-${n}.dat $t)
	avgloss=$(calc-avg ss-loss-${n}.dat);
	lossci=$(calc-confidence-interval-endpoints ss-loss-${n}.dat $t)
	# 16 columns
	echo $n $djcmtwelvecolumns $avgloss $lossci
done > hdjcmlaci-ES3.2.dat

