#!/bin/bash

TMPD=$(mktemp -d)
trap "rm -rf $TMPD" EXIT

HST=$(cd $PWD;pwd -P)
SRC=$HST/qemu
BLD=$SRC/build

cat << EOF > $TMPD/build_roms.sh
#!/bin/bash
pushd $SRC/roms
    make -C edk2/BaseTools -j8
    make -f Makefile.edk2 flashdevs=x86_64-code -j8
popd
EOF
chmod +x $TMPD/build_roms.sh

cat << EOF > $TMPD/Dockerfile
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND    noninteractive
RUN apt-get update -qq
RUN apt-get install -y gcc ccache expect libssl-dev wget curl xterm device-tree-compiler
RUN apt-get install -y build-essential gcc python g++ pkg-config libz-dev
RUN apt-get install -y libglib2.0-dev libpixman-1-dev libfdt-dev git
RUN apt-get install -y libstdc++6 valgrind libtcl8.6 libmbedtls-dev
RUN apt-get install -y python3-pip
RUN apt-get install -y ninja-build
RUN apt-get install -y flex bison
RUN apt-get install -y vim bc nasm iasl
RUN apt-get install -y dos2unix
#RUN apt-get install -y gcc-aarch64-linux-gnu
#RUN apt-get install -y gcc-arm-linux-gnueabi
#RUN apt-get install -y gcc-powerpc64le-linux-gnu
COPY . /workarea/
WORKDIR /workarea
EOF

pushd $TMPD
    docker build -t qemu-focal .
popd

OPTS="--enable-slirp"

RUN="docker run -it -v $HST:$HST"
$RUN qemu-focal mkdir -p $BLD
$RUN -w $BLD qemu-focal bash -x /workarea/build_roms.sh
$RUN -w $BLD qemu-focal $SRC/configure --target-list=x86_64-softmmu --static --prefix=$HST/install
$RUN -w $BLD qemu-focal make -j8 all install
$RUN -w $BLD qemu-focal bash
