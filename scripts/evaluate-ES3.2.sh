echo "Evaluation Scenario 3.2 (see evaluation guide for interpretation)"
echo "This script must be executed as root (for hping3 and ns3 to work)"
echo "This script requires about 5 to 6 hours to finish."
startedat=`date`

bash evaluate-partov-ES3.2.sh 1

echo "Waiting for 2 minutes to be sure that no packet from previous experiments is on the air"
sleep 120
bash evaluate-ns-ES3.2.sh 1

echo "Waiting for 2 minutes to be sure that no packet from previous experiments is on the air"
sleep 120
bash evaluate-hping-ES3.2.sh 1

bash evaluate-parse-ES3.2.sh

cd ../outputs/

mkdir -p enhs-ES3.2-datfiles
rm -f enhs-ES3.2-datfiles/*
mv edjcmlaci-ES3.2.dat hdjcmlaci-ES3.2.dat ns3djcmlaci-ES3.2.dat enhs-ES3.2-datfiles
echo "..enhs-ES3.2-datfiles folder is prepared.................. Done"
echo "started at:"
echo $startedat
echo "finished at:"
date

