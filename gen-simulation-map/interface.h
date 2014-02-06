#ifndef INTERFACE_H
#define INTERFACE_H

#include <string>

class Interface {
private:
	bool initilized;
	std::string linkName;
	std::uint32_t ip;
	int realIndex;

public:
	Interface ();

	void init (std::string linkName, std::uint32_t ip);
	bool isInitialized () const;
	int getRealIndex () const;
	static void printPhysicalInterface ();
	void print (int realIndex);
	std::uint32_t getIp () const;
};

#endif
