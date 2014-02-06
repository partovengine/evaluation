#include <iostream>
#include <stdlib.h>
#include <cstdint>
#include <string.h>

#include "mapcreator.h"

using namespace std;


void usage ();
MapCreator *parseArguments (int argc, char *argv[]);


int main (int argc, char *argv[]) {
	MapCreator *mapcreator = parseArguments (argc, argv);
	if (!mapcreator) {
		return -1;
	}
	mapcreator->createNodes ();
	mapcreator->printMap ();
	delete mapcreator;

	return 0;
}

MapCreator *parseArguments (int argc, char *argv[]) {
	bool emulationMode = false;
	bool compactScheduler = false;
	if (strcmp (argv[argc-1], "emul") == 0) { // match
		emulationMode = true;
		argc--;
	} else if (strcmp (argv[argc-1], "real") == 0) {
		argc--;
	} else if (strcmp (argv[argc-1], "compact") == 0) {
		compactScheduler = true;
		argc--;
	}
	if (argc > 10 || argc < 7) {
		usage ();
		return 0;
	}
	int dataSize = -1;
	char *gapstr = 0;
	while (argc-- > 7) {
		switch (argv[argc][0]) {
		case 's': {
			int seed = atoi (&argv[argc][2]);
			srand (seed);
			break;
		}
		case 'g':
			gapstr = &argv[argc][2];
			break;
		case 'd':
			dataSize = atoi (&argv[argc][2]);
			break;
		}
	}
	int *gap;
	int gapno = 1;
	if (gapstr != 0) {
		for (int i = 0; gapstr[i]; ++i) {
			if (gapstr[i] == ',') {
				gapno++;
			}
		}
		gap = new int[gapno];
		for (int i = 0; ; ++i, gapstr = 0) {
			const char *gi = strtok (gapstr, ",");
			if (gi == 0) {
				break;
			}
			gap[i] = atoi (gi);
		}
	} else {
		gap = new int[gapno];
		gap[0] = 100; // 100 ms | 10 pps
	}
	int latency = atoi (argv[1]);
	string mapName = argv[2];
	int innerCount = atoi (argv[3]);
	int secondLayerFanOut = atoi (argv[4]);
	int thirdLayerFanOut = atoi (argv[5]);
	int serversCount = atoi (argv[6]);
	if (innerCount > 15) {
		cerr << "Error: At most 15 nodes can be placed in the first layer" << endl;
		return 0;
	} else if (secondLayerFanOut > 15) {
		cerr << "Error: At most 15 nodes can be placed in the second layer per each node in the first layer" << endl;
		return 0;
	} else if (thirdLayerFanOut > 256) {
		cerr << "Error: At most 256 nodes can be placed in the third layer per each node in the second layer" << endl;
		return 0;
	} else if (serversCount > innerCount * secondLayerFanOut * thirdLayerFanOut / 2) {
		cerr << "Error: At most " << (innerCount * secondLayerFanOut * thirdLayerFanOut / 2) << " nodes can be marked as server in this topology (which results to having no client at all!)" << endl;
		return 0;
	}

	MapCreator *mapcreator = new MapCreator (latency, mapName,
			innerCount, secondLayerFanOut, thirdLayerFanOut, serversCount,
			emulationMode, compactScheduler,
			gap, gapno, dataSize);
	return mapcreator;
}

void usage () {
	cerr << "The program needs 6..10 arguments." << endl;
	cerr << "\t- latency of all links in milli-seconds" << endl;
	cerr << "\t- name of the map" << endl;
	cerr << "\t- count of routers in most inner circle" << endl;
	cerr << "\t- fan out from first layer towards second layer" << endl;
	cerr << "\t- fan out from second towards third layer" << endl;
	cerr << "\t- count of nodes which must be used as servers/clients (in third layer; symmetrically)" << endl;
	cerr << "\t- (optional) g=<num> gap interval between consecutively sent PING packets in milli-seconds" << endl;
	cerr << "\t- (optional) s=<num> random seed" << endl;
	cerr << "\t- (optional) d=<num> data size in bytes" << endl;
	cerr << "\t- (optional) emul | real | compact (default: real)" << endl;
	cerr << "\t\t-- emul: enable emulation and use realtime scheduler" << endl;
	cerr << "\t\t-- real: disable emulation and use realtime scheduler" << endl;
	cerr << "\t\t-- compact: disable emulation and use compact-time scheduler" << endl;
}

