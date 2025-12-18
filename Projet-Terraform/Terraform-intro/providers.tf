terraform {
    required_providers {
        incus = {
            source = "lxc/incus"
            version = "1.0.0"
        }
#        ansible = {
#            source  = "ansible/ansible"
#            version = "~> 1.3.0"
#        }
    }
}

provider "incus" {
    remote {
        name    = "phorge"   
    }
}

#provider "ansible" {
#}