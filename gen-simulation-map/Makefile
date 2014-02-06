COMPILER = g++
FLAGS = -Wall -g -std=c++0x
LIBS =

TARGET = gen-simulation-map.out

SOURCES = gen-simulation-map.cpp \
	mapcreator.cpp \
	node.cpp \
	interface.cpp \
	routing.cpp

OBJ1 = ${SOURCES:.cpp=.o}
OBJ2 = ${OBJ1:.h=.o}
OBJECTS = ${OBJ2:.c=.o}

all: ${TARGET}

${TARGET}: ${OBJECTS}
	${COMPILER} ${FLAGS} -o ${TARGET} ${OBJECTS} ${LIBS}

clean:
	rm -f ${OBJECTS} ${TARGET}

.cpp.o:
	${COMPILER} ${FLAGS} -c $< -o $@
.c.o:
	${COMPILER} ${FLAGS} -c $< -o $@
