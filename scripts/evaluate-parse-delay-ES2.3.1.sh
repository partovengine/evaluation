echo "Parsing delay info of ES2.3.1 to prepare CDF data file........"

. ../../../../scripts/functions.sh
cat ids | while read vi vj vk vservc; do
	delaysfile="ss-alldelays-${vi}-${vj}-${vk}-servc-${vservc}-lat1-compact.dat";
	tempcdffile="qq-temp-delays-cdf-${vi}-${vj}-${vk}-servc-${vservc}-lat1-compact.dat";
	calc-cdf $delaysfile $tempcdffile
	# for 10 ms
	rowone=$(head -n 1 $tempcdffile)
	# for 12 ms
	rowtwo=$(head -n 2 $tempcdffile | tail -n 1)
	# for 14 ms
	rowthree=$(head -n 3 $tempcdffile | tail -n 1)
	# for 16 ms
	rowfour=$(head -n 4 $tempcdffile | tail -n 1)
	# for 20 ms
	rowfive=$(head -n 5 $tempcdffile | tail -n 1)
	# 11 columns
	echo "$vservc $rowone $rowtwo $rowthree $rowfour $rowfive"
done > dcdf-ES2.3.1.dat

mv dcdf-ES2.3.1.dat ../../../../outputs/
echo "..dcdf-ES2.3.1.dat is prepared................................ Done"
