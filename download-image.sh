#!/bin/bash

set -e

base_url="https://download.opensuse.org/repositories/devel:/kubic:/images/openSUSE_Tumbleweed/"
name=$(curl --silent "$base_url" | pandoc -f html -t plain | egrep -e 'kubeadm-cri-o-kvm-and-xen.*qcow2.xz$')

wget -O kubic.qcow2.xz "$base_url$name"
xz -f -v --decompress kubic.qcow2.xz
