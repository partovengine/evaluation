#include "routing.h"

#include "printer.h"

Routing::Routing(int _index, std::uint32_t _network, int _netmaskbits, std::uint32_t _nextHop)
	: index (_index), network (_network), netmaskbits (_netmaskbits), nextHop (_nextHop)
{ }

int Routing::getInterfaceIndex () const {
	return index;
}

std::uint32_t Routing::getNextHop () const {
	return nextHop;
}

void Routing::print (int realInterfaceIndex) const {
	printLine ("<ptl:value>", static_cast<std::string> (Ip (network)), "</ptl:value>", 5);
	printLine ("<ptl:value>", netmaskbits, "</ptl:value>", 5);
	printLine ("<ptl:value>", static_cast<std::string> (Ip (nextHop)), "</ptl:value>", 5);
	printLine ("<ptl:value>", realInterfaceIndex, "</ptl:value>", 5);
}

