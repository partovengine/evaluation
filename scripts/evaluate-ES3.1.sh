echo "Evaluation Scenario 3.1 (see evaluation guide for interpretation)"
echo "This script must be executed as root (for hping3 and ns3 to work)"
echo "This script requires about 30 minutes to finish."
N=4
t=1.960

. functions.sh

cd ../partovnse.git/PartovServer/deploy/bin
rm ../config/routers.map
ln ../config/emulation-ES3.1.map ../config/routers.map
rm ../config/config.ini
ln ../config/config-emul-with-timeout.ini ../config/config.ini
for((round=1;$round<=$N;round=$round+1)); do
echo "Emulating...Round #${round}..................................."
./partov > ../../../../outputs/emulation-single-raw-round-${round}.txt 2>&1 &
partovpid=$!
sleep 120
kill -9 $partovpid >/dev/null 2>&1 || true;
echo "Waiting...."
sleep 30
echo "Running hping3...Round #${round}.............................."
hping3 -c 60 -i 1 -d 1024 -1 4.2.2.4 > ../../../../outputs/hping3-single-raw-round-${round}.txt 2>&1 &
hpingpid=$!
sleep 120
kill -9 $hpingpid >/dev/null 2>&1 || true;
echo "Waiting...."
sleep 30
echo "Running ns3...Round #${round}................................."
cd ../../../../ns-allinone-3.19/ns-3.19/
./waf --run src/emu/examples/emu-ping > ../../outputs/ns3-single-raw-round-${round}.txt 2>&1 &
nspid=$!
# all emulators are configured to exit by themselves after 60 seconds so we can kill them after 120 seconds for sure.
sleep 120
kill -9 $nspid >/dev/null 2>&1 || true;
cd ../../partovnse.git/PartovServer/deploy/bin/
done
cd ../../../../outputs/
echo "Parsing results..............................................."
echo -n > esdbp-ES3.1.dat.temp
echo -n > esjbp-ES3.1.dat.temp
echo -n > hsdbp-ES3.1.dat.temp
echo -n > hsjbp-ES3.1.dat.temp
echo -n > ns3sdbp-ES3.1.dat.temp
echo -n > ns3sjbp-ES3.1.dat.temp
for((round=1;$round<=$N;round=$round+1)); do
parse-rtt emulation-single-raw-round-${round}.txt delay.temp
cat delay.temp >> esdbp-ES3.1.dat.temp
calc-jitter delay.temp jitter.temp
cat jitter.temp >> esjbp-ES3.1.dat.temp

hp-parse-rtt hping3-single-raw-round-${round}.txt delay.temp
cat delay.temp >> hsdbp-ES3.1.dat.temp
calc-jitter delay.temp jitter.temp
cat jitter.temp >> hsjbp-ES3.1.dat.temp

nsthree-parse-rtt ns3-single-raw-round-${round}.txt delay.temp
cat delay.temp >> ns3sdbp-ES3.1.dat.temp
calc-jitter delay.temp jitter.temp
cat jitter.temp >> ns3sjbp-ES3.1.dat.temp
done

sort --numeric-sort esdbp-ES3.1.dat.temp > esdbp-ES3.1.dat
sort --numeric-sort esjbp-ES3.1.dat.temp > esjbp-ES3.1.dat
sort --numeric-sort hsdbp-ES3.1.dat.temp > hsdbp-ES3.1.dat
sort --numeric-sort hsjbp-ES3.1.dat.temp > hsjbp-ES3.1.dat
sort --numeric-sort ns3sdbp-ES3.1.dat.temp > ns3sdbp-ES3.1.dat
sort --numeric-sort ns3sjbp-ES3.1.dat.temp > ns3sjbp-ES3.1.dat

calc-cdf esdbp-ES3.1.dat esdcdf-ES3.1.dat
calc-cdf esjbp-ES3.1.dat esjcdf-ES3.1.dat
calc-cdf hsdbp-ES3.1.dat hsdcdf-ES3.1.dat
calc-cdf hsjbp-ES3.1.dat hsjcdf-ES3.1.dat
calc-cdf ns3sdbp-ES3.1.dat ns3sdcdf-ES3.1.dat
calc-cdf ns3sjbp-ES3.1.dat ns3sjcdf-ES3.1.dat

esdavg=$(calc-avg esdbp-ES3.1.dat)
esdci=$(calc-confidence-interval-endpoints esdbp-ES3.1.dat $t)
esjavg=$(calc-avg esjbp-ES3.1.dat)
esjci=$(calc-confidence-interval-endpoints esjbp-ES3.1.dat $t)
hsdavg=$(calc-avg hsdbp-ES3.1.dat)
hsdci=$(calc-confidence-interval-endpoints hsdbp-ES3.1.dat $t)
hsjavg=$(calc-avg hsjbp-ES3.1.dat)
hsjci=$(calc-confidence-interval-endpoints hsjbp-ES3.1.dat $t)
ns3sdavg=$(calc-avg ns3sdbp-ES3.1.dat)
ns3sdci=$(calc-confidence-interval-endpoints ns3sdbp-ES3.1.dat $t)
ns3sjavg=$(calc-avg ns3sjbp-ES3.1.dat)
ns3sjci=$(calc-confidence-interval-endpoints ns3sjbp-ES3.1.dat $t)
#18 columns
echo $esdavg $esdci $esjavg $esjci $hsdavg $hsdci $hsjavg $hsjci $ns3sdavg $ns3sdci $ns3sjavg $ns3sjci > ehpns3-sdjaci-ES3.1.dat

mkdir -p enhs-ES3.1-datfiles
rm -f enhs-ES3.1-datfiles/*
mv esdbp-ES3.1.dat esjbp-ES3.1.dat esdcdf-ES3.1.dat esjcdf-ES3.1.dat hsdbp-ES3.1.dat hsjbp-ES3.1.dat hsdcdf-ES3.1.dat hsjcdf-ES3.1.dat ns3sdbp-ES3.1.dat ns3sjbp-ES3.1.dat ns3sdcdf-ES3.1.dat ns3sjcdf-ES3.1.dat enhs-ES3.1-datfiles/
mv ehpns3-sdjaci-ES3.1.dat enhs-ES3.1-datfiles/
echo "..enhs-ES3.1-datfiles folder is prepared.................. Done"
