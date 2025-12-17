resource "incus_network" "CookedNetwork"{
  name    = "CookedNetwork"
  type    = "ovn"
  project = "CookedTeam"

  config = {
    "network"      = "UPLINK"
    "ipv4.address" = "192.168.1.1/24"
    "ipv4.nat"     = "true"
  }

}

 
resource "incus_instance" "Front" {
  name    = "Front"
  image   = "images:alpine/3.19"
  type    = "virtual-machine"
  project = "CookedTeam"
  target  = var.incus_location

  config = {
    "boot.autostart" = true
    "security.secureboot" = "false"
    "limits.cpu"     = var.cpu_front
    "limits.memory"  = var.memory_front
  }

  device {
    name = "eth0"
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
      size = "16GB"
    }
  }
}

resource "incus_instance" "Back" {
  name    = "Back"
  image   = "images:ubuntu/24.04/cloud"
  type    = "virtual-machine"
  project = "CookedTeam"
  target  = var.incus_location

  config = {
    "boot.autostart" = true
    "security.secureboot" = "false"
    "limits.cpu"     = var.cpu_back
    "limits.memory"  = var.memory_back
  }

  device {
    name = "eth0"
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