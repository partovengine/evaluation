#ifndef ROUTING_H
#define ROUTING_H

#include <cstdint>


class Routing {
private:
	int index;
	std::uint32_t network;
	int netmaskbits;
	std::uint32_t nextHop;

public:
	Routing (int index, std::uint32_t network, int netmaskbits, std::uint32_t nextHop);
	int getInterfaceIndex () const;
	std::uint32_t getNextHop () const;

	void print (int realInterfaceIndex) const;
};

#endif

