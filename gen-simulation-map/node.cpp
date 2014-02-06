#include <string>

#include "node.h"
#include "printer.h"

#include "routing.h"

Node::Node ()
	: mode (Router)
{ }

Node::~Node () {
	if (interfaces) {
		delete[] interfaces;
	}
	while (!routings.empty ()) {
		Routing *r = routings.back ();
		routings.pop_back ();
		delete r;
	}
}

void Node::init (int maxRequiredInterfaceIndex, std::string _name) {
	name = _name;
	interfaceUpperLimit = maxRequiredInterfaceIndex + 1;
	interfaces = new Interface[interfaceUpperLimit];
}

void Node::addInterfaceAndLink (int index, std::string linkName, uint32_t ip) {
	interfaces[index].init (linkName, ip);
}

void Node::addRouting (int index, std::uint32_t network, int netmaskbits, std::uint32_t nextHop) {
	Routing *r = new Routing (index, network, netmaskbits, nextHop);
	routings.push_back (r);
}

void Node::markAsServer (std::uint32_t _targetIp, bool emulated) {
	if (emulated) {
		mode = EmulatedServer;
	} else {
		mode = SimulatedServer;
	}
	targetIp = _targetIp;
}

void Node::markAsClient (std::uint32_t _targetIp) {
	mode = Client;
	targetIp = _targetIp;
}

std::uint32_t Node::getFirstIpAddress () const {
	for (int i = 0; i < interfaceUpperLimit; ++i) {
		if (interfaces[i].isInitialized ()) {
			return interfaces[i].getIp ();
		}
	}
	std::cerr << "Node has no IP address" << std::endl;
	throw 2;
}

void Node::printInterfaces () const {
	printLine ("<ptl:interfaces>", 3);
	if (mode == EmulatedServer) {
		Interface::printPhysicalInterface ();
	}
	for (int i = 0, j = 0; i < interfaceUpperLimit; ++i) {
		if (interfaces[i].isInitialized ()) {
			interfaces[i].print (j++);
		}
	}
	printLine ("</ptl:interfaces>", 3);
}

void Node::printRouter () const {
	printLine ("<ptl:plugin ptl:name=\"", name, "\" ptl:plugin-identifier=\"Router\">", 2);

	printInterfaces ();

	printLine ("<ptl:parameters>", 3);
	printLine ("<ptl:param ptl:name=\"routing-table\">", 4);
	for (int i = routings.size () - 1; i >= 0; --i) {
		int index = routings[i]->getInterfaceIndex ();
		index = interfaces[index].getRealIndex ();
		routings[i]->print (index);
		if (i > 0) {
			printLine ();
		}
	}
	printLine ("</ptl:param>", 4);
	printLine ("</ptl:parameters>", 3);
	printLine ("</ptl:plugin>", 2);
}

void Node::printClient (int gapno, int dataSize) const {
	static int index = 0;
	printLine ("<ptl:plugin ptl:name=\"", name, "\" ptl:plugin-identifier=\"Pinger\">", 2);

	printInterfaces ();

	printLine ("<ptl:tick-interval-ref>gap-interval", (index++ % gapno), "</ptl:tick-interval-ref>", 3);

	printLine ("<ptl:parameters>", 3);

	printLine ("<ptl:param ptl:name=\"next-hop\">", 4);
	printLine ("<ptl:value>", static_cast<std::string> (Ip (routings.back ()->getNextHop ())), "</ptl:value>", 5);
	printLine ("</ptl:param>", 4);
	printLine ("<ptl:param ptl:name=\"identifier-mode\">", 4);
	printLine ("<ptl:value>incremental</ptl:value>", 5);
	printLine ("</ptl:param>", 4);
	if (dataSize != -1) {
		printLine ("<ptl:param ptl:name=\"data-size\">", 4);
		printLine ("<ptl:value>", dataSize, "</ptl:value>", 5);
		printLine ("</ptl:param>", 4);
	}
	printLine ("<ptl:param ptl:name=\"target-host\">", 4);
	printLine ("<ptl:value>", static_cast<std::string> (Ip (targetIp)), "</ptl:value>", 5);
	printLine ("</ptl:param>", 4);
	printLine ("<ptl:param ptl:name=\"verbose\">", 4);
	printLine ("<ptl:value>true</ptl:value>", 5);
	printLine ("</ptl:param>", 4);

	printLine ("</ptl:parameters>", 3);
	printLine ("</ptl:plugin>", 2);
}

void Node::printSimulatedServer () const {
	printLine ("<ptl:simple ptl:name=\"", name, "\">", 2);

	printInterfaces ();

	printLine ("</ptl:simple>", 2);
}

void Node::printEmulatedServer () const {
	printLine ("<ptl:plugin ptl:name=\"", name, "\" ptl:plugin-identifier=\"OneToOneIcmpProxy\">", 2);

	printInterfaces ();

	printLine ("<ptl:parameters>", 3);

	printLine ("<ptl:param ptl:name=\"first-host\">", 4);
	printLine ("<ptl:value>192.168.42.1</ptl:value>", 5);
	printLine ("<ptl:value>192.168.42.1</ptl:value>", 5);
	printLine ("</ptl:param>", 4);
	printLine ("<ptl:param ptl:name=\"second-host\">", 4);
	printLine ("<ptl:value>", static_cast<std::string> (Ip (targetIp)), "</ptl:value>", 5);
	printLine ("<ptl:value>", static_cast<std::string> (Ip (routings.back ()->getNextHop ())), "</ptl:value>", 5);
	printLine ("</ptl:param>", 4);

	printLine ("</ptl:parameters>", 3);
	printLine ("</ptl:plugin>", 2);
}

void Node::print (int gapno, int dataSize) const {
	switch (mode) {
	case Router:
		printRouter ();
		break;
	case Client:
		printClient (gapno, dataSize);
		break;
	case SimulatedServer:
		printSimulatedServer ();
		break;
	case EmulatedServer:
		printEmulatedServer ();
		break;
	default:
		std::cerr << "Error: Unknown mode value:" << mode << std::endl;
		throw 1;
	}
}


