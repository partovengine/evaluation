#ifndef NODE_H
#define NODE_H

#include <vector>
#include "interface.h"

class Routing;

class Node {
private:
	std::string name;
	int interfaceUpperLimit;
	Interface *interfaces;
	std::vector<Routing *> routings;
	enum Mode {
		Router,
		Client,
		SimulatedServer,
		EmulatedServer
	} mode;
	std::uint32_t targetIp; // for clients

public:
	Node ();
	~Node ();

	void init (int maxRequiredInterfaceIndex, std::string name);

	void addInterfaceAndLink (int index, std::string linkName, std::uint32_t ip);
	void addRouting (int index, std::uint32_t network, int netmaskbits, std::uint32_t nextHop);
	// nodes are router by default
	void markAsServer (std::uint32_t targetIp, bool emulated);
	void markAsClient (std::uint32_t targetIp);

	std::uint32_t getFirstIpAddress () const;

	void print (int gapno, int dataSize) const;

private:
	void printRouter () const;
	void printClient (int gapno, int dataSize) const;
	void printSimulatedServer () const;
	void printEmulatedServer () const;
	void printInterfaces () const;
};

#endif
