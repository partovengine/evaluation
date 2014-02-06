startinground=$1
N=4
. functions.sh
NS_MAX_FLOWS=35
NS_STEP=8

cd ../ns-allinone-3.19/ns-3.19/
echo 'localip=$1; n=$2; i=$3; round=$4;' > run-ns.temp
echo './waf --run "src/emu/examples/emu-ping --localip=${localip}" > ../../outputs/ns3-multi-${n}-flow-${i}-raw-round-${round}.txt 2>&1 &' >> run-ns.temp
echo 'nspid=$!' >> run-ns.temp
# ns must finish itself after 60 seconds. If it does not, and so is not realtime despite its claims, we should kill at after 90 seconds (with 30 seconds to be sure it is really over its allowed running time
echo 'sleep 90' >> run-ns.temp
echo 'kill -9 $nspid >/dev/null 2>&1 || true;' >> run-ns.temp
chmod +x ./run-ns.temp

function nsthree_multi_instances {
	local n=$1
	local round=$2
	local i;
	for((i=0;$i<$n;i=$i+1)); do
		let lastbyte="$i+100"
		local localip="192.168.42.${lastbyte}"
		echo "/usr/bin/time --format=\"%M\" ./run-ns.temp ${localip} $n $i $round 2>mem-${i}.temp &"
	done > ns3-multi-${n}-round-${round}.sh
	echo "wait" >> ns3-multi-${n}-round-${round}.sh
	chmod +x ns3-multi-${n}-round-${round}.sh
	/usr/bin/time --format="%P" ./ns3-multi-${n}-round-${round}.sh 2>cpu-overall.temp
	local totalmaxmem=0
	for((i=0;$i<$n;i=$i+1)); do
		local memval=$(cat mem-${i}.temp);
		let totalmaxmem="$totalmaxmem+$memval";
	done
	echo "$(cat cpu-overall.temp) $totalmaxmem" > ../../outputs/ns3-multi-${n}-cpu-memory-round-${round}.log
}
for((round=$startinground;$round<=$N;round=$round+1)); do
echo "Running ns3...Round #${round}................................."
for((i=1;$i<$NS_MAX_FLOWS;i=$i+$NS_STEP)); do
	echo "The ${i} ns3 subscenario is started."
	nsthree_multi_instances $i $round
	echo "The ${i} ns3 subscenario is finished."
	sleep 30
done
i=$NS_MAX_FLOWS
echo "The ${i} ns3 subscenario is started."
nsthree_multi_instances $i $round
echo "The ${i} ns3 subscenario is finished."
sleep 30
done

