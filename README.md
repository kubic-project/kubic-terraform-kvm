# terraform-kubic-kvm

The goal is to provide a simple setup of three [Kubic](https://kubic.opensuse.org/) VMs.

# About terraform-libvirt

If you want to dive in the Terraform-libvirt API, you can have a look here:

https://github.com/dmacvicar/terraform-provider-libvirt#website-docs

## Prerequisites

You're going to need at least:

* `terraform`
* [`terraform-provider-libvirt`](https://github.com/dmacvicar/terraform-provider-libvirt)


# Usage

Run 

```bash
./download-image.py
terraform init
terraform plan
terraform apply
./mk-ssh-config.sh
```
    
to start the VMs.

Some parameters (like number of virtual machines and parameters of virtual
machines) are configurable by creating a `terraform.tfvars` file which can be
copied from the sample file:

```
cp terraform.tfvars.sample terraform.tfvars
```

Please refer to the `variables.tf` file for the full variables list with
descriptions.

*note: the default password for the root user is `linux`.*

# Setting up Kubernetes cluster

Initialize the K8s cluster by running `kubeadm` on the the first node:

```bash
cat <<'EOF' | ssh -F ssh_config $(terraform output -json | jq -r '.ips.value[0][]') 'bash -s'
kubeadm init --cri-socket=/var/run/crio/crio.sock --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
EOF
```
    
And run the `kubeadm join` on the others. We just have to add `--cri-socket=/var/run/crio/crio.sock`:

```bash
join_command=$(ssh -F ssh_config $(terraform output -json | jq -r '.ips.value[0][]') "kubeadm token create --print-join-command")
join_command="kubeadm join --cri-socket=/var/run/crio/crio.sock $(echo $join_command | python -c 'import sys; print(" ".join(sys.stdin.read().split()[2:]))')"
ssh -F ssh_config $(terraform output -json | jq -r '.ips.value[1][]') "$join_command"
ssh -F ssh_config $(terraform output -json | jq -r '.ips.value[2][]') "$join_command"
```

# Howto

## Access the cluster locally

```bash
scp -F ssh_config $(terraform output -json | jq -r '.ips.value[0][]'):~/.kube/config ~/.kube/config
k get nodes
```
    
## Using an insecure private registry

```bash
registry_ip="$(terraform output -json | jq -r '.ips.value[0][]'):5000"  # or another IO
for h in $(terraform output -json | jq -r '.ips.value[][]')
do
    cat <<EOF | ssh -F ssh_config $h 'bash -s'
sed -i 's/\[crio\.image\]/[crio.image]\ninsecure_registries = ["$registry_ip"]/g' /etc/crio/crio.conf
grep -C 1 insecure /etc/crio/crio.conf
systemctl restart crio
EOF
done
 ```
 
# References

 * Outdated [Kubic blog entry](https://kubic.opensuse.org/blog/2018-08-20-kubeadm-intro/)
