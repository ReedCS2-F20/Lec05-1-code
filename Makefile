#
# CSCI 221 Spring 2020
#
# This Makefile is described more carefully in the README here. The
# entries rely on some special `$` "macros" that `make`
# understands. I've also defined a few other macros/variables, in a
# standard way, at the top of this file, just below.
#

CXX=g++
CXX_FLAGS=-g -std=c++11 -fsanitize=address
.PHONY: all clean
TARGETS=test_llist 

all: $(TARGETS)

llist.o: llist.hh

test_llist: test_llist.o llist.o
	$(CXX) $(CXX_FLAGS) -o $@ $^

clean:
	rm -f *.o *~ a.out core $(TARGETS)
