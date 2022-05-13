variable "kubespray_git_ref" {
  description = "Kubespray ref name"
  type        = string
  default     = "refs/tags/v2.17.1"
}

variable "kubespray_dir" {
  description = "Kubespray target dir"
  type        = string
  default     = "/cluster/kubespray"
}

variable "deploy_components" {
  description = "Either to deploy or not kubernetes components. Set to true after kubernetes is up and running."
  type        = bool
  default     = false
}

variable "region" {
  description = "Cluster Region"
  type        = string
  default     = null
}

variable "master_nodes" {
  description = "List of master nodes to provision"
  type        = list(any)
  default = [
    {
      address : "1.1.1.1",
      hostname : "master-0",
      ssh_private_key : "~/.ssh/id_rsa",

      disks : {
        etcd : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/containers"
        },
        kubelet : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/kubelet"
        }
        containers : {
          device : "/dev/sdd",
          mountpoint : "/var/lib/etcd"
        }
      }
    }
  ]
}

variable "infra_nodes" {
  description = "List of worker nodes to provision"
  type        = list(any)
  default = [
    {
      address : "2.2.2.2",
      hostname : "infra-0"

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
        }
        containers : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/containers",
        }
      }
    }
  ]
}

variable "app_nodes" {
  description = "List of worker nodes to provision"
  type        = list(any)
  default = [
    {
      address : "3.3.3.3",
      hostname : "app-0",

      disks : {
        kubelet : {
          device : "/dev/sdb",
          mountpoint : "/var/lib/kubelet",
        }
        containers : {
          device : "/dev/sdc",
          mountpoint : "/var/lib/containers",
        }
      }
    }
  ]
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "centos"
}

variable "ssh_password" {
  description = "SSH password"
  type        = string
  default     = ""
}

variable "ssh_private_key" {
  description = "Path for SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_bastion_host" {
  description = "SSH password"
  type        = string
  default     = ""
}

variable "ssh_bastion_user" {
  description = "SSH bastion username"
  type        = string
  default     = ""
}

variable "ssh_bastion_password" {
  description = "SSH bastion password"
  type        = string
  default     = ""
}

variable "ssh_bastion_private_key" {
  description = "Path for SSH bastion private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "custom_provisioner" {
  description = "Path for custom provisioner script"
  type        = string
  default     = ""
}

variable "install_packages" {
  description = "Extra packages to install on nodes"
  type        = list(string)
  default     = []
}

variable "uninstall_packages" {
  description = "Extra packages to uninstall from nodes"
  type        = list(string)
  default     = []
}

variable "etc_hosts" {
  description = "Entries to add to /etc/hosts on each node, Example: {\"1.1.1.1\":\"example.com example.io\"}"
  type        = map(string)
  default     = {}
}

variable "systemctl_enable" {
  description = "Services to enable on nodes"
  type        = list(string)
  default = [
    "chronyd",
    "iscsid"
  ]
}

variable "systemctl_disable" {
  description = "Services to disable on nodes"
  type        = list(string)
  default     = []
}
