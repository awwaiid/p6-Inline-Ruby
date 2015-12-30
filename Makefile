.PHONY: clean test
all: ./resources/pyhelper.so
clean:
	rm ./resources/pyhelper.so
./resources/pyhelper.so: pyhelper.c
	gcc pyhelper.c -Wall -I"/usr/include/python2.7" -L"/usr/lib/python2.7/config-x86_64-linux-gnu" -lpython2.7 -shared -o ./resources/pyhelper.so -fPIC -g
test: all
	prove -e 'perl6 -Ilib' t
