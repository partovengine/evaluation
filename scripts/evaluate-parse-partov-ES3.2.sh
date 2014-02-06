N=$1
t=1.960
. functions.sh
MAX_FLOWS=154
STEP=9

cd ../partovnse.git/PartovServer/deploy/bin
for((i=1;$i<=$MAX_FLOWS;i=$i+$STEP)); do
rm -f ll-flows-${i}.dat
for((round=1;$round<=$N;round=$round+1)); do
	cat ll-flows-${i}-round-${round}.loss | gawk '{ a=a+$1; b=b+$2; } END { print (a-b)/a*100; }' >> ll-flows-${i}.dat
done
done
for((i=1;$i<=$MAX_FLOWS;i=$i+$STEP)); do
	avgloss=$(calc-avg ll-flows-${i}.dat);
	lossci=$(calc-confidence-interval-endpoints ll-flows-${i}.dat $t);
	echo $avgloss $lossci
done > ll
cd ../../../../outputs/

cp ../partovnse.git/PartovServer/deploy/bin/ll .

echo "Parsing emulation results....................................."
rm -f tt-*.dat
for((round=1;$round<=$N;round=$round+1)); do
for((i=1;$i<=$MAX_FLOWS;i=$i+$STEP)); do
	parse-id-rtt emulation-multi-${i}-raw-round-${round}.txt emulation-multi-${i}-parsed-round-${round}.txt
	calc-id-rtt-statistics emulation-multi-${i}-parsed-round-${round}.txt tt-alldelays-${i}.dat tt-alljitters-${i}.dat
	calc-cpu-memory-statistics emulation-multi-${i}-cpu-memory-round-${round}.log >> tt-cm-${i}.dat
done
done
for((i=1;$i<=$MAX_FLOWS;i=$i+$STEP)); do
	echo $i $(calc-djcm-aggregate-value-and-ci tt-alldelays-${i}.dat tt-alljitters-${i}.dat tt-cm-${i}.dat $t)
done > tt
#16 columns
paste tt ll > edjcmlaci-ES3.2.dat

