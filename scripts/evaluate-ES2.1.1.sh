echo "Evaluation Scenario 2.1.1 (see evaluation guide for interpretation)"
echo "This script requires about 1:30 hours to finish."
N=4
t=1.960
cd ../partovnse.git/PartovServer/deploy/bin
rm ../config/config.ini
ln ../config/config-local.ini ../config/config.ini
echo "Generating ids file................................................"
i=7; j=14; k=49; servc=30; # the biggest map
function generate_ids {
	local gi;
	for((gi=11;$gi<=100;gi=$gi+1)); do
		local rate=$(echo "scale=9; $servc*1000.0/$gi" | bc);
		local group=$(echo "scale=0; $rate/100" | bc);
		echo $group $rate $gi
	done > ids.pre.temp
	sort --numeric-sort -u ids.pre.temp > ids.temp
	cat ids.temp | gawk -v i=$i -v j=$j -v k=$k -v servc=$servc '{ rate=$2; gap=$3; print i, j, k, servc, gap, rate; }' > ids
}
generate_ids
head -n3 ids
echo "........"
tail -n3 ids
count=$(cat ids | wc -l)
echo "Preparing $count map files......................................"
OLDPWD=$(pwd)
cd ../../../../gen-simulation-map
cat $OLDPWD/ids | gawk '{ i=$1;j=$2;k=$3;servc=$4;gap=$5; print "./gen-simulation-map.out 1 ../config/routers", i, j, k, servc, "g="gap, "> simulation-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms.map" }' | bash >/dev/null 2>&1
cat $OLDPWD/ids | gawk -v PP=$OLDPWD '{ i=$1;j=$2;k=$3;servc=$4;gap=$5; print "mv simulation-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms.map",PP"/../maps/"  }' | bash
cd $OLDPWD
rm -f ss-*.dat

echo 'vi=$1;vj=$2;vk=$3;vservc=$4;vgap=$5;round=$6;' > partov-running-script.sh
echo './partov > simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-gap-${vgap}ms-raw-round-${round}.txt 2>&1' >> partov-running-script.sh
chmod +x partov-running-script.sh
for((round=1;$round<=$N;round=$round+1)); do
echo ". ../../../../scripts/functions.sh" > run.sh
cat ids | while read vi vj vk vservc vgap vrate; do
	mapfile="../maps/simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-gap-${vgap}ms.map";
	routers="../config/routers.map";
	echo "rm -f $routers && ln $mapfile $routers && /usr/bin/time --format=\"%P %M\" ./partov-running-script.sh ${vi} ${vj} ${vk} ${vservc} ${vgap} ${round} 2> simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-gap-${vgap}ms-cpu-memory-round-${round}.log" >> run.sh
	echo "echo \"$mapfile is handled\"" >> run.sh
done
echo "Simulating...Round #${round}......................................."
bash ./run.sh
echo "Parsing results...................................................."
echo ". ../../../../scripts/functions.sh" > parse.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4;gap=$5; print "parse-id-rtt simulation-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms-raw-round-"round".txt simulation-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms-parsed-round-"round".dat" }' >> parse.sh
bash ./parse.sh
echo ". ../../../../scripts/functions.sh" > stat.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4;gap=$5; print "calc-id-rtt-statistics simulation-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms-parsed-round-"round".dat ss-alldelays-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms.dat ss-alljitters-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms.dat" }' >> stat.sh
bash ./stat.sh
echo ". ../../../../scripts/functions.sh" > cpu-memory.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4;gap=$5; print "calc-cpu-memory-statistics simulation-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms-cpu-memory-round-"round".log >> ss-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms-cpu-memory.dat"; }' >> cpu-memory.sh
bash ./cpu-memory.sh
done

echo ". ../../../../scripts/functions.sh" > postprocess.sh
cat ids | gawk -v t=$t '{ i=$1;j=$2;k=$3;servc=$4;gap=$5;rate=$6; print "data=$(calc-djcm-aggregate-value-and-ci ss-alldelays-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms.dat ss-alljitters-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms.dat ss-"i"-"j"-"k"-servc-"servc"-lat1-gap-"gap"ms-cpu-memory.dat",t"); echo",rate,"$data",gap }' >> postprocess.sh
bash ./postprocess.sh > djcmaci-ES2.1.1.dat

mv djcmaci-ES2.1.1.dat ../../../../outputs/
echo "..djcmaci-ES2.1.1.dat is prepared................................ Done"

