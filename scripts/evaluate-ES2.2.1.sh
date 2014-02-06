echo "Evaluation Scenario 2.2.1 (see evaluation guide for interpretation)"
echo "This script requires about 2:30 hours to finish."
N=4
t=1.960
cd ../partovnse.git/PartovServer/deploy/bin
rm ../config/config.ini
ln ../config/config-local.ini ../config/config.ini
echo "Generating ids file................................................"
i=7; j=14; k=49; # the biggest map
for((z=4;$z<550;z=$z+20)); do servc=$z; echo "$i $j $k $servc"; done > ids
for((z=550;$z<565;z=$z+2)); do servc=$z; echo "$i $j $k $servc"; done >> ids
head -n3 ids
echo "........"
tail -n3 ids
count=$(cat ids | wc -l)
echo "Preparing $count map files......................................"
OLDPWD=$(pwd)
cd ../../../../gen-simulation-map
cat $OLDPWD/ids | gawk '{ i=$1;j=$2;k=$3;servc=$4; print "./gen-simulation-map.out 1 ../config/routers", i, j, k, servc, "> simulation-"i"-"j"-"k"-servc-"servc"-lat1.map" }' | bash >/dev/null 2>&1
cat $OLDPWD/ids | gawk -v PP=$OLDPWD '{ i=$1;j=$2;k=$3;servc=$4; print "mv simulation-"i"-"j"-"k"-servc-"servc"-lat1.map",PP"/../maps/"  }' | bash
cd $OLDPWD
rm -f ss-*.dat

echo 'vi=$1;vj=$2;vk=$3;vservc=$4;round=$5;' > partov-running-script.sh
echo './partov > simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-raw-round-${round}.txt 2>&1' >> partov-running-script.sh
chmod +x partov-running-script.sh
for((round=1;$round<=$N;round=$round+1)); do
echo ". ../../../../scripts/functions.sh" > run.sh
cat ids | while read vi vj vk vservc; do
	mapfile="../maps/simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1.map";
	routers="../config/routers.map";
	echo "rm -f $routers && ln $mapfile $routers && /usr/bin/time --format=\"%P %M\" ./partov-running-script.sh ${vi} ${vj} ${vk} ${vservc} ${round} 2> simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-cpu-memory-round-${round}.log" >> run.sh
	echo "echo \"$mapfile is handled\"" >> run.sh
done
echo "Simulating...Round #${round}......................................."
bash ./run.sh
echo "Parsing results...................................................."
echo ". ../../../../scripts/functions.sh" > parse.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4; print "parse-id-rtt simulation-"i"-"j"-"k"-servc-"servc"-lat1-raw-round-"round".txt simulation-"i"-"j"-"k"-servc-"servc"-lat1-parsed-round-"round".dat" }' >> parse.sh
bash ./parse.sh
echo ". ../../../../scripts/functions.sh" > stat.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4; print "calc-id-rtt-statistics simulation-"i"-"j"-"k"-servc-"servc"-lat1-parsed-round-"round".dat ss-alldelays-"i"-"j"-"k"-servc-"servc"-lat1.dat ss-alljitters-"i"-"j"-"k"-servc-"servc"-lat1.dat" }' >> stat.sh
bash ./stat.sh
echo ". ../../../../scripts/functions.sh" > cpu-memory.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4; print "calc-cpu-memory-statistics simulation-"i"-"j"-"k"-servc-"servc"-lat1-cpu-memory-round-"round".log >> ss-"i"-"j"-"k"-servc-"servc"-lat1-cpu-memory.dat"; }' >> cpu-memory.sh
bash ./cpu-memory.sh
done

echo ". ../../../../scripts/functions.sh" > postprocess.sh
cat ids | gawk -v t=$t '{ i=$1;j=$2;k=$3;servc=$4; print "data=$(calc-djcm-aggregate-value-and-ci ss-alldelays-"i"-"j"-"k"-servc-"servc"-lat1.dat ss-alljitters-"i"-"j"-"k"-servc-"servc"-lat1.dat ss-"i"-"j"-"k"-servc-"servc"-lat1-cpu-memory.dat",t"); echo",servc,"$data" }' >> postprocess.sh
bash ./postprocess.sh > djcmaci-ES2.2.1.dat

mv djcmaci-ES2.2.1.dat ../../../../outputs/
echo "..djcmaci-ES2.2.1.dat is prepared................................ Done"

