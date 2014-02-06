echo "Evaluation Scenario 2.3.1 (see evaluation guide for interpretation)"
echo "This script requires about 5:15 hours to finish."
startedat=`date`
N=4
t=1.960
cd ../partovnse.git/PartovServer/deploy/bin
#check precondition...
pingercppfile=$(find ../../src/ -name Pinger.cpp)
if [ -z "$(grep '^#define ES2_3_1$' $pingercppfile)" ]; then
	echo "For running ES2.3.1, it's required to uncomment related 'define' statement at the beginning of \`\`$pingercppfile'' file and compile it again. Do not forget to comment it again and recompile for other evaluation scripts to work as expected.";
	exit -1;
fi
#end of check for precondition
rm -f ../config/config.ini
ln ../config/config-local-without-timeout.ini ../config/config.ini
echo "Generating ids file................................................"
i=7; j=14; k=49; # the biggest map
for((z=4;$z<605;z=$z+10)); do servc=$z; echo "$i $j $k $servc"; done > ids
cat ids | gawk '{ i=$1;j=$2;k=$3;servc=$4; print servc }' > clientcount
head -n3 ids
echo "........"
tail -n3 ids
count=$(cat ids | wc -l)
echo "Preparing $count map files......................................"
OLDPWD=$(pwd)
cd ../../../../gen-simulation-map
cat $OLDPWD/ids | gawk '{ i=$1;j=$2;k=$3;servc=$4; print "./gen-simulation-map.out 1 ../config/routers", i, j, k, servc, "compact > simulation-"i"-"j"-"k"-servc-"servc"-lat1-compact.map" }' | bash >/dev/null 2>&1
cat $OLDPWD/ids | gawk -v PP=$OLDPWD '{ i=$1;j=$2;k=$3;servc=$4; print "mv simulation-"i"-"j"-"k"-servc-"servc"-lat1-compact.map",PP"/../maps/"  }' | bash
cd $OLDPWD
rm -f ss-*.dat

echo 'vi=$1;vj=$2;vk=$3;vservc=$4;round=$5;' > partov-running-script.sh
echo './partov > simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-compact-raw-round-${round}.txt 2>&1' >> partov-running-script.sh
chmod +x partov-running-script.sh
for((round=1;$round<=$N;round=$round+1)); do
echo ". ../../../../scripts/functions.sh" > run.sh
cat ids | while read vi vj vk vservc; do
	mapfile="../maps/simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-compact.map";
	routers="../config/routers.map";
	echo "rm -f $routers && ln $mapfile $routers && /usr/bin/time --format=\"%e %M\" ./partov-running-script.sh ${vi} ${vj} ${vk} ${vservc} ${round} 2> simulation-${vi}-${vj}-${vk}-servc-${vservc}-lat1-compact-wallclock-memory-round-${round}.log" >> run.sh
	echo "echo \"$mapfile is handled\"" >> run.sh
done
echo "Simulating...Round #${round}......................................."
bash ./run.sh
echo "Parsing results...................................................."
echo ". ../../../../scripts/functions.sh" > parse.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4; print "parse-id-rtt simulation-"i"-"j"-"k"-servc-"servc"-lat1-compact-raw-round-"round".txt simulation-"i"-"j"-"k"-servc-"servc"-lat1-compact-parsed-round-"round".dat" }' >> parse.sh
bash ./parse.sh
echo ". ../../../../scripts/functions.sh" > stat.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4; print "calc-id-rtt-statistics simulation-"i"-"j"-"k"-servc-"servc"-lat1-compact-parsed-round-"round".dat ss-alldelays-"i"-"j"-"k"-servc-"servc"-lat1-compact.dat ss-alljitters-"i"-"j"-"k"-servc-"servc"-lat1-compact.dat" }' >> stat.sh
bash ./stat.sh
echo ". ../../../../scripts/functions.sh" > wallclock-memory.sh
cat ids | gawk -v round=$round '{ i=$1;j=$2;k=$3;servc=$4; print "cat simulation-"i"-"j"-"k"-servc-"servc"-lat1-compact-wallclock-memory-round-"round".log >> ss-"i"-"j"-"k"-servc-"servc"-lat1-compact-wallclock-memory.dat"; }' >> wallclock-memory.sh
bash ./wallclock-memory.sh
done

echo ". ../../../../scripts/functions.sh" > postprocess.sh
cat ids | gawk -v t=$t '{ i=$1;j=$2;k=$3;servc=$4; print "calc-djwm-aggregate-value-and-ci ss-alldelays-"i"-"j"-"k"-servc-"servc"-lat1-compact.dat ss-alljitters-"i"-"j"-"k"-servc-"servc"-lat1-compact.dat ss-"i"-"j"-"k"-servc-"servc"-lat1-compact-wallclock-memory.dat",t }' >> postprocess.sh
bash ./postprocess.sh > ss

paste clientcount ss > djwmaci-ES2.3.1.dat
mv djwmaci-ES2.3.1.dat ../../../../outputs/
echo "..djwmaci-ES2.3.1.dat is prepared................................ Done"
echo "started at:"
echo $startedat
echo "finished at:"
date
bash ../../../../scripts/evaluate-parse-delay-ES2.3.1.sh
