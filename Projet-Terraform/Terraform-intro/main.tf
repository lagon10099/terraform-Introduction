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

locals {
  cle_privee = base64decode(var.cle_privee_b64)
}

resource "incus_network_forward" "web_port80" {
  project = "CookedTeam"
  network = incus_network.CookedNetwork.name
  listen_address = "10.3.0.16"
  ports = [{
    protocol       = "tcp"
    listen_port    = "80"
    target_address = "192.168.2.12"
    target_port    = "80"
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
    "cloud-init.user-data" = <<EOF
#cloud-config
package_update: true
package_upgrade: false
packages:
  - ansible
  - curl
  - nano
  - git
  - python3-pip
write_files:
  - path: /root/.ssh/id_ed25519
    owner: root:root
    permissions: '0600'
    encoding: b64
    content: ${var.cle_privee_b64}
runcmd:
  - mkdir -p /root/.ssh && chmod 700 /root/.ssh
  - ssh-keyscan -t ed25519 github.com >> /root/.ssh/known_hosts
  - ansible-galaxy install geerlingguy.docker
  - ansible-galaxy install geerlingguy.pip
  - GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" git clone git@github.com:lagon10099/terraform-Introduction.git /root/terraform-Introduction || (cat /var/log/cloud-init-output.log && exit 1)
  - cd /root/terraform-Introduction/Projet-Terraform/Ansible && ansible-playbook -i inventories/production/hosts -u debian --private-key /root/.ssh/id_ed25519 playbooks/deploy-webfile.yml
EOF
    "cloud-init.network-config" = <<EOF
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
    "cloud-init.user-data" = <<EOF
#cloud-config
package_update: true
package_upgrade: false
packages:
  - openssh-server
users:
  - name: debian
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFdusjne1g5kAsP65drVjlH/RZc3mAQwJ4yevi68Zvxq ansible-deploy
runcmd:
  - ufw allow 22/tcp
EOF
    "cloud-init.network-config" = <<EOF
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