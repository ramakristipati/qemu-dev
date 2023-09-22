
all: build

fetch:
	GIT_SSL_NO_VERIFY=1 git submodule update --init --recursive

build:
	./build.sh

run:
	./run.sh
