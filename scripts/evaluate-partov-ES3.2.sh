startinground=$1
N=4
t=1.960
. functions.sh
cd ../partovnse.git/PartovServer/deploy/bin
rm ../config/routers.map
ln ../config/emulation-ES3.2-er.map ../config/routers.map
rm ../config/config.ini
ln ../config/config-emul.ini ../config/config.ini
cp ../config/emulation-ES3.2.map ../maps/
MAX_FLOWS=154
STEP=9
function emulate_multi_instances {
	local n=$1
	local round=$2
	(
		sleep 5;
		cd ../../../../cf.git
		local i;
		for((i=0;$i<$n;i=$i+1)); do
			./new.sh >/dev/null 2>&1
		done
		sleep 60;
		for((i=0;$i<$n;i=$i+1)); do
			./free.sh >/dev/null 2>&1
		done
		partovpid=$(ps aux | grep './partov' | grep -v grep | gawk '{ print $2 }');
		kill -INT $partovpid
	) &
	echo "./partov > ../../../../outputs/emulation-multi-${n}-raw-round-${round}.txt 2>&1" > run-partov.temp
	chmod +x run-partov.temp
	/usr/bin/time --format="%P %M" ./run-partov.temp 2> ../../../../outputs/emulation-multi-${n}-cpu-memory-round-${round}.log
	find ../logs/emulation-ES3.2/paper/ -name scalar.log | sort | while read ff; do
	        echo "scale=9; received=$(cat $ff | tail -n2 | head -n1 | cut -d= -f2); sent=$(cat $ff | tail -n1 | cut -d= -f2); print sent; print \" \"; print received; print \"\n\"" | bc
	done > ll-flows-${i}-round-${round}.loss
}
for((round=$startinground;$round<=$N;round=$round+1)); do
echo "Emulating...Round #${round}..................................."
for((i=1;$i<=$MAX_FLOWS;i=$i+$STEP)); do
	rm -rf ../logs/emulation-ES3.2/paper/*
	emulate_multi_instances $i $round
	sleep 30
	echo "The emulation subscenario $i is finished."
done
done

