provider "vsphere" {
    user                 = var.vsphere_user
    password             = var.vsphere_password
    vsphere_server       = var.vsphere_vcenter
    allow_unverified_ssl = var.allow_unverified_ssl
}

# main.tf

# Data source for vCenter Datacenter
data "vsphere_datacenter" "datacenter" {
    name = "Datacenter"
}

# Data source for vCenter Datastore
data "vsphere_datastore" "datastore" {
    name          = "datastore2"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere-cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_network" "network" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm-template-name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm01" {
  name             = "master01"
  firmware         = "efi"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  num_cpus         = var.cpu
  memory           = var.ram
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "master"
        domain    = "node"
      }
      network_interface {
        ipv4_address = "192.168.179.222"
        ipv4_netmask = 24
        dns_server_list = ["1.1.1.1", "8.8.8.8"]
        
      }
      ipv4_gateway = var.ipv4_gateway
      
    }
  }
}


