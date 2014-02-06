
template <typename T, typename P, typename Q>
inline void printLine (const T &s1, const P &s2, const Q &s3) {
	cout << s1 << s2 << s3 << endl;
}

template <typename T>
inline void printLine (const T &str) {
	cout << str << endl;
}

inline void printLine () {
	cout << endl;
}

