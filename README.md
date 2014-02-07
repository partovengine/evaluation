# Evaluation

This repo provides evaluation scripts to test performance of Partov and compare it with performance of Hping3 (a program created specially for sending different kinds of packets; as a base line for comparisons) and with performance of NS-3 (a famous network simulator).

## Preparation

You can run **prepare.sh** file to download NS-3, PartovNSE, and CF codes and compile/prepare them automatically. The script will warn about possible problems which may need manual intervention. Those cases are listed below:

1. NS-3 requires python2 and can not work with python3. If you faced any error during preparing NS-3, make sure that python2 binary exists and works. Then resume the **prepare.sh** script again,
2. When the _partovnse.git_ folder get created, use .sql files in _deploy/bin_ folder to create database and a user for running evaluation scenarios. Either create a user with 'paper' username and '1234' password or edit the credentials of created user in the **info.sh** file,
3. Either libpcap 1.5.1 must be installed or backward compatibility for pre-1.0 libpcap API must be enabled. For enabling backward compatibility see the _INSTALL_ guide in the _partovnse.git/_ folder.

## After Preparation

Following files must be edited manually:

1. The _ns-allinone-3.19/ns-3.19/src/emu/examples/emu-ping.cc_ file: There, update 3 items:
  - interface name which is currently set to **enp2s0**,
  - default local IP address which is currently set to **192.168.42.101** (select an IP within your local network IP range),
  - gateway IP address which is currently set to **192.168.42.1**,
2. The _cf.git/info.sh_ file: Update **user** and **pass** parameters there (to be equal to credentials of user that you have created in the **PartovDB** database),
3. All files starting with **config** in the _partovnse.git/PartovServer/deploy/config/_ folder: Update database connection information, interface name, IP address and MAC address of gateway, and IP address of virtual routers installed on those network interfaces,
4. All **.map** files in the _partovnse.git/PartovServer/deploy/config/_ folder: Update interface name,
5. The _emulation-ES3.1.map_ and _emulation-ES3.2.map_ files in _partovnse.git/PartovServer/deploy/config/_ folder: Update **next-hop** with IP address of the gateway,
6. In a terminal, go to _partovnse.git/PartovServer/deploy/bin/_ folder and run **./setcapability.sh** to give packet injection capability to created Partov binary executable file.

## Evaluation Scenarios

First double check that above tasks are completed correctly. If everything was OK, you must be able to run **hping3** to ping some host on the Internet by these commands (as root):

    hping3 -c 3 -i 1 -d 1024 -1 4.2.2.4

and also be able to do the same with the NS-3, using following commands (again as root):

    cd ns-allinone-3.19/ns-3.19/
    ./waf --run src/emu/examples/emu-ping

and do the same using Partov by following commands (as a normal, non-root, user):

    cd partovnse.git/PartovServer/deploy/bin/
    ln -f ../config/emulation-ES3.1.map ../config/routers.map
    ln -f ../config/config-emul-with-timeout.ini ../config/config.ini
    ./partov

and watch sent/received packets using **tcpdump** program. If you do not see packets as expected, check installation guides and readme files of related part and fix the problem manually before moving forward.

Then, go to _scripts_ folder and run evaluation scripts one by one to obtain experiments results within the _outputs_ folder. Each script will print additional messages about its progress and an estimation about required time to complete that experiment.
For a more detailed description about what is being performed in each evaluation scenario, look in the **evaluation-guide.md** file.

## Plotting Results

After completion of each evaluation script, you can find a message about created output file(s). Copy them from the _outputs_ folder to the _plots_ folder and run corresponding GnuPlot scripts to generate **eps** figures from obtained data files. Use **epstopdf** program to convert **eps** figures to **pdf** figures afterwards. Some figures like boxplots which are more complicated can not be rendered correctly in raw **eps** form and must be converted to **pdf** to become correctly viewable.
You can also use **plots/prepare-plots.sh** script to generate all plots at once.

