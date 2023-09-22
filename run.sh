#!/bin/bash

HOST=$(cd $PWD;pwd -P)
IMGS=$HOST/images
INST=${1:-1}
NAME=myqemu$INST
IMG=$IMGS/$NAME.img

# don't use -monitor none if we need qemu> shell
# CTRL+C kill the VM
# if=virtio and -nographic must
# for telnet: -serial telnet:0.0.0.0:4321,server,nowait
# to connect two instances over mcast sock: -device virtio-net-pci,netdev=n$INST,mac=52:54:00:12:34:1$INST -netdev socket,id=n$INST,mcast=230.0.0.1:1234
CMD="$HOST/install/bin/qemu-system-x86_64 -name guest=$NAME -m 16384 -boot order=d -enable-kvm -drive file=$IMG,if=virtio -nographic -monitor none"

$CMD -netdev user,id=net0,net=192.168.0.0/24,dhcpstart=192.168.0.9  -device virtio-net-pci,netdev=net0 $@

