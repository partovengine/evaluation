#include "interface.h"

#include "printer.h"

Interface::Interface ()
	: initilized (false)
{ }

void Interface::init (std::string _linkName, uint32_t _ip) {
	linkName = _linkName;
	ip = _ip;
	initilized = true;
}

int Interface::getRealIndex () const {
	return realIndex;
}

void Interface::printPhysicalInterface () {
	static int id = 100;
	id++;
	char macstr[3 * 6];
	std::uint32_t ip = 192 << 24 | 168 << 16 | 42 << 8 | id;
	sprintf (macstr, "00:0c:29:95:00:%02X", id - 100);
	printLine ("<ptl:physical-ethernet-interface>", 4);
	printLine ("<ptl:device-name>eth0</ptl:device-name><ptl:mac-address>", macstr, "</ptl:mac-address><ptl:ip-address>", static_cast<std::string> (Ip (ip)), "</ptl:ip-address>", 5);
	printLine ("<ptl:netmask>255.255.255.0</ptl:netmask><ptl:max-buffer-size-ref>buffer-size</ptl:max-buffer-size-ref>", 5);
	printLine ("</ptl:physical-ethernet-interface>", 4);
}

void Interface::print (int _realIndex) {
	realIndex = _realIndex;
	char macstr[3 * 6];
	sprintf (macstr, "%02X:%02X:%02X:%02X:%02X:%02X", 0x24, 0x8C, ip >> 24, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF);
	printLine ("<ptl:ethernet-interface>", 4);
	printLine ("<ptl:mac-address>", macstr, "</ptl:mac-address><ptl:ip-address>", static_cast<std::string> (Ip (ip)), "</ptl:ip-address>", 5);
	printLine ("<ptl:netmask>255.255.255.0</ptl:netmask><ptl:max-buffer-size-ref>buffer-size</ptl:max-buffer-size-ref>", 5);
	printLine ("<ptl:connected-to-link ptl:name=\"", linkName, "\"/>", 5);
	printLine ("</ptl:ethernet-interface>", 4);
}

bool Interface::isInitialized () const {
	return initilized;
}

std::uint32_t Interface::getIp () const {
	return ip;
}

