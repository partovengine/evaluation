
set -e

wget -c 'https://www.nsnam.org/release/ns-allinone-3.19.tar.bz2' -O ns-allinone-3.19.tar.bz2
wget -c 'http://partov.ce.sharif.edu/gitlab/partovengine/cf/repository/archive.tar.gz?ref=v3.1.0' -O cf-v3.1.0.tar.gz
wget -c 'http://partov.ce.sharif.edu/gitlab/partovengine/partovnse/repository/archive.tar.gz?ref=v3.1.0' -O partovnse-v3.1.0.tar.gz

echo "Checking checksum of downloaded archives..."
sha512sum --check checksums.sha512
echo "Downloaded archived are valid."

echo
echo "Preparing NS-3 ...."
if [ ! -d ns-allinone-3.19/ ]; then
	tar xjf ns-allinone-3.19.tar.bz2
	cd ns-allinone-3.19/
	patch -p1 <../assets/ns-pinger-test-program.patch
else
	cd ns-allinone-3.19/
fi
echo "NS-3 requires python2 and can not work with python3. If you faced any error, make sure that python2 binary exists and works and then resume this script."
read -p "Press [Enter] to continue."
./build.py
cd ns-3.19/
./waf configure --enable-examples
./waf
cd ../../

echo
echo "Preparing CF ...."
if [ ! -d cf.git/ ]; then
	tar xzf cf-v3.1.0.tar.gz
	cd cf.git/
	cp ../assets/info.sh info.sh
	make
	cd ../
fi

echo
echo "Preparing Map Generator ...."
cd gen-simulation-map/
make
cd ../

echo
echo "Preparing Partov ...."
if [ ! -d partovnse.git/ ]; then
	tar xzf partovnse-v3.1.0.tar.gz
	cp -r ../assets/config/ partovnse.git/PartovServer/deploy/
fi
echo 'To install Partov, follow the ``partovnse.git/INSTALL" guide. Rest of this script only compiles Partov and you must install dependencies manually.'
echo "If you faced any compile error, check following common scenarios:"
echo "  - libpcap 1.5.1 must be installed; both binary and development version."
echo '  - if you are using an old libpcap version, you will see errors about missing pcap_* functions.'
echo '    * To fix it, uncomment the related define statement as described in the ``partovnse.git/INSTALL" guide to enable backward compatibility with old libpcap API and then continue with ``make" command again.'
read -p "Press [Enter] to continue."
cd partovnse.git/PartovServer/
qmake
make

echo
echo "Preparing is finished."
echo "Now you can continue doing tasks which are listed in the *After Preparation* section in the README.md file."

