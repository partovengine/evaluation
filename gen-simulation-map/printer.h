#include <iostream>

class Ip {
private:
	std::uint32_t ip;

public:
	explicit Ip (std::uint32_t _ip)
		: ip (_ip)
	{ }

	operator std::string () const {
		char ipstr[4 * 4];
		sprintf (ipstr, "%d.%d.%d.%d", ip >> 24, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF);
		return ipstr;
	}
};

inline void printTabs (int tabcount) {
	for (int i = 0; i < tabcount; ++i) {
		std::cout << "\t";
	}
}

template <typename T, typename P, typename Q, typename L, typename K>
inline void printLine (const T &s1, const P &s2, const Q &s3, const L &s4, const K &s5, int tabcount = 0) {
	printTabs (tabcount);
	std::cout << s1 << s2 << s3 << s4 << s5 << std::endl;
}

template <typename T, typename P, typename Q>
inline void printLine (const T &s1, const P &s2, const Q &s3, int tabcount = 0) {
	printTabs (tabcount);
	std::cout << s1 << s2 << s3 << std::endl;
}

template <typename T>
inline void printLine (const T &str, int tabcount = 0) {
	printTabs (tabcount);
	std::cout << str << std::endl;
}

inline void printLine () {
	std::cout << std::endl;
}

