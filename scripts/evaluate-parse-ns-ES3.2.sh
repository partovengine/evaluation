N=$1
t=1.960
. functions.sh
NS_MAX_FLOWS=35
NS_STEP=8

cd ../outputs/

echo "Parsing ns3 results..........................................."
rm -f nn-*.dat
for((round=1;$round<=$N;round=$round+1)); do
for((n=1;$n<$NS_MAX_FLOWS;n=$n+$NS_STEP)); do
	echo -n > ns3-multi-${n}-allflows-delay-round-${round}.dat
	echo -n > ns3-multi-${n}-allflows-jitter-round-${round}.dat
	echo -n > nn-${n}-round-${round}.dat
	for((i=0;$i<$n;i=$i+1)); do
		nsthree-parse-rtt ns3-multi-${n}-flow-${i}-raw-round-${round}.txt ns3-multi-${n}-flow-${i}-parsed-round-${round}.txt
		cat ns3-multi-${n}-flow-${i}-parsed-round-${round}.txt >> ns3-multi-${n}-allflows-delay-round-${round}.dat

		calc-jitter ns3-multi-${n}-flow-${i}-parsed-round-${round}.txt ns3-multi-${n}-flow-${i}-jitter-round-${round}.dat
		jj=$(calc-jitter-moving-average ns3-multi-${n}-flow-${i}-jitter-round-${round}.dat)
		echo $jj >> ns3-multi-${n}-allflows-jitter-round-${round}.dat

		cat ns3-multi-${n}-flow-${i}-raw-round-${round}.txt | grep Received | wc -l >> nn-${n}-round-${round}.dat
	done
	calc-cpu-memory-statistics ns3-multi-${n}-cpu-memory-round-${round}.log >> nn-cm-${n}.dat
	loss=$(cat nn-${n}-round-${round}.dat | gawk -v n=$n '{ b=b+$1; } END { a=60*n; print (a-b)/a*100; }');
	cat ns3-multi-${n}-allflows-delay-round-${round}.dat >> nn-alldelays-${n}.dat
	cat ns3-multi-${n}-allflows-jitter-round-${round}.dat >> nn-alljitters-${n}.dat
	echo "$loss" >> nn-loss-${n}.dat;
done
n=$NS_MAX_FLOWS
echo -n > ns3-multi-${n}-allflows-delay-round-${round}.dat
echo -n > ns3-multi-${n}-allflows-jitter-round-${round}.dat
echo -n > nn-${n}-round-${round}.dat
for((i=0;$i<$n;i=$i+1)); do
	nsthree-parse-rtt ns3-multi-${n}-flow-${i}-raw-round-${round}.txt ns3-multi-${n}-flow-${i}-parsed-round-${round}.txt
	cat ns3-multi-${n}-flow-${i}-parsed-round-${round}.txt >> ns3-multi-${n}-allflows-delay-round-${round}.dat

	calc-jitter ns3-multi-${n}-flow-${i}-parsed-round-${round}.txt ns3-multi-${n}-flow-${i}-jitter-round-${round}.dat
	jj=$(calc-jitter-moving-average ns3-multi-${n}-flow-${i}-jitter-round-${round}.dat)
	echo $jj >> ns3-multi-${n}-allflows-jitter-round-${round}.dat

	cat ns3-multi-${n}-flow-${i}-raw-round-${round}.txt | grep Received | wc -l >> nn-${n}-round-${round}.dat
done
calc-cpu-memory-statistics ns3-multi-${n}-cpu-memory-round-${round}.log >> nn-cm-${n}.dat
loss=$(cat nn-${n}-round-${round}.dat | gawk -v n=$n '{ b=b+$1; } END { a=60*n; print (a-b)/a*100; }');
cat ns3-multi-${n}-allflows-delay-round-${round}.dat >> nn-alldelays-${n}.dat
cat ns3-multi-${n}-allflows-jitter-round-${round}.dat >> nn-alljitters-${n}.dat
echo "$loss" >> nn-loss-${n}.dat;
done
for((n=1;$n<$NS_MAX_FLOWS;n=$n+$NS_STEP)); do
	djcmtwelvecolumns=$(calc-djcm-aggregate-value-and-ci nn-alldelays-${n}.dat nn-alljitters-${n}.dat nn-cm-${n}.dat $t)
	avgloss=$(calc-avg nn-loss-${n}.dat);
	lossci=$(calc-confidence-interval-endpoints nn-loss-${n}.dat $t)

	# 16 columns
	echo $n $djcmtwelvecolumns $avgloss $lossci
done > ns3djcmlaci-ES3.2.dat
n=$NS_MAX_FLOWS
djcmtwelvecolumns=$(calc-djcm-aggregate-value-and-ci nn-alldelays-${n}.dat nn-alljitters-${n}.dat nn-cm-${n}.dat $t)
avgloss=$(calc-avg nn-loss-${n}.dat);
lossci=$(calc-confidence-interval-endpoints nn-loss-${n}.dat $t)

# 16 columns
echo $n $djcmtwelvecolumns $avgloss $lossci >> ns3djcmlaci-ES3.2.dat

