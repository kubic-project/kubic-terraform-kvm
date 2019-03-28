# kubic-kvm

The goal is to provide a simple setup of three Kubic VMs.

You can extend the main.tf example provided in the `kubic-kvm` dir.

# About terraform-libvirt

If you want to dive in the Terraform-libvirt API, you can have a look here:

https://github.com/dmacvicar/terraform-provider-libvirt#website-docs

## Prerequisites

You're going to need at least:
* `terraform`
* [`terraform-provider-libvirt`](https://github.com/dmacvicar/terraform-provider-libvirt)


# Usage

Run 

    $ ./download-image.sh
    $ terraform init
    $ terraform plan
    $ terraform apply
    
to start the VMs and follow [https://kubic.opensuse.org/blog/2018-08-20-kubeadm-intro/](https://kubic.opensuse.org/blog/2018-08-20-kubeadm-intro/) to initialize Kubernetes.


# Setting up Kubernetes cluster

Run init on the one node:

    $ kubeadm init --cri-socket=/var/run/crio/crio.sock --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU
    $ mkdir -p $HOME/.kube
    $ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    $ sudo chown $(id -u):$(id -g) $HOME/.kube/config
    $ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
    
And join on the others:

    $ kubeadm join --cri-socket=/var/run/crio/crio.sock --ignore-preflight-errors=NumCPU ....
