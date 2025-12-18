variable "cpu_front" {
    description = "Number of CPU cores for the Front instance."
    type        = number
}

variable "memory_front" {
    description = "Amount of memory (in MB) for the Front instance."
    type        = number
}

variable "disk_front" {
    description = "Amount of disk space (in GB) for the Front instance."
    type        = number
}

variable "cpu_back" {
    description = "Number of CPU cores for the Back instance."
    type        = number
    
}

variable "memory_back" {
    description = "Amount of memory (in MB) for the Back instance."
    type        = number
}

variable "disk_back" {
    description = "Amount of disk space (in GB) for the Back instance."
    type        = number
}

variable "incus_location" {
    description = "Cluster member name to place the instances."
    type        = string
}

variable "cle_privee_b64" {
  type        = string
  sensitive   = true
  description = "Clé privée base64"
}