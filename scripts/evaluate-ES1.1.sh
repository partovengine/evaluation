echo "Evaluation Scenario 1.1 (see evaluation guide for interpretation)"
echo "This script requires about 5 minutes to finish."
N=4
t=1.960
cd ../partovnse.git/PartovServer/deploy/bin
rm ../config/routers.map
ln ../config/simulation-ES1.1.map ../config/routers.map
rm ../config/config.ini
ln ../config/config-local.ini ../config/config.ini
. ../../../../scripts/functions.sh
echo -n > simdbp-ES1.1.dat
echo -n > simjbp-ES1.1.dat
echo "Simulating........................................................."
for((round=1;$round<=$N;round=$round+1)); do
echo "Round #$round"
./partov > simulation-minimal-map-raw.txt 2>&1
echo "Parsing results...................................................."
parse-rtt simulation-minimal-map-raw.txt simdbp-ES1.1-round-${round}.temp
remove-outlier simdbp-ES1.1-round-${round}.temp 1 simdbp-ES1.1-round-${round}.dat
calc-jitter simdbp-ES1.1-round-${round}.dat simjbp-ES1.1-round-${round}.dat
cat simdbp-ES1.1-round-${round}.dat >> simdbp-ES1.1.dat
cat simjbp-ES1.1-round-${round}.dat >> simjbp-ES1.1.dat
done

calc-cdf simdbp-ES1.1.dat simdcdf-ES1.1.dat
calc-cdf simjbp-ES1.1.dat simjcdf-ES1.1.dat

avgdelay=$(calc-avg simdbp-ES1.1.dat)
delay_confidence_interval=$(calc-confidence-interval-endpoints simdbp-ES1.1.dat $t)
avgjitter=$(calc-avg simjbp-ES1.1.dat)
jitter_confidence_interval=$(calc-confidence-interval-endpoints simjbp-ES1.1.dat $t)
#6 columns
echo $avgdelay $delay_confidence_interval $avgjitter $jitter_confidence_interval > simdj-aci-ES1.1.dat

mkdir -p sim-ES1.1-datfiles
rm -f sim-ES1.1-datfiles/*
mv simdbp-ES1.1.dat simjbp-ES1.1.dat simdcdf-ES1.1.dat simjcdf-ES1.1.dat simdj-aci-ES1.1.dat sim-ES1.1-datfiles/
rm -rf ../../../../outputs/sim-ES1.1-datfiles/
mv sim-ES1.1-datfiles/ ../../../../outputs/
echo "..sim-ES1.1-datfiles folder is prepared....................... Done"
