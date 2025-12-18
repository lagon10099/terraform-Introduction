resource "incus_network" "CookedNetwork"{
  name    = "CookedNetwork"
  type    = "ovn"
  project = "CookedTeam"

  config = {
    "network"      = "UPLINK"
    "ipv4.address" = "192.168.2.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "none"
    "ipv6.nat"     = "false"
  }
}

resource "incus_network_forward" "web_port80" {
  project = "CookedTeam"
  network = incus_network.CookedNetwork.name
  listen_address = "10.3.0.16"
  ports = [{
    protocol       = "tcp"
    listen_port    = 80
    target_address = "192.168.2.12"
    target_port    = 80
    description    = ""
  }]
}

resource "incus_instance" "Ansible" {
  name    = "Ansible"
  image   = "images:ubuntu/24.04/cloud"
  type    = "virtual-machine"
  project = "CookedTeam"
  target  = var.incus_location

  config = {
    "boot.autostart" = true
    "security.secureboot" = "false"
    "limits.cpu"     = var.cpu_front
    "limits.memory"  = "${var.memory_front}MB"
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: false
    packages:
      - ansible
      - nano
      - git
      - python3-pip
    write_files:
      - path: /root/.ssh/id_ed25519
        owner: root:root
        permissions: '0600'
        content: ${var.cle_privee}
    runcmd:
      - ssh-keyscan -t ed25519 github.com >> /root/.ssh/known_hosts
      - git clone git@github.com:lagon10099/terraform-Introduction.git
      
  EOF
    "cloud-init.network-config" = <<-EOF
    network:
      version: 2
      ethernets:
        enp5s0:
          dhcp4: false
          dhcp6: false
          addresses: [192.168.2.11/24]
          gateway4: 192.168.2.1
          nameservers:
            addresses: [1.1.1.1, 8.8.8.8]
  EOF
  }

 device {
   name = "enp5s0"
   type = "nic"
   properties = {
     network = incus_network.CookedNetwork.name
   }
}

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "local"
      path = "/"
      size = "${var.disk_front}GB"
    }
  }
}

resource "incus_instance" "Web" {
  name    = "Web"
  image   = "images:debian/12/cloud"
  type    = "virtual-machine"
  project = "CookedTeam"
  target  = var.incus_location

  config = {
    "boot.autostart" = true
    "security.secureboot" = "false"
    "limits.cpu"     = var.cpu_back
    "limits.memory"  = "${var.memory_back}MB"
    #"security.protection.delete" = "true"
    "cloud-init.user-data" = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: false
  EOF
    "cloud-init.network-config" = <<-EOF
    network:
      version: 2
      ethernets:
        enp5s0:
          dhcp4: false
          dhcp6: false
          addresses: [192.168.2.12/24]
          gateway4: 192.168.2.1
          nameservers:
            addresses: [1.1.1.1, 8.8.8.8]
  EOF
  }

 device {
   name = "enp5s0"
   type = "nic"
   properties = {
     network = incus_network.CookedNetwork.name
   }
 }

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "local"
      path = "/"
      size = "${var.disk_back}GB"
    }
  }
}