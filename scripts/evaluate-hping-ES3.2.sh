startinground=$1
N=4
. functions.sh
MAX_FLOWS=154
STEP=9

cd ../outputs/
echo 'n=$1; i=$2; round=$3;' > run-hping.temp
echo 'hping3 -c 60 -i 1 -d 1024 -1 4.2.2.4 > hping3-multi-$n-flow-$i-raw-round-${round}.txt 2>&1 || true;' >> run-hping.temp
chmod +x run-hping.temp
function hping_multi_instances {
	local n=$1
	local round=$2
	local i;
	for((i=0;$i<$n;i=$i+1)); do
		echo "/usr/bin/time --format=\"%M\" ./run-hping.temp $n $i $round 2>mem-${i}.temp &"
	done > hping3-multi-${n}-round-${round}.sh
	echo "wait" >> hping3-multi-${n}-round-${round}.sh
	chmod +x hping3-multi-${n}-round-${round}.sh
	/usr/bin/time --format="%P" ./hping3-multi-${n}-round-${round}.sh 2>cpu-overall.temp
	local totalmaxmem=0
	for((i=0;$i<$n;i=$i+1)); do
		local memval=$(cat mem-${i}.temp);
		let totalmaxmem="$totalmaxmem+$memval";
	done
	echo "$(cat cpu-overall.temp) $totalmaxmem" > hping3-multi-$n-cpu-memory-round-${round}.log
}
for((round=$startinground;$round<=$N;round=$round+1)); do
echo "Running hping3...Round #${round}.............................."
for((i=1;$i<=$MAX_FLOWS;i=$i+$STEP)); do
	hping_multi_instances $i $round
	echo "The ${i} hping3 subscenario is finished."
done
done

