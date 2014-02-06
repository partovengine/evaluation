#include <sstream>
#include <stdlib.h>

#include "mapcreator.h"

#include "node.h"
#include "printer.h"

MapCreator::MapCreator (int _latency, std::string _mapName,
		int _innerCount, int _secondLayerFanOut, int _thirdLayerFanOut, int _serversCount,
		bool _emulationMode, bool _compactScheduler, int *_gap, int _gapno, int _dataSize)
	: latency (_latency), mapName (_mapName),
	innerCount (_innerCount), secondLayerFanOut (_secondLayerFanOut), thirdLayerFanOut (_thirdLayerFanOut),
	totalCount (innerCount * (1 + secondLayerFanOut * (1 + thirdLayerFanOut))),
	nodes (new Node[totalCount]), serversCount (_serversCount),
	emulationMode (_emulationMode), compactScheduler (_compactScheduler),
	gap (_gap), gapno (_gapno), dataSize (_dataSize)
{ }

MapCreator::~MapCreator () {
	if (nodes) {
		delete[] nodes;
	}
	delete[] gap;
}

void MapCreator::printLink (const std::string &linkName, int indentationLevel) const {
	printLine ("<ptl:link ptl:name=\"", linkName, "\" ptl:protocol=\"802.3\"><ptl:latency>", latency, "ms</ptl:latency></ptl:link>", indentationLevel);
}

std::string MapCreator::prepareLinkName (const char *identifier, int i, const char *layerSeparator, int j) const {
	std::ostringstream oss;
	oss << identifier << i << layerSeparator << j;
	return oss.str ();
}

std::string MapCreator::prepareLinkName (const std::string &identifier, const char *layerSeparator, int k) const {
	std::ostringstream oss;
	oss << identifier << layerSeparator << k;
	return oss.str ();
}

void MapCreator::printLinks () const {
	printLine ("<ptl:links>", 1);
	for (int i = 0; i < innerCount; ++i) {
		for (int j = i+1; j < innerCount; ++j) {
			std::string linkName = prepareLinkName ("L", i, "-", j);
			printLink (linkName, 2);
		}
		printLine ();
		for (int j = 0; j < secondLayerFanOut; ++j) {
			std::string linkName = prepareLinkName ("L", i, "-s1-", j);
			printLink (linkName, 2);
			for (int k = 0; k < thirdLayerFanOut; ++k) {
				std::string secondLinkName = prepareLinkName (linkName, "-s2-", k);
				printLink (secondLinkName, 3);
			}
		}
		printLine ();
	}
	printLine ("</ptl:links>", 1);
}

void MapCreator::printMap () const {
	printLine ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
	if (compactScheduler) {
		printLine ("<ptl:map xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:ptl=\"http://partov.ce.sharif.edu/2013/PTL/Map\" xsi:schemaLocation=\"http://partov.ce.sharif.edu/2013/PTL/Map map.xsd\" ptl:name=\"", mapName, "\" ptl:version=\"3.1\" ptl:realtime=\"false\" ptl:count=\"1\">");
	} else { // realtime scheduler -> default
		printLine ("<ptl:map xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:ptl=\"http://partov.ce.sharif.edu/2013/PTL/Map\" xsi:schemaLocation=\"http://partov.ce.sharif.edu/2013/PTL/Map map.xsd\" ptl:name=\"", mapName, "\" ptl:version=\"3.1\" ptl:count=\"1\">");
	}

	printLinks ();

	printLine ("<ptl:nodes>", 1);
	for (int i = 0; i < totalCount; ++i) {
		nodes[i].print (gapno, dataSize);
	}
	printLine ("</ptl:nodes>", 1);
	printLine ("<ptl:lists>", 1);
	printLine ("<ptl:size ptl:name=\"buffer-size\">", 2);
	printLine ("<ptl:item>500B</ptl:item>", 3);
	printLine ("</ptl:size>", 2);
	printLine ("<ptl:size ptl:name=\"physical-buffer-size\">", 2);
	printLine ("<ptl:item>500B</ptl:item>", 3);
	printLine ("</ptl:size>", 2);
	for (int i = 0; i < gapno; ++i) {
		printLine ("<ptl:time ptl:name=\"gap-interval", i, "\">", 2);
		printLine ("<ptl:item>", gap[i], "ms</ptl:item>", 3);
		printLine ("</ptl:time>", 2);
	}
	printLine ("</ptl:lists>", 1);
	printLine ("</ptl:map>");
}

void MapCreator::createNodes () {
	//n=innerCount, m=secondLayerFanOut, q=thirdLayerFanOut
	//nodes: R1, R2, ..., Rn, \ => innerCount
	//	R1s1, ..., R1sm, R2s1, ..., R2sm, ..., Rns1, ..., Rnsm, \ => innerCount * secondLayerFanOut
	//	R1s1s1, ..., R1s1sq, ..., R1sms1, ..., R1smsq, R2s1s1, ..., R2s1sq, ..., Rnsms1, ..., Rnsmsq # => innerCount * secondLayerFanOut * thirdLayerFanOut
	// totalCount = innerCount * (1 + secondLayerFanOut * (1 + thirdLayerFanOut))

	std::ostringstream oss;
	// First layer nodes
	for (int i = 0; i < innerCount; ++i) {
		oss.clear ();
		oss.str ("");
		oss << "R" << i;
		std::string name = oss.str ();
		nodes[i].init (innerCount + secondLayerFanOut, name);
	}
	// First layer links
	for (int i = 0; i < innerCount; ++i) {
		Node &u = nodes[i];
		for (int j = i+1; j < innerCount; ++j) {
			Node &v = nodes[j];
			oss.clear ();
			oss.str ("");
			oss << "L" << i << "-" << j;
			std::string linkName = oss.str ();
			std::uint32_t ip = 10 << 24 | 0 << 16 | (i*innerCount + j) << 8;
			u.addInterfaceAndLink (j-i, linkName, ip | 10);
			v.addInterfaceAndLink (innerCount-j+i, linkName, ip | 20);

			u.addRouting (j-i, 10 << 24 | (j+1) << 20, 12, ip | 20);
			v.addRouting (innerCount-j+i, 10 << 24 | (i+1) << 20, 12, ip | 10);
		}
		oss.clear ();
		oss.str ("");
		oss << "R" << i;
		std::string name = oss.str ();
		// Second layer nodes
		for (int j = 0; j < secondLayerFanOut; ++j) {
			oss.clear ();
			oss.str ("");
			oss << "L" << i << "-s1-" << j;
			std::string linkName = oss.str ();
			std::uint32_t ip = 10 << 24 | (i+1) << 20 | (j+1) << 8;
			std::uint32_t ipj = (ip & 0xFFFF0000) | (j+1) << 16;
			oss.clear ();
			oss.str ("");
			oss << name << "s" << j;
			std::string vname = oss.str ();
			Node &v = nodes[innerCount + i*secondLayerFanOut + j];
			createNode (u, innerCount + i*secondLayerFanOut + j, thirdLayerFanOut, vname, linkName, innerCount + j + 1, ip, ipj, 16);
			// third layer nodes
			for (int k = 0; k < thirdLayerFanOut; ++k) {
				oss.clear ();
				oss.str ("");
				oss << linkName << "-s2-" << k;
				std::string secondLinkName = oss.str ();
				std::uint32_t ipk = ipj | k << 8;
				oss.clear ();
				oss.str ("");
				oss << vname << "s" << k;
				std::string zname = oss.str ();
				createNode (v, innerCount * (1 + secondLayerFanOut) + (i*secondLayerFanOut + j) * thirdLayerFanOut + k, 0, zname, secondLinkName, k+1, ipk, ipk, 24);
			}
		}
	}
	markClientsAndServers ();
}

int mod (int a, int b) {
	if (b == 0) {
		return 0;
	} else {
		return a % b;
	}
}

void MapCreator::markClientsAndServers () {
	int countOfNodesInThirdLayer = innerCount * secondLayerFanOut * thirdLayerFanOut;
	int countOfNodesInSecondLayer = innerCount * secondLayerFanOut;
	bool *serverSelected = new bool[countOfNodesInThirdLayer];
	int *serverIndex = new int[serversCount];
	int clientOffset = (countOfNodesInSecondLayer / 2) * thirdLayerFanOut;
	for (int i = 0; i < countOfNodesInThirdLayer; ++i) { 
		serverSelected[i] = false;
	}
	for (int i = 0; i < serversCount; ++i) {
		int r = mod (rand (), countOfNodesInSecondLayer / 2) * thirdLayerFanOut + mod (rand (), thirdLayerFanOut);
		while (serverSelected[r]) {
			r = mod (rand (), countOfNodesInSecondLayer / 2) * thirdLayerFanOut + mod (rand (), thirdLayerFanOut);
		}
		serverSelected[r] = true;
		serverIndex[i] = r;
	}
	// marking clients and servers and their correspondences
	int offset = totalCount - countOfNodesInThirdLayer;
	std::cerr << "servers count: " << serversCount << std::endl;
	for (int i = 0; i < serversCount; ++i) { 
		int s = serverIndex[i];
		int c = s + clientOffset;
		std::cerr << "Select " << s << " as server and " << c << " as client" << std::endl;
		Node &server = nodes[offset + s];
		Node &client = nodes[offset + c];
		server.markAsServer (client.getFirstIpAddress (), emulationMode);
		client.markAsClient (server.getFirstIpAddress ());
	}
}

/*
// Random Marker --> replaced with above version
void MapCreator::markClientsAndServers () {
	int countOfNodesInThirdLayer = innerCount * secondLayerFanOut * thirdLayerFanOut;
	int countOfNodesInSecondLayer = innerCount * secondLayerFanOut;
	bool *serverSelected = new bool[countOfNodesInThirdLayer];
	int *serverIndex = new int[serversCount];
	int *countOfServersInLayer2Group = new int[countOfNodesInSecondLayer];
	int *iteratorIndexInLayer2Group = new int[countOfNodesInSecondLayer];
	for (int i = 0; i < countOfNodesInThirdLayer; ++i) { 
		serverSelected[i] = false;
	}
	for (int i = 0; i < countOfNodesInSecondLayer; ++i) {
		countOfServersInLayer2Group[i] = 0;
		iteratorIndexInLayer2Group[i] = 0;
	}
	for (int i = 0; i < serversCount; ++i) {
		int r = rand () % countOfNodesInThirdLayer;
		while (serverSelected[r]) {
			r = rand () % countOfNodesInThirdLayer;
		}
		serverSelected[r] = true;
		serverIndex[i] = r;
		countOfServersInLayer2Group[r / thirdLayerFanOut]++;
	}
	int **secondLayerGroupedServerIndex = new int*[countOfNodesInSecondLayer];
	for (int i = 0; i < countOfNodesInSecondLayer; ++i) {
		secondLayerGroupedServerIndex[i] = new int[countOfServersInLayer2Group[i]];
	}
	for (int i = 0; i < serversCount; ++i) {
		int index = serverIndex[i];
		int groupIndex = index / thirdLayerFanOut;
		secondLayerGroupedServerIndex[groupIndex][iteratorIndexInLayer2Group[groupIndex]++] = index;
	}
	// serverIndex => list of countOfNodesInThirdLayer selected servers
	// secondLayerGroupedServerIndex => above list grouped by layer 2 node

	// marking client and servers and their correspondences
	int offset = totalCount - countOfNodesInThirdLayer;
	for (int i = 0; i < countOfNodesInThirdLayer; ++i) { 
		Node &n = nodes[offset + i];
		if (serverSelected[i]) { // it's a server
			n.markAsServer ();
		} else { // it's a client
			int nearServers = countOfServersInLayer2Group[i / thirdLayerFanOut];
			int sindex;
			if (nearServers > 0) {
				int r = rand () % nearServers;
				sindex = secondLayerGroupedServerIndex[i / thirdLayerFanOut][r];
			} else {
				int r = rand () % serversCount;
				sindex = serverIndex[r];
			}
			std::uint32_t targetIp = nodes[offset + sindex].getFirstIpAddress ();
			n.markAsClient (targetIp);
		}
	}
}
*/

void MapCreator::createNode (Node &u, int nodeIndex, int maxRequiredInterfaceIndex, std::string nodeName, std::string linkName, std::uint32_t uNodeIndex, std::uint32_t ip, std::uint32_t vOwnedIpRange, int vOwnedIpRangeMaskBits) {
	Node &v = nodes[nodeIndex];
	v.init (maxRequiredInterfaceIndex, nodeName);

	v.addInterfaceAndLink (0, linkName, ip | 5);
	u.addInterfaceAndLink (uNodeIndex, linkName, ip | 1);

	u.addRouting (uNodeIndex, vOwnedIpRange, vOwnedIpRangeMaskBits, ip | 5);
	v.addRouting (0, 0, 0, ip | 1); // routes must be printed in reversed order to default route can be placed at the end of the list.
}


