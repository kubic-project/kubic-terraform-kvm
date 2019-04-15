#!/bin/bash

set -e

base_url="https://download.opensuse.org/repositories/devel:/kubic:/images/openSUSE_Tumbleweed/"
name_xz=$(curl --silent "$base_url" | pandoc -f html -t plain | egrep -e 'kubeadm-cri-o-kvm-and-xen.*qcow2.xz$' || true)
name=$(curl --silent "$base_url" | pandoc -f html -t plain | egrep -e 'kubeadm-cri-o-kvm-and-xen.*qcow2$' || true)

if [[ ! -z "$name_xz" ]]; then
    wget -O kubic.qcow2.xz "$base_url$name_xz"
    xz -f -v --decompress kubic.qcow2.xz
elif [[ ! -z "$name" ]]; then
    wget -O kubic.qcow2 "$base_url$name"
else
    echo "Error: Could not find kubeadm-cri-o-kvm-and-xen image on $base_url"
    exit 1
fi
