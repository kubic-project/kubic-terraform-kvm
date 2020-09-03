terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "kubic_image" {
  name   = "kubic_image"
  source = "./kubic.qcow2"
}

resource "libvirt_volume" "os_volume" {
  name           = "os_volume-${count.index}"
  base_volume_id = libvirt_volume.kubic_image.id
  count          = var.count_vms
}

resource "libvirt_volume" "data_volume" {
  name = "data_volume-${count.index}"

  // 6 * 1024 * 1024 * 1024
  size  = 6442450944
  count = var.count_vms
}

resource "libvirt_network" "kubic_network" {
  name   = "kubic-network"
  mode   = var.network_mode
  domain = var.dns_domain

  dns {
    enabled = true
  }

  addresses = [var.network_cidr]
}

data "template_file" "ignition_data" {
  count    = var.count_vms
  template = file("commoninit.ign")

  vars = {
    hostname = "kubic-${count.index}"
  }
}

resource "libvirt_ignition" "kubic_ignition" {
  name    = "kubic-ignition-${count.index}"
  content = element(data.template_file.ignition_data.*.rendered, count.index)
  count   = var.count_vms
}

resource "libvirt_domain" "kubic_domain" {
  name = "kubic-kubeadm-${count.index}"

  cpu = {
    mode = "host-passthrough"
  }

  memory = var.memory
  vcpu   = var.vcpu

  disk {
    volume_id = element(libvirt_volume.os_volume.*.id, count.index)
  }

  disk {
    volume_id = element(libvirt_volume.data_volume.*.id, count.index)
  }

  network_interface {
    network_name   = "kubic-network"
    hostname       = "kubic-kubeadm-${count.index}"
    wait_for_lease = true
  }

  coreos_ignition = element(libvirt_ignition.kubic_ignition.*.id, count.index)
  count           = var.count_vms
}

output "ips" {
  value = libvirt_domain.kubic_domain.*.network_interface.0.addresses
}
