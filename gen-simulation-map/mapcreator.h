#ifndef MAP_CREATOR_H
#define MAP_CREATOR_H

#include <string>

class Node;

class MapCreator {
private:
	const int latency;
	const std::string mapName;

	const int innerCount;
	const int secondLayerFanOut;
	const int thirdLayerFanOut;

	const int totalCount;
	Node *nodes;

	const int serversCount;

	const bool emulationMode;
	const bool compactScheduler;

	const int *gap; // in milli-seconds
	const int gapno;

	const int dataSize;

public:
	MapCreator (int latency, std::string mapName,
			int innerCount, int secondLayerFanOut, int thirdLayerFanOut, int serversCount,
			bool emulationMode, bool compactScheduler, int *gap, int gapno, int dataSize);
	~MapCreator ();

	void createNodes ();
	void printMap () const;

private:
	void createNode (Node &u, int nodeIndex, int maxRequiredInterfaceIndex, std::string nodeName, std::string linkName, std::uint32_t uNodeIndex, std::uint32_t ip, std::uint32_t vOwnedIpRange, int vOwnedIpRangeMaskBits);

	void markClientsAndServers ();

	std::string prepareLinkName (const char *identifier, int i, const char *layerSeparator, int j) const;
	std::string prepareLinkName (const std::string &identifier, const char *layerSeparator, int k) const;

	void printLinks () const;
	void printLink (const std::string &linkName, int indentationLevel) const;
};

#endif
